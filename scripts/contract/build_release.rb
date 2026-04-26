#!/usr/bin/env ruby
require "fileutils"
require "time"
require "yaml"
require "digest"

require_relative "artifact_utils"
require_relative "handoff_generation"
require_relative "workflow_manifest"
require_relative "progress_board"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/contract/build_release.rb <run_dir>"
  exit 1
end

def present?(value)
  !value.nil? && !(value.respond_to?(:empty?) && value.empty?) && value.to_s.strip != ""
end

run_dir = ARGV[0]
usage if run_dir.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

handoff_path = ContractFlow::WorkflowManifest.handoff_snapshot_yaml_path(run_root)
spec_path = ContractFlow::WorkflowManifest.artifact_path("contract-03", run_root)
review_path = ContractFlow::WorkflowManifest.review_path(run_root)
run_manifest_path = ContractFlow::WorkflowManifest.run_manifest_path(run_root)
review_result_path = ContractFlow::WorkflowManifest.review_result_path(run_root)

[handoff_path, spec_path, review_path, run_manifest_path, review_result_path].each do |path|
  unless File.exist?(path)
    warn "Required file not found: #{path}"
    exit 1
  end
end

handoff = Contract::ArtifactUtils.load_yaml(handoff_path)
spec = Contract::ArtifactUtils.load_yaml(spec_path)
review = Contract::ArtifactUtils.load_yaml(review_path)
run_manifest = Contract::ArtifactUtils.load_yaml(run_manifest_path)
review_result = Contract::ArtifactUtils.load_yaml(review_result_path)

spec_errors = Contract::ArtifactUtils.validate_artifact("contract_spec", spec, artifact_path: spec_path)
unless spec_errors.empty?
  warn "Validation failed for #{spec_path}"
  spec_errors.each { |error| warn "- #{error}" }
  exit 2
end

review_errors = Contract::ArtifactUtils.validate_artifact("review", review, artifact_path: review_path)
unless review_errors.empty?
  warn "Validation failed for #{review_path}"
  review_errors.each { |error| warn "- #{error}" }
  exit 2
end

run_flow_id = run_manifest["flow_id"].to_s
handoff_flow_id = handoff["flow_id"].to_s
if run_flow_id.empty? || handoff_flow_id.empty? || run_flow_id != handoff_flow_id
  warn "Run flow binding is invalid for #{run_root}"
  exit 2
end

unless review.dig("decision", "allow_release") == true
  warn "Review does not allow release: #{review_path}"
  exit 2
end

unless %w[releasing passed].include?(review_result["status"].to_s)
  warn "Review result is not ready for release: #{review_result_path}"
  exit 2
end

subject_path = Contract::ArtifactUtils.expanded_path(review.dig("meta", "subject_path"), review_path)
unless subject_path && File.expand_path(subject_path) == File.expand_path(spec_path)
  warn "Review subject_path does not match the current run contract spec"
  warn "- expected: #{spec_path}"
  warn "- actual: #{subject_path}"
  exit 2
end

flow_id = handoff_flow_id
if review.dig("meta", "batch_id").to_s != flow_id || review.dig("meta", "contract_id").to_s != flow_id
  warn "Review meta flow binding does not match the current run"
  exit 2
end

if spec.dig("meta", "batch_id").to_s != flow_id || spec.dig("meta", "contract_id").to_s != flow_id
  warn "Contract spec flow binding does not match the current run"
  exit 2
end

if File.expand_path(review_result["review_path"].to_s, run_root) != File.expand_path(review_path)
  warn "Review result review_path does not match the current run review artifact"
  exit 2
end

if File.expand_path(review_result["subject_path"].to_s, run_root) != File.expand_path(spec_path)
  warn "Review result subject_path does not match the current run contract spec"
  exit 2
end

review_sha256 = Digest::SHA256.file(review_path).hexdigest
spec_sha256 = Digest::SHA256.file(spec_path).hexdigest
if review_result["review_sha256"].to_s != review_sha256
  warn "Review artifact has changed since it was sealed for release"
  exit 2
