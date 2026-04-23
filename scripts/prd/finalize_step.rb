#!/usr/bin/env ruby
require_relative "../progress_board"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/prd/finalize_step.rb <run_dir> <#{PrdFlow::WorkflowManifest.continue_usage}> [--force-review]"
  exit 1
end

def progress_path_for(run_root)
  File.join(run_root, "progress/workflow-progress.md")
end

def update_progress(run_root, step_id)
  progress_path = progress_path_for(run_root)
  return unless File.exist?(progress_path)

  board = WorkflowProgressBoard::Board.new(progress_path)
  step = PrdFlow::WorkflowManifest.step_for(step_id)
  next_step = PrdFlow::WorkflowManifest.next_step_id(step_id) || "contract"
  return unless step

  board.update_row(step_id, status: "review", output: step.fetch("artifact_relative_path"), reviewer: step.fetch("review_relative_path"), next_step: next_step)
  board.set_meta("current_step_id", "#{step_id}.review")
  board.set_meta("overall_status", "review")
  board.set_meta("current_goal", "Review #{step.fetch('artifact')} and use the rendered markdown for the next decision")
  board.set_meta("current_blocker", "Awaiting independent reviewer decision")
  board.set_meta("next_agent_input", step.fetch("render_relative_path"))
  board.set_meta("next_expected_output", step.fetch("review_relative_path"))
  board.save
end

run_dir = ARGV[0]
step_id = ARGV[1]
remaining = ARGV.drop(2)
usage if run_dir.to_s.strip.empty? || step_id.to_s.strip.empty?

force_review = remaining.delete("--force-review")
usage unless remaining.empty?

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

step = PrdFlow::WorkflowManifest.step_for(step_id)
usage unless step

validate_cmd = ["ruby", "scripts/prd/validate_artifact.rb", step.fetch("artifact"), PrdFlow::WorkflowManifest.artifact_path(step_id, run_root)]
review_cmd = ["ruby", "scripts/prd/init_review_context.rb"]
review_cmd << "--force" if force_review
review_cmd.concat(["--step", step.fetch("review_step"), "--step-id", step.fetch("step_id"), "--subject", PrdFlow::WorkflowManifest.artifact_path(step_id, run_root), PrdFlow::WorkflowManifest.review_path(step_id, run_root)])
render_cmd = ["ruby", "scripts/prd/render_artifact.rb", step.fetch("artifact"), PrdFlow::WorkflowManifest.artifact_path(step_id, run_root), PrdFlow::WorkflowManifest.render_path(step_id, run_root)]

[validate_cmd, review_cmd, render_cmd].each do |cmd|
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  exit(Process.last_status&.exitstatus || 1) unless success
end

update_progress(run_root, step_id)
puts "Validated #{step.fetch('artifact')} at #{PrdFlow::WorkflowManifest.artifact_path(step_id, run_root)}."
puts "Prepared reviewer context at #{PrdFlow::WorkflowManifest.review_path(step_id, run_root)}."
puts "Rendered markdown at #{PrdFlow::WorkflowManifest.render_path(step_id, run_root)}."
