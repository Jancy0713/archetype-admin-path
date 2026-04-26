#!/usr/bin/env ruby
require "fileutils"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
FINAL_PRD = File.join(ROOT, "docs/prd/examples/2.0/happy-path-run/prd/prd-04.final_prd.yaml")
RUN_ROOT = File.join("/tmp", "contract-initial-ready-smoke")

def run!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

def assert(condition, message)
  return if condition

  warn message
  exit 1
end

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Time], aliases: true)
end

begin
  FileUtils.rm_rf(RUN_ROOT)
  FileUtils.mkdir_p(RUN_ROOT)

  modified_final_prd = File.join(RUN_ROOT, "prd-04.parallel.final_prd.yaml")
  final_prd = load_yaml(FINAL_PRD)
  batch = Array(final_prd["prd_batches"]).find { |item| item.is_a?(Hash) && item["batch_id"] == "batch-02-admin-pages" }
  unless batch
    warn "batch-02-admin-pages not found in final_prd fixture"
    exit 1
  end
  batch["dependency_batches"] = []
  File.write(modified_final_prd, YAML.dump(final_prd))

  run!("ruby", "scripts/contract/generate_batch_handoffs.rb", "--force", RUN_ROOT, modified_final_prd)

  index = load_yaml(File.join(RUN_ROOT, "contract_handoff", "contract-handoff.index.yaml"))
  second_flow = Array(index["flows"]).find { |flow| flow["flow_id"] == "batch-02-admin-pages" }
  assert(second_flow && second_flow["status"] == "ready", "Independent second flow should be ready at handoff generation time")

  handoff = load_yaml(File.join(RUN_ROOT, "contract_handoff", "flows", "02.batch-02-admin-pages.handoff.yaml"))
  assert(handoff["status"] == "ready", "Second flow handoff should inherit ready status when dependencies are empty")

  puts "Initial ready smoke passed."
ensure
  FileUtils.rm_rf(RUN_ROOT)
end