end

if review_result["subject_sha256"].to_s != spec_sha256
  warn "Contract spec has changed since review approval"
  exit 2
end

release_dir = ContractFlow::WorkflowManifest.release_dir_path(run_root)
staging_dir = File.join(File.dirname(release_dir), ".release-staging")
backup_dir = File.join(File.dirname(release_dir), ".release-backup")
FileUtils.rm_rf(staging_dir)
FileUtils.rm_rf(backup_dir)
FileUtils.mkdir_p(staging_dir)

resources = Array(spec.dig("resource_contracts", "resources")).map { |item| item["name"].to_s.strip }.reject(&:empty?)
views = Array(spec.dig("consumer_views", "views")).map { |item| item["name"].to_s.strip }.reject(&:empty?)
summary_text = Array(spec.dig("spec_scope", "summary")).join("\n")
summary_text = spec.dig("spec_scope", "summary").to_s if summary_text.empty?

# 1. contract.yaml (copy of spec)
staged_contract_path = File.join(staging_dir, "contract.yaml")
FileUtils.cp(spec_path, staged_contract_path)

# 2. openapi.yaml
endpoints = Array(spec.dig("api_surface", "endpoints"))
if endpoints.empty?
  warn "api_surface.endpoints is empty; cannot build a valid OpenAPI"
  exit 2
end

paths = {}
schemas = {}

endpoints.each do |ep|
  path = ep["path"].to_s
  method = ep["method"].to_s.downcase
  next if path.empty? || method.empty?

  paths[path] ||= {}
  op = {
    "operationId" => ep["operation_id"],
    "summary" => ep["summary"],
    "tags" => Array(ep["tags"]),
    "responses" => {}
  }

  res = ep["response"]
  if res.is_a?(Hash)
    status = res["status"].to_s
    schema_name = res["schema"].to_s
    op["responses"][status] = {
      "description" => "Successful response",
      "content" => {
        "application/json" => {
          "schema" => { "$ref" => "#/components/schemas/#{schema_name}" }
        }
      }
    }
    schemas[schema_name] ||= { "type" => "object", "properties" => {} }
  end

  if Array(ep.dig("request", "query")).any?
    op["parameters"] = ep.dig("request", "query").map do |q|
      {
        "name" => q["name"],
        "in" => "query",
        "required" => true,
        "schema" => { "type" => q["schema"] || "string" }
      }
    end
  end

  if present?(ep.dig("request", "body"))
    body_schema = ep.dig("request", "body").to_s
    op["requestBody"] = {
      "content" => {
        "application/json" => {
          "schema" => { "$ref" => "#/components/schemas/#{body_schema}" }
        }
      }
    }
    schemas[body_schema] ||= { "type" => "object", "properties" => {} }
  end

  paths[path][method] = op
end

resources.each { |r| schemas[r] ||= { "type" => "object", "properties" => {} } }

openapi = {
  "openapi" => "3.1.0",
  "info" => {
    "title" => present?(handoff["flow_title"]) ? handoff["flow_title"] : flow_id,
    "version" => "0.1.0",
    "summary" => summary_text,
  },
  "tags" => resources.map { |name| { "name" => name } },
  "paths" => paths,
  "components" => { "schemas" => schemas },
  "x-contract-run" => {
    "run_id" => File.basename(run_root),
    "flow_id" => flow_id,
    "source_handoff" => ContractFlow::WorkflowManifest.handoff_snapshot_yaml_relative_path,
    "source_contract_spec" => ContractFlow::WorkflowManifest.artifact_relative_path("contract-03"),
    "source_review" => ContractFlow::WorkflowManifest.review_relative_path,
  },
}

staged_openapi_path = File.join(staging_dir, "openapi.yaml")
File.write(staged_openapi_path, YAML.dump(openapi))

