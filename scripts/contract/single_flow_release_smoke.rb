#!/usr/bin/env ruby
require "fileutils"
require "yaml"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)
SOURCE_PRD_RUN = File.join(ROOT, "runs", "2026-04-26-ai-init-prd-final")
RUNS_ROOT = File.join("/tmp", "contract-single-flow-release-smoke")
BASELINES_ROOT = File.join(RUNS_ROOT, "baselines")
ENV["CONTRACT_RUNS_ROOT"] = RUNS_ROOT

def get_run_root(flow_id)
  ContractFlow::WorkflowManifest.run_root(RUNS_ROOT, flow_id)
end

def run!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system({
    "CONTRACT_RUNS_ROOT" => RUNS_ROOT,
    "CONTRACT_BASELINES_ROOT" => BASELINES_ROOT
  }, *cmd, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

def run_expect_failure!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system({ "CONTRACT_RUNS_ROOT" => RUNS_ROOT }, *cmd, chdir: ROOT)
  if success
    warn "Expected command to fail but it succeeded"
    exit 1
  end
end

def assert(condition, message)
  return if condition

  warn message
  exit 1
end

def load_yaml(path)
  YAML.safe_load(File.read(path), permitted_classes: [Time], aliases: true)
end

def write_yaml(path, payload)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, YAML.dump(payload))
end

def prd_run_root
  File.join(RUNS_ROOT, "2026-04-26-ai-init-prd-final")
end

def handoff_path(order, flow_id)
  File.join(prd_run_root, "contract_handoff", "flows", format("%02d.%s.handoff.yaml", order, flow_id))
end

def fill_scope_intake(path)
  data = load_yaml(path)
  data["intake_basis"]["handoff_snapshot_path"] = "../../intake/contract-handoff.snapshot.yaml"
  data["intake_basis"]["handoff_summary_path"] = "../../intake/contract-handoff.snapshot.md"
  data["intake_basis"]["source_final_prd_path"] = File.join(prd_run_root, "prd", "prd-04.final_prd.yaml")
  data["batch_scope"]["goal"] = "Foundation access contract"
  data["batch_scope"]["in_scope_modules"] = ["foundation-access"]
  data["dependencies"]["prerequisite_flows"] = []
  data["dependencies"]["referenced_release_contracts"] = []
  data["do_not_assume"] = ["Do not assume unsupported tenant scope"]
  data["decision"]["allow_domain_mapping"] = true
  data["decision"]["reason"] = "scope ready"
  write_yaml(path, data)
end

def fill_domain_mapping(path)
  data = load_yaml(path)
  # RUN_ROOT was hardcoded in previous version, now using the actual path
  run_root = File.expand_path("..", File.dirname(File.dirname(path)))
  data["mapping_basis"]["scope_intake_path"] = File.join(run_root, "contract/working/contract-01.scope_intake.yaml")
  data["mapping_basis"]["handoff_snapshot_path"] = File.join(run_root, "intake/contract-handoff.snapshot.yaml")
  data["mapping_basis"]["source_final_prd_path"] = File.join(prd_run_root, "prd", "prd-04.final_prd.yaml")
  data["mapping_basis"]["referenced_release_contracts"] = []
  data["resource_map"]["resources"] = [
    {
      "name" => "Account",
      "kind" => "entity",
      "ownership" => "foundation",
      "summary" => "Core access account",
      "shared_or_new" => "new",
      "related_views" => ["AccessList"],
    },
  ]
  data["action_map"]["actions"] = [
    {
      "name" => "listAccounts",
      "resource_name" => "Account",
      "action_type" => "query",
      "summary" => "List accounts",
      "related_views" => ["AccessList"],
    },
  ]
  data["consumer_view_map"]["views"] = [
    {
      "name" => "AccessList",
      "view_type" => "table",
      "goal" => "View access accounts",
      "primary_resources" => ["Account"],
      "primary_actions" => ["listAccounts"],
    },
  ]
  data["reference_plan"]["definitions_to_finalize_in_spec"] = ["Account list contract"]
  data["decision"]["allow_contract_spec"] = true
  data["decision"]["reason"] = "mapping ready"
  write_yaml(path, data)
