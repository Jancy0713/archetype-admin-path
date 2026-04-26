#!/usr/bin/env ruby
require "fileutils"
require "yaml"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)
SOURCE_RUN = File.join(ROOT, "runs", "2026-04-26-ai-init-prd-final")
TMP_RUN = File.join("/tmp", "contract-mainline-smoke")
TMP_CONTRACT_RUNS_ROOT = File.join("/tmp", "contract-mainline-runs")
def tmp_contract_run_root
  ContractFlow::WorkflowManifest.run_root(TMP_CONTRACT_RUNS_ROOT, "batch-foundation-access")
end

def run!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system({ "CONTRACT_RUNS_ROOT" => TMP_CONTRACT_RUNS_ROOT }, *cmd, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

def ensure_file!(path)
  return if File.exist?(path)

  warn "Expected file not found: #{path}"
  exit 1
end

begin
  ENV["CONTRACT_RUNS_ROOT"] = TMP_CONTRACT_RUNS_ROOT
  FileUtils.rm_rf(TMP_RUN)
  FileUtils.rm_rf(TMP_CONTRACT_RUNS_ROOT)
  FileUtils.mkdir_p(TMP_RUN)
  FileUtils.cp_r(File.join(SOURCE_RUN, "."), TMP_RUN)
  FileUtils.rm_rf(File.join(TMP_RUN, "contract_handoff"))

  review_path = File.join(TMP_RUN, "prd", "prd-04.review.yaml")
  run!("ruby", "scripts/prd/review_complete.rb", TMP_RUN, review_path)

  index_path = File.join(TMP_RUN, "contract_handoff", "contract-handoff.index.yaml")
  handoff_doc_path = File.join(TMP_RUN, "contract_handoff", "contract-handoff.md")
  current_handoff_path = File.join(TMP_RUN, "contract_handoff", "flows", "01.batch-foundation-access.handoff.yaml")
  progress_path = File.join(TMP_RUN, "progress", "workflow-progress.md")

  ensure_file!(index_path)
  ensure_file!(handoff_doc_path)
  ensure_file!(current_handoff_path)
  ensure_file!(progress_path)

  index = YAML.safe_load(File.read(index_path), permitted_classes: [Time], aliases: true)
  unless index["recommended_entry_flow"] == "batch-foundation-access"
    warn "Unexpected recommended_entry_flow: #{index['recommended_entry_flow']}"
    exit 1
  end

  run_root = tmp_contract_run_root
  ensure_file!(File.join(run_root, "intake", "contract-handoff.snapshot.yaml"))
  ensure_file!(File.join(run_root, "intake", "contract-handoff.snapshot.md"))
  ensure_file!(File.join(run_root, "contract", "working"))
  ensure_file!(File.join(run_root, "contract", "release"))
  ensure_file!(File.join(run_root, "progress", "workflow-progress.md"))

  progress = File.read(progress_path)
  unless progress.include?("current_step_id: contract_handoff")
    warn "Progress board did not move to contract_handoff"
    exit 1
  end
  run_id = File.basename(run_root)
  unless progress.include?(run_id) && progress.include?("/prompts/run-agent-prompt.md")
    warn "Progress board did not point to the contract startup prompt. Expected #{run_id} in #{progress_path}"
    exit 1
  end
  unless progress.include?(run_id) && progress.include?("/contract/working/contract-01.scope_intake.yaml")
    warn "Progress board did not point to the first working artifact. Expected #{run_id} in #{progress_path}"
    exit 1
  end

  puts "Contract mainline smoke passed."
ensure
  FileUtils.rm_rf(TMP_RUN)
  FileUtils.rm_rf(TMP_CONTRACT_RUNS_ROOT)
end