# 3. contract.summary.md
staged_contract_summary_path = File.join(staging_dir, "contract.summary.md")
contract_summary_lines = [
  "# Contract Summary: #{flow_id}",
  "",
  "- Title: #{handoff['flow_title']}",
  "- Scope: #{summary_text}",
  "",
  "## API Endpoints",
  "",
]
endpoints.each do |ep|
  contract_summary_lines << "- `#{ep['method'].to_s.upcase} #{ep['path']}`: #{ep['summary']} (#{ep['operation_id']})"
end
File.write(staged_contract_summary_path, contract_summary_lines.join("\n") + "\n")

# 4. openapi.summary.md
staged_openapi_summary_path = File.join(staging_dir, "openapi.summary.md")
summary_lines = [
  "# OpenAPI Summary",
  "",
  "- Flow Id: `#{flow_id}`",
  "- Run Id: `#{File.basename(run_root)}`",
  "- Source Handoff: `#{ContractFlow::WorkflowManifest.handoff_snapshot_yaml_relative_path}`",
  "- Source Contract Spec: `#{ContractFlow::WorkflowManifest.artifact_relative_path('contract-03')}`",
  "- Review Gate: `#{ContractFlow::WorkflowManifest.review_relative_path}`",
  "",
  "## API Surface",
  "",
]
endpoints.each { |ep| summary_lines << "- `#{ep['method'].to_s.upcase} #{ep['path']}` -> `#{ep['operation_id']}`" }
summary_lines << ""
summary_lines << "## Release Boundary"
summary_lines << ""
summary_lines << "- `contract/working/` contains draft artifacts and rendered working notes."
summary_lines << "- `contract/release/` is the formal downstream package."

File.write(staged_openapi_summary_path, summary_lines.join("\n") + "\n")

# 5. develop-handoff.md
staged_develop_handoff_path = File.join(staging_dir, "develop-handoff.md")
develop_lines = [
  "# Develop Handoff",
  "",
  "- Flow Id: `#{flow_id}`",
  "- Formal Input Root: `#{ContractFlow::WorkflowManifest.release_dir_relative_path}`",
  "- Consume `contract.yaml`, `contract.summary.md`, `openapi.yaml`, `openapi.summary.md`, and this handoff file from `contract/release/`.",
  "- Do not consume draft files under `contract/working/` as the formal implementation input.",
  "",
  "## Upstream Snapshots",
  "",
  "- Intake Handoff: `#{ContractFlow::WorkflowManifest.handoff_snapshot_yaml_relative_path}`",
  "- Contract Spec: `#{ContractFlow::WorkflowManifest.artifact_relative_path('contract-03')}`",
  "- Review Result: `#{ContractFlow::WorkflowManifest.review_relative_path}`",
  "",
  "## Current Notes",
  "",
]
develop_lines.concat(Array(review["notes"]).map { |item| "- #{item}" })
develop_lines << "- No additional reviewer notes." if Array(review["notes"]).empty?

File.write(staged_develop_handoff_path, develop_lines.join("\n") + "\n")

# Apply release
begin
  FileUtils.mv(release_dir, backup_dir) if Dir.exist?(release_dir)
  FileUtils.mv(staging_dir, release_dir)

  # REMOVED: ContractFlow::HandoffGeneration.advance_after_release!(prd_run_root: source_prd_run_root, released_flow_id: flow_id)
  # Downstream will check the physical presence of released output.

  review_result["status"] = "passed"
  review_result["released_at"] = Time.now.utc.iso8601
  review_result["next_action"] = "release_ready"
  review_result["next_command"] = nil
  File.write(review_result_path, YAML.dump(review_result))
  FileUtils.rm_rf(backup_dir)
  ContractFlow::ProgressBoard.mark_release_ready!(run_root)
rescue StandardError => e
  FileUtils.rm_rf(staging_dir)
  FileUtils.rm_rf(release_dir)
  FileUtils.mv(backup_dir, release_dir) if Dir.exist?(backup_dir)
  warn "Failed to build release package: #{e.message}"
  exit 1
end

puts "Built release package at #{release_dir}"
puts "Formal outputs:"
ContractFlow::WorkflowManifest.release_files_paths(run_root).each { |path| puts "- #{path}" }
