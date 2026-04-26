#!/usr/bin/env ruby
require "fileutils"
require "time"
require "yaml"
require "digest"

require_relative "artifact_utils"
require_relative "workflow_manifest"
require_relative "progress_board"
require_relative "execution_summary"

ROOT = File.expand_path("../..", __dir__)

def normalized(path)
  File.expand_path(path)
end

def expected_subject_paths(run_dir)
  return [] if run_dir.to_s.strip.empty?

  [
    ContractFlow::WorkflowManifest.artifact_path("contract-03", run_dir),
  ].map { |path| normalized(path) }.uniq
end

def usage
  warn "Usage: ruby scripts/contract/review_complete.rb <run_dir> <review.yml>"
  exit 1
end

run_dir = ARGV[0]
review_path = ARGV[1]
usage if run_dir.to_s.strip.empty? || review_path.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

review_path = File.expand_path(review_path, ROOT)
unless File.exist?(review_path)
  warn "Review file not found: #{review_path}"
  exit 1
end

review_data = Contract::ArtifactUtils.load_yaml(review_path)
review_errors = Contract::ArtifactUtils.validate_artifact("review", review_data, artifact_path: review_path)
unless review_errors.empty?
  warn "Validation failed for #{review_path}"
  review_errors.each { |error| warn "- #{error}" }
  exit 2
end

subject_path = review_data.dig("meta", "subject_path")
subject_path = Contract::ArtifactUtils.expanded_path(subject_path, review_path)
unless subject_path && File.exist?(subject_path)
  warn "Subject file not found: #{subject_path}"
  exit 2
end

flow_id = review_data.dig("meta", "batch_id").to_s
if flow_id.empty?
  warn "Review meta.batch_id is required"
  exit 2
end

expected_review_path = normalized(ContractFlow::WorkflowManifest.review_path(run_root))
actual_review_path = normalized(review_path)
if actual_review_path != expected_review_path
  warn "Review path does not match the current run for flow #{flow_id}"
  warn "- expected: #{expected_review_path}"
  warn "- actual: #{actual_review_path}"
  exit 2
end

expected_paths = expected_subject_paths(run_dir).select { |path| File.exist?(path) }
subject_path = normalized(subject_path)
if !expected_paths.empty? && !expected_paths.include?(subject_path)
  warn "Review subject_path does not match the current run for flow #{flow_id}"
  expected_paths.each { |path| warn "- expected: #{path}" }
  warn "- actual: #{subject_path}"
  exit 2
end

subject_data = Contract::ArtifactUtils.load_yaml(subject_path)
subject_errors = Contract::ArtifactUtils.validate_artifact("contract_spec", subject_data, artifact_path: subject_path)
unless subject_errors.empty?
  warn "Validation failed for #{subject_path}"
  subject_errors.each { |error| warn "- #{error}" }
  exit 2
end

run_manifest = Contract::ArtifactUtils.load_yaml(ContractFlow::WorkflowManifest.run_manifest_path(run_root))
handoff_snapshot = Contract::ArtifactUtils.load_yaml(ContractFlow::WorkflowManifest.handoff_snapshot_yaml_path(run_root))
expected_flow_id = run_manifest["flow_id"].to_s
handoff_flow_id = handoff_snapshot["flow_id"].to_s
if expected_flow_id.empty? || handoff_flow_id.empty? || expected_flow_id != handoff_flow_id
  warn "Run flow binding is invalid for #{run_root}"
  exit 2
end

if review_data.dig("meta", "batch_id").to_s != expected_flow_id
  warn "Review meta.batch_id does not match the current run flow"
  warn "- expected: #{expected_flow_id}"
  warn "- actual: #{review_data.dig('meta', 'batch_id')}"
  exit 2
end

if subject_data.dig("meta", "batch_id").to_s != expected_flow_id
  warn "Review subject batch_id does not match the current run flow"
  warn "- expected: #{expected_flow_id}"
  warn "- actual: #{subject_data.dig('meta', 'batch_id')}"
  exit 2
end