end

def fill_contract_spec(path)
  data = load_yaml(path)
  data["spec_scope"]["summary"] = "Foundation access API contract"
  data["spec_scope"]["modules_in_scope"] = ["foundation-access"]
  data["spec_scope"]["resources_in_scope"] = ["Account"]
  data["spec_scope"]["actions_in_scope"] = ["listAccounts"]
  data["resource_contracts"]["resources"] = [
    {
      "name" => "Account",
      "purpose" => "Represent access account",
      "ownership" => "foundation",
      "fields" => ["id", "name"],
      "states" => ["active"],
      "constraints" => ["id required"],
      "references" => [],
    },
  ]
  data["consumer_views"]["views"] = [
    {
      "name" => "AccessList",
      "view_type" => "table",
      "goal" => "List accounts",
      "consumers" => ["admin-ui"],
      "required_resources" => ["Account"],
      "required_fields" => ["id", "name"],
      "required_actions" => ["listAccounts"],
    },
  ]
  data["query_and_command_semantics"]["queries"] = [
    {
      "name" => "listAccounts",
      "applies_to" => "Account",
      "inputs" => ["page", "page_size"],
      "behavior" => ["returns paginated accounts"],
    },
  ]
  data["api_surface"] = {
    "endpoints" => [
      {
        "operation_id" => "listAccounts",
        "method" => "GET",
        "path" => "/api/v1/accounts",
        "summary" => "List accounts",
        "tags" => ["foundation"],
        "request" => { "query" => [{ "name" => "page", "schema" => "integer" }] },
        "response" => { "status" => 200, "schema" => "AccountList" }
      }
    ]
  }
  data["access_and_tenant_rules"]["roles"] = ["admin"]
  data["validation_and_error_semantics"]["validations"] = ["page_size must be positive"]
  data["validation_and_error_semantics"]["error_cases"] = ["403 forbidden"]
  data["decision"]["allow_review"] = true
  data["decision"]["reason"] = "spec ready"
  write_yaml(path, data)
end

def approve_review(path, run_root)
  data = load_yaml(path)
  data["review_scope"]["handoff_snapshot_path"] = File.join(run_root, "intake/contract-handoff.snapshot.yaml")
  data["review_scope"]["scope_intake_path"] = File.join(run_root, "contract/working/contract-01.scope_intake.yaml")
  data["review_scope"]["domain_mapping_path"] = File.join(run_root, "contract/working/contract-02.domain_mapping.yaml")
  data["review_scope"]["checklist_path"] = File.join(ROOT, "docs/contract/reviewer/checklists/contract_spec_ready.md")
  data["decision"]["has_blocking_issue"] = false
  data["decision"]["allow_release"] = true
  data["decision"]["need_human_escalation"] = false
  data["decision"]["reason"] = "ready for release"
  data["notes"] = ["single flow release smoke"]
  write_yaml(path, data)
end

