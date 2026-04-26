#!/usr/bin/env ruby
require_relative "artifact_utils"
require_relative "workflow_manifest"
require_relative "progress_board"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/contract/finalize_step.rb <run_dir> <flow_id> <#{ContractFlow::WorkflowManifest.continue_usage}> [--force-review] [--reviewer <name>]"
  exit 1
end

run_dir = ARGV[0]
flow_id = ARGV[1]
step_id = ARGV[2]
remaining = ARGV.drop(3)
usage if run_dir.to_s.strip.empty? || flow_id.to_s.strip.empty? || step_id.to_s.strip.empty?

force_review = false
reviewer = nil

while remaining.any?
  token = remaining.shift
  case token
  when "--force-review"
    force_review = true
  when "--reviewer"
    reviewer = remaining.shift
  else
    usage
  end
end

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

manifest_flow_id = ContractFlow::WorkflowManifest.manifest_flow_id(run_root)
if manifest_flow_id && manifest_flow_id != flow_id
  warn "Run directory flow_id (#{manifest_flow_id}) does not match argument flow_id (#{flow_id})"
  exit 2
end

if !manifest_flow_id && File.basename(run_root) != "contract-#{flow_id}"
  warn "Legacy run directory does not match flow_id #{flow_id}"
  exit 2
end

step = ContractFlow::WorkflowManifest.step_for(step_id)
usage unless step

validate_cmd = [
  "ruby",
  "scripts/contract/validate_artifact.rb",
  step.fetch("artifact"),
  ContractFlow::WorkflowManifest.artifact_path(step_id, run_root),
]
puts "$ #{validate_cmd.join(' ')}"
success = system(*validate_cmd, chdir: ROOT)
exit(Process.last_status&.exitstatus || 1) unless success

artifact_path = ContractFlow::WorkflowManifest.artifact_path(step_id, run_root)
artifact_data = Contract::ArtifactUtils.load_yaml(artifact_path)
unless Contract::ArtifactUtils.decision_allows_next_step?(step.fetch("artifact"), artifact_data)
  gate_key = Contract::ArtifactUtils.decision_gate_for(step.fetch("artifact"))
  warn "Cannot finalize #{step.fetch('artifact')} until decision.#{gate_key}=true"
  exit 2
end

render_cmd = [
  "ruby",
  "scripts/contract/render_artifact.rb",
  step.fetch("artifact"),
  artifact_path,
  ContractFlow::WorkflowManifest.render_path(step_id, run_root),
]

commands = []

if step.fetch("review_step")
  if reviewer.to_s.strip.empty?
    warn "--reviewer is required when finalizing a review-gated contract step"
    exit 1
  end

  review_cmd = ["ruby", "scripts/contract/init_review_context.rb"]
  review_cmd << "--force" if force_review
  review_cmd.concat([
    "--step", step.fetch("review_step"),
    "--step-id", "contract-04",
    "--contract-id", flow_id,
    "--batch-id", flow_id,
    "--subject", artifact_path,
    "--reviewer", reviewer,
    ContractFlow::WorkflowManifest.review_path(run_root),
  ])
  commands << review_cmd
end

commands << render_cmd

commands.each do |cmd|
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  exit(Process.last_status&.exitstatus || 1) unless success
end

ContractFlow::ProgressBoard.update_for_finalize(
  run_root: run_root,
  step_id: step_id
)

puts "Validated #{step.fetch('artifact')} at #{ContractFlow::WorkflowManifest.artifact_path(step_id, run_root)}."
if step.fetch("review_step")
  puts "Prepared reviewer context at #{ContractFlow::WorkflowManifest.review_path(run_root)}."
  puts "Reviewer materials snapshot at #{ContractFlow::WorkflowManifest.review_materials_path(run_root)}."
end
puts "Rendered markdown at #{ContractFlow::WorkflowManifest.render_path(step_id, run_root)}."