review_passed = review_data.dig("decision", "allow_release") == true
has_blocking = review_data.dig("decision", "has_blocking_issue") == true
need_human_escalation = review_data.dig("decision", "need_human_escalation") == true
return_step = review_data.dig("decision", "suggested_return_step").to_s
state_path = ContractFlow::WorkflowManifest.review_result_path(run_root)
FileUtils.mkdir_p(File.dirname(state_path))

flow_id = expected_flow_id
snapshot = {
  "flow_id" => "contract",
  "step_id" => "contract-04",
  "status" => review_passed ? "releasing" : "blocked",
  "batch_id" => flow_id,
  "contract_id" => review_data.dig("meta", "contract_id"),
  "run_id" => File.basename(run_root),
  "review_path" => actual_review_path,
  "subject_path" => subject_path,
  "review_sha256" => Digest::SHA256.file(actual_review_path).hexdigest,
  "subject_sha256" => Digest::SHA256.file(subject_path).hexdigest,
  "rendered_subject_path" => ContractFlow::WorkflowManifest.render_path("contract-03", run_root),
  "rendered_review_path" => ContractFlow::WorkflowManifest.render_path("contract-04", run_root),
  "reviewed_at" => Time.now.utc.iso8601,
}

if review_passed
  snapshot["next_action"] = "build_release"
  snapshot["next_command"] = ["ruby", "scripts/contract/build_release.rb", run_root]
  File.write(state_path, YAML.dump(snapshot))

  render_command = [
    "ruby",
    "scripts/contract/render_artifact.rb",
    "review",
    actual_review_path,
    ContractFlow::WorkflowManifest.render_path("contract-04", run_root),
  ]
  puts "$ #{render_command.join(' ')}"
  system(*render_command, chdir: ROOT)

  release_command = ["ruby", "scripts/contract/build_release.rb", run_root]
  success = system(*release_command, chdir: ROOT)
  exit(Process.last_status&.exitstatus || 1) unless success
  snapshot["status"] = "passed"
  snapshot["released_at"] = Time.now.utc.iso8601
  snapshot["next_action"] = "release_ready"
  snapshot["next_command"] = nil
  File.write(state_path, YAML.dump(snapshot))
  ContractFlow::ProgressBoard.update_for_review_complete(
    run_root: run_root,
    review_passed: true,
    has_blocking: has_blocking,
    return_step: return_step,
    review_result_path: state_path
  )
  ContractFlow::ProgressBoard.mark_release_ready!(run_root)
  summary_path = ContractFlow::ExecutionSummary.write_review_complete_summary(
    run_root: run_root,
    flow_id: flow_id,
    review_passed: true,
    review_path: actual_review_path,
    state_path: state_path,
    return_step: return_step
  )
  puts "Review passed for #{subject_path}."
  puts "Next step: release package built under #{ContractFlow::WorkflowManifest.release_dir_path(run_root)}"
  puts "State snapshot: #{state_path}"
  puts "Execution summary: #{summary_path}"
  exit 0
end

snapshot["next_action"] = return_step.empty? ? "contract_spec" : return_step
snapshot["has_blocking_issue"] = has_blocking
snapshot["need_human_escalation"] = need_human_escalation
snapshot["next_command"] = nil
File.write(state_path, YAML.dump(snapshot))
ContractFlow::ProgressBoard.update_for_review_complete(
  run_root: run_root,
  review_passed: false,
  has_blocking: has_blocking,
  need_human_escalation: need_human_escalation,
  return_step: return_step,
  review_result_path: state_path
)
summary_path = ContractFlow::ExecutionSummary.write_review_complete_summary(
  run_root: run_root,
  flow_id: flow_id,
  review_passed: false,
  review_path: actual_review_path,
  state_path: state_path,
  return_step: return_step
)
puts "Review blocked #{subject_path}."
if has_blocking
  puts "Blocking issues present."
end
puts "Suggested return step: #{return_step.empty? ? 'contract_spec' : return_step}"
puts "Human escalation required." if need_human_escalation
puts "State snapshot: #{state_path}"
puts "Execution summary: #{summary_path}"
exit 2
