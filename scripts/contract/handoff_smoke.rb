#!/usr/bin/env ruby
require "fileutils"
require "yaml"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)
FINAL_PRD = File.join(ROOT, "docs/prd/examples/2.0/happy-path-run/prd/prd-04.final_prd.yaml")
RUN_ROOT = File.join(ROOT, "runs", "contract-handoff-smoke")

def run!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

def run_with_env!(env, *cmd)
  puts "$ #{cmd.join(' ')}"
  success = system(env, *cmd, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

def ensure_file!(path)
  return if File.exist?(path)

  warn "Expected file not found: #{path}"
  exit 1
end

def expect_failure!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  if success
    warn "Expected command to fail but it succeeded"
    exit 1
  end
end

def expect_failure_with_env!(env, *cmd)
  puts "$ #{cmd.join(' ')}"
  success = system(env, *cmd, chdir: ROOT)
  if success
    warn "Expected command to fail but it succeeded"
    exit 1
  end
end

begin
  FileUtils.rm_rf(RUN_ROOT)
  FileUtils.mkdir_p(RUN_ROOT)
  run!("ruby", "scripts/contract/generate_batch_handoffs.rb", "--force", RUN_ROOT, FINAL_PRD)

  index_path = File.join(RUN_ROOT, "contract_handoff", "contract-handoff.index.yaml")
  ensure_file!(index_path)
  ensure_file!(File.join(RUN_ROOT, "contract_handoff", "contract-handoff.md"))
  ensure_file!(File.join(RUN_ROOT, "contract_handoff", "flows", "01.batch-01-core-model.handoff.yaml"))
  ensure_file!(File.join(RUN_ROOT, "contract_handoff", "flows", "01.batch-01-core-model.handoff.md"))
  ensure_file!(File.join(RUN_ROOT, "contract_handoff", "flows", "02.batch-02-admin-pages.handoff.yaml"))
  ensure_file!(File.join(RUN_ROOT, "contract_handoff", "flows", "03.batch-03-tags.handoff.yaml"))

  index = YAML.safe_load(File.read(index_path), permitted_classes: [Time], aliases: true)
  unless index["recommended_entry_flow"] == "batch-01-core-model"
    warn "Unexpected recommended_entry_flow: #{index['recommended_entry_flow']}"
    exit 1
  end
  unless Array(index["flows"]).size == 3
    warn "Expected 3 flows in contract-handoff.index.yaml"
    exit 1
  end

  runs_root = File.join("/tmp", "contract-handoff-init-smoke")
  ENV["CONTRACT_RUNS_ROOT"] = runs_root
  FileUtils.rm_rf(runs_root)
  run_with_env!({ "CONTRACT_RUNS_ROOT" => runs_root }, "ruby", "scripts/contract/init_flow_run.rb", File.join(RUN_ROOT, "contract_handoff", "flows", "01.batch-01-core-model.handoff.yaml"))
  
  # Initialization should now succeed even for pending flows (as standardized shells)
  run_with_env!({ "CONTRACT_RUNS_ROOT" => runs_root }, "ruby", "scripts/contract/init_flow_run.rb", File.join(RUN_ROOT, "contract_handoff", "flows", "02.batch-02-admin-pages.handoff.yaml"))
  
  # Verify prompt for pending flow
  run_02_root = ContractFlow::WorkflowManifest.run_root(runs_root, "batch-02-admin-pages")
  pending_prompt_path = File.join(run_02_root, "prompts", "run-agent-prompt.md")
  ensure_file!(pending_prompt_path)
  pending_prompt = File.read(pending_prompt_path)
  unless pending_prompt.include?("- **当前状态**: `pending`") || pending_prompt.include?("- **当前状态**: `pending_dependencies`")
    warn "Pending flow prompt did not show pending status"
    exit 1
  end

  invalid_final_prd = File.join(RUN_ROOT, "prd-04.invalid.final_prd.yaml")
  final_prd = YAML.safe_load(File.read(FINAL_PRD), permitted_classes: [Time], aliases: true)
  batch = Array(final_prd["ready_batches"]).find { |item| item.is_a?(Hash) && item["batch_id"] == "batch-01-core-model" }
  batch ||= Array(final_prd["prd_batches"]).find { |item| item.is_a?(Hash) && item["batch_id"] == "batch-01-core-model" }
  batch&.delete("contract_handoff")
  File.write(invalid_final_prd, YAML.dump(final_prd))
  expect_failure!("ruby", "scripts/contract/generate_batch_handoffs.rb", "--force", RUN_ROOT, invalid_final_prd)

  puts "Contract handoff smoke passed."
ensure
  FileUtils.rm_rf(RUN_ROOT)
  FileUtils.rm_rf(File.join("/tmp", "contract-handoff-init-smoke"))
end
