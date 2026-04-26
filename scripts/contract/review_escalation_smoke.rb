#!/usr/bin/env ruby
require "fileutils"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
SOURCE_PRD_RUN = File.join(ROOT, "runs", "2026-04-26-ai-init-prd-final")
RUNS_ROOT = File.join("/tmp", "contract-review-escalation-smoke")

def run!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system({ "CONTRACT_RUNS_ROOT" => RUNS_ROOT }, *cmd, chdir: ROOT)
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

def handoff_path
  File.join(prd_run_root, "contract_handoff", "flows", "01.batch-foundation-access.handoff.yaml")
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

def get_run_root(flow_id)
  Dir.glob(File.join(RUNS_ROOT, "*-contract-#{flow_id}")).first || File.join(RUNS_ROOT, "contract-#{flow_id}")
end

def fill_domain_mapping(path, run_root)
  data = load_yaml(path)
  data["mapping_basis"]["scope_intake_path"] = File.join(run_root, "contract/working/contract-01.scope_intake.yaml")
  data["mapping_basis"]["handoff_snapshot_path"] = File.join(run_root, "intake/contract-handoff.snapshot.yaml")
  data["mapping_basis"]["source_final_prd_path"] = File.join(prd_run_root, "prd", "prd-04.final_prd.yaml")
  data["mapping_basis"]["referenced_release_contracts"] = []
  data["resource_map"]["resources"] = [{ "name" => "Account", "kind" => "entity", "ownership" => "foundation", "summary" => "Core access account", "shared_or_new" => "new", "related_views" => ["AccessList"] }]
  data["action_map"]["actions"] = [{ "name" => "listAccounts", "resource_name" => "Account", "action_type" => "query", "summary" => "List accounts", "related_views" => ["AccessList"] }]
  data["consumer_view_map"]["views"] = [{ "name" => "AccessList", "view_type" => "table", "goal" => "View access accounts", "primary_resources" => ["Account"], "primary_actions" => ["listAccounts"] }]
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
  data["resource_contracts"]["resources"] = [{ "name" => "Account", "purpose" => "Represent access account", "ownership" => "foundation", "fields" => ["id", "name"], "states" => ["active"], "constraints" => ["id required"], "references" => [] }]
  data["consumer_views"]["views"] = [{ "name" => "AccessList", "view_type" => "table", "goal" => "List accounts", "consumers" => ["admin-ui"], "required_resources" => ["Account"], "required_fields" => ["id", "name"], "required_actions" => ["listAccounts"] }]
  data["query_and_command_semantics"]["queries"] = [{ "name" => "listAccounts", "applies_to" => "Account", "inputs" => ["page", "page_size"], "behavior" => ["returns paginated accounts"] }]
  data["api_surface"] = {
    "endpoints" => [
      {
        "operation_id" => "listAccounts",
        "method" => "GET",
        "path" => "/accounts",
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

def escalate_review(path, run_root)
  data = load_yaml(path)
  data["review_scope"]["handoff_snapshot_path"] = File.join(run_root, "intake/contract-handoff.snapshot.yaml")
  data["review_scope"]["scope_intake_path"] = File.join(run_root, "contract/working/contract-01.scope_intake.yaml")
  data["review_scope"]["domain_mapping_path"] = File.join(run_root, "contract/working/contract-02.domain_mapping.yaml")
  data["review_scope"]["checklist_path"] = File.join(ROOT, "docs/contract/reviewer/checklists/contract_spec_ready.md")
  data["decision"]["has_blocking_issue"] = false
  data["decision"]["allow_release"] = false
  data["decision"]["need_human_escalation"] = true
  data["decision"]["suggested_return_step"] = ""
  data["decision"]["reason"] = "Boundary conflict requires human decision"
  data["findings"]["issues"] = ["Boundary conflict needs human decision"]
  write_yaml(path, data)
end

begin
  FileUtils.rm_rf(RUNS_ROOT)
  FileUtils.mkdir_p(RUNS_ROOT)
  FileUtils.cp_r(File.join(SOURCE_PRD_RUN, "."), prd_run_root)
  run!("ruby", "scripts/contract/init_flow_run.rb", handoff_path)

  run_root = get_run_root("batch-foundation-access")
  run!("ruby", "scripts/contract/continue_run.rb", run_root, "batch-foundation-access", "contract-01")
  fill_scope_intake(File.join(run_root, "contract/working/contract-01.scope_intake.yaml"))
  run!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-01")

  run!("ruby", "scripts/contract/continue_run.rb", run_root, "batch-foundation-access", "contract-02")
  fill_domain_mapping(File.join(run_root, "contract/working/contract-02.domain_mapping.yaml"), run_root)
  run!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-02")

  run!("ruby", "scripts/contract/continue_run.rb", run_root, "batch-foundation-access", "contract-03")
  fill_contract_spec(File.join(run_root, "contract/working/contract-03.contract_spec.yaml"))
  run!("ruby", "scripts/contract/finalize_step.rb", run_root, "batch-foundation-access", "contract-03", "--reviewer", "smoke-reviewer")

  review_path = File.join(run_root, "contract/working/contract-04.review.yaml")
  escalate_review(review_path, run_root)
  run_expect_failure!("ruby", "scripts/contract/review_complete.rb", run_root, review_path)

  progress = File.read(File.join(run_root, "progress/workflow-progress.md"))
  assert(progress.include?("current_step_id: review.human_escalation"), "Progress board did not route to human escalation")
  assert(progress.include?("current_blocker: Reviewer requested human escalation"), "Progress board did not preserve escalation blocker")
  assert(progress.include?("next_agent_input: contract/working/contract-04.review.yaml"), "Progress board did not keep review file as escalation input")

  puts "Review escalation smoke passed."
ensure
  FileUtils.rm_rf(RUNS_ROOT)
end
