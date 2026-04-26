#!/usr/bin/env ruby
require "fileutils"

ROOT = File.expand_path("../..", __dir__)
FINAL_PRD = File.join(ROOT, "docs/prd/examples/2.0/happy-path-run/prd/prd-04.final_prd.yaml")
RUN_ROOT = File.join("/tmp", "contract-progress-board-smoke")

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

begin
  FileUtils.rm_rf(RUN_ROOT)
  FileUtils.mkdir_p(RUN_ROOT)

  run!("ruby", "scripts/contract/generate_batch_handoffs.rb", RUN_ROOT, FINAL_PRD)

  assert(File.exist?(File.join(RUN_ROOT, "contract_handoff", "contract-handoff.index.yaml")), "Expected contract_handoff index to be generated")
  assert(File.exist?(File.join(RUN_ROOT, "contract_handoff", "flows", "01.batch-01-core-model.handoff.yaml")), "Expected structured flow handoff to be generated")
  assert(!File.exist?(File.join(RUN_ROOT, "progress", "workflow-progress.md")), "Step 2 should not materialize contract progress files")
  assert(!File.exist?(File.join(RUN_ROOT, "contract", "contract-batch-index.yaml")), "Step 2 should not regenerate legacy contract batch index")

  puts "Contract progress board smoke passed."
ensure
  FileUtils.rm_rf(RUN_ROOT)
end