begin
  FileUtils.rm_rf(RUNS_ROOT)
  FileUtils.mkdir_p(RUNS_ROOT)
  FileUtils.cp_r(File.join(SOURCE_PRD_RUN, "."), prd_run_root)
  run!("ruby", "scripts/contract/init_flow_run.rb", handoff_path(1, "batch-foundation-access"))

  run_root = get_run_root("batch-foundation-access")
  run!("ruby", "scripts/contract/continue_run.rb", run_root, "batch-foundation-access", "contract-01")
  fill_scope_intake(File.join(run_root, "contract/working/contract-01.scope_intake.yaml"))
  scope_path = File.join(run_root, "contract/working/contract-01.scope_intake.yaml")
  scope_data = load_yaml(scope_path)
  scope_data["decision"]["allow_domain_mapping"] = false
  write_yaml(scope_path, scope_data)
  run_expect_failure!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-01")
  progress = File.read(File.join(run_root, "progress/workflow-progress.md"))
  assert(progress.include?("current_step_id: contract-01"), "Progress board should remain on contract-01 when gate is closed")
  scope_data["decision"]["allow_domain_mapping"] = true
  write_yaml(scope_path, scope_data)
  run!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-01")

  run_root = get_run_root("batch-foundation-access")
  run!("ruby", "scripts/contract/continue_run.rb", run_root, "batch-foundation-access", "contract-02")
  fill_domain_mapping(File.join(run_root, "contract/working/contract-02.domain_mapping.yaml"))
  run!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-02")

  run_root = get_run_root("batch-foundation-access")
  run!("ruby", "scripts/contract/continue_run.rb", run_root, "batch-foundation-access", "contract-03")
  fill_contract_spec(File.join(run_root, "contract/working/contract-03.contract_spec.yaml"))
  spec_path = File.join(run_root, "contract/working/contract-03.contract_spec.yaml")
  spec_data = load_yaml(spec_path)
  spec_data["meta"]["batch_id"] = "batch-account-access"
  spec_data["meta"]["contract_id"] = "batch-account-access"
  write_yaml(spec_path, spec_data)
  run_expect_failure!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-03", "--reviewer", "smoke-reviewer")
  spec_data["meta"]["batch_id"] = "batch-foundation-access"
  spec_data["meta"]["contract_id"] = "batch-foundation-access"
  write_yaml(spec_path, spec_data)
  run!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-03", "--reviewer", "smoke-reviewer")

  run_root = get_run_root("batch-foundation-access")
  review_path = File.join(run_root, "contract/working/contract-04.review.yaml")
  approve_review(review_path, run_root)
  review_data = load_yaml(review_path)
  review_data["meta"]["batch_id"] = "batch-account-access"
  review_data["meta"]["contract_id"] = "batch-account-access"
  write_yaml(review_path, review_data)
  run_expect_failure!("ruby", "scripts/contract/review_complete.rb", run_root, review_path)
  review_data["meta"]["batch_id"] = "batch-foundation-access"
  review_data["meta"]["contract_id"] = "batch-foundation-access"
  write_yaml(review_path, review_data)
  run!("ruby", "scripts/contract/review_complete.rb", run_root, review_path)

  run_root = get_run_root("batch-foundation-access")
  %w[openapi.yaml openapi.summary.md develop-handoff.md contract.yaml contract.summary.md].each do |filename|
    assert(File.exist?(File.join(run_root, "contract/release", filename)), "Expected release file not found: #{filename}")
  end

  progress = File.read(File.join(run_root, "progress/workflow-progress.md"))
  assert(progress.include?("overall_status: released"), "Progress board did not mark release as released")
  assert(progress.include?("next_expected_output: contract/release/develop-handoff.md"), "Progress board did not point to develop handoff")

  puts "==> Re-running handoff generation to pick up physical release dependency..."
  run!("ruby", "scripts/contract/generate_batch_handoffs.rb", "--force", prd_run_root, File.join(prd_run_root, "prd/prd-04.final_prd.yaml"))

  second_handoff_path = handoff_path(2, "batch-account-access")
  second_handoff = load_yaml(second_handoff_path)
  assert(second_handoff["status"] == "ready", "Second flow handoff did not unlock after first flow release (even after re-generation)")
  run!("ruby", "scripts/contract/init_flow_run.rb", second_handoff_path)

  run_root = get_run_root("batch-foundation-access")
  puts "==> Injecting mock develop verification artifact..."
  develop_dir = File.join(run_root, "develop")
  FileUtils.mkdir_p(develop_dir)
  File.write(File.join(develop_dir, "verification.md"), "# Mock Verification\nPassed.")

  puts "==> Testing baseline settlement..."
  run!("ruby", "scripts/contract/settle_baseline.rb", "batch-foundation-access")

  baseline_current = File.join(BASELINES_ROOT, "batch-foundation-access", "current")
  %w[openapi.yaml openapi.summary.md develop-verified-handoff.md implementation-settlement.md].each do |filename|
    assert(File.exist?(File.join(baseline_current, filename)), "Baseline file missing: #{filename}")
  end

  puts "Single-flow release smoke (Full Chain) passed."
ensure
  FileUtils.rm_rf(RUNS_ROOT)
end
