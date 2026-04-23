#!/usr/bin/env ruby
require_relative "../progress_board"
require_relative "artifact_utils"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/prd/review_complete.rb <run_dir> <review.yml>"
  exit 1
end

def progress_path_for(run_root)
  File.join(run_root, "progress/workflow-progress.md")
end

def validate_yaml_artifact(type, path)
  data = Prd::ArtifactUtils.load_yaml(path)
  errors = Prd::ArtifactUtils.validate_artifact(type, data, artifact_path: path)
  unless errors.empty?
    warn "Validation failed for #{path}"
    errors.each { |error| warn "- #{error}" }
    exit 2
  end
  data
end

def update_progress(run_root, step_id, review_data, subject_data)
  progress_path = progress_path_for(run_root)
  return unless File.exist?(progress_path)

  board = WorkflowProgressBoard::Board.new(progress_path)
  step = PrdFlow::WorkflowManifest.step_for(step_id)
  next_step = PrdFlow::WorkflowManifest.next_step_id(step_id) || "contract"

  has_blocking = review_data.dig("decision", "has_blocking_issue") == true
  allow_next = review_data.dig("decision", "allow_next_step") == true
  escalate = review_data.dig("decision", "need_human_escalation") == true
  artifact = step&.fetch("artifact")

  if allow_next
    if artifact == "clarification"
      board.update_row(step_id, status: "review", output: PrdFlow::WorkflowManifest.artifact_relative_path(step_id), reviewer: PrdFlow::WorkflowManifest.review_relative_path(step_id), human_confirmation: "required", next_step: next_step)
      board.set_meta("current_step_id", "#{step_id}.human_confirmation")
      board.set_meta("overall_status", "blocked")
      board.set_meta("current_goal", "Complete Human Confirmation Gate for #{step_id} before #{next_step}")
      board.set_meta("current_blocker", "Awaiting human confirmation")
      board.set_meta("next_agent_input", PrdFlow::WorkflowManifest.render_relative_path(step_id))
      board.set_meta("next_expected_output", PrdFlow::WorkflowManifest.artifact_relative_path(step_id))
    else
      row_status = PrdFlow::WorkflowManifest.completion_status_for(step_id, subject_data)
      board.update_row(step_id, status: row_status, output: PrdFlow::WorkflowManifest.artifact_relative_path(step_id), reviewer: PrdFlow::WorkflowManifest.review_relative_path(step_id), next_step: next_step)
      board.set_meta("current_step_id", next_step)
      board.set_meta("overall_status", "doing")
      board.set_meta("current_goal", next_step == "contract" ? "Prepare contract design from final_prd handoff" : "Proceed to #{next_step}")
      board.set_meta("current_blocker", "")
      board.set_meta("next_agent_input", next_step == "contract" ? PrdFlow::WorkflowManifest.artifact_relative_path(step_id) : PrdFlow::WorkflowManifest.artifact_relative_path(next_step))
      board.set_meta("next_expected_output", next_step == "contract" ? "contract" : PrdFlow::WorkflowManifest.artifact_relative_path(next_step))
    end
  else
    board.update_row(step_id, status: "blocked", output: PrdFlow::WorkflowManifest.artifact_relative_path(step_id), reviewer: PrdFlow::WorkflowManifest.review_relative_path(step_id))
    board.set_meta("current_step_id", "#{step_id}.blocked")
    board.set_meta("overall_status", "blocked")
    board.set_meta("current_goal", "Resolve reviewer findings for #{step_id}")
    blocker =
      if escalate
        "Reviewer requested human escalation"
      elsif has_blocking
        "Reviewer found blocking issues"
      else
        "Reviewer did not allow the next step"
      end
    board.set_meta("current_blocker", blocker)
    board.set_meta("next_agent_input", PrdFlow::WorkflowManifest.review_relative_path(step_id))
    board.set_meta("next_expected_output", PrdFlow::WorkflowManifest.artifact_relative_path(step_id))
  end

  board.save
end

run_dir = ARGV[0]
review_path_arg = ARGV[1]
usage if run_dir.to_s.strip.empty? || review_path_arg.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

review_path = File.expand_path(review_path_arg, ROOT)
unless File.exist?(review_path)
  warn "Review file not found: #{review_path}"
  exit 1
end

review_data = validate_yaml_artifact("review", review_path)
review_step = review_data.dig("status", "step")
step = PrdFlow::WorkflowManifest.step_for_review_step(review_step)
unless step
  warn "Unknown review step: #{review_step}"
  exit 1
end

subject_path = review_data.dig("meta", "subject_path")
subject_path = File.expand_path(subject_path, File.dirname(review_path))
unless File.exist?(subject_path)
  warn "Subject file not found: #{subject_path}"
  exit 1
end

subject_type = step.fetch("artifact")
expected_subject_path = PrdFlow::WorkflowManifest.artifact_path(step.fetch("step_id"), run_root)
if expected_subject_path && File.exist?(expected_subject_path) && File.expand_path(subject_path) != File.expand_path(expected_subject_path)
  warn "Review subject_path points outside the current run; using #{expected_subject_path} instead"
  subject_path = expected_subject_path
end

subject_data = validate_yaml_artifact(subject_type, subject_path)

update_progress(run_root, step.fetch("step_id"), review_data, subject_data)

if review_data.dig("decision", "allow_next_step") == true
  next_step = PrdFlow::WorkflowManifest.next_step_id(step.fetch("step_id")) || "contract"
  puts "Review passed for #{step.fetch('step_id')}."
  if step.fetch("artifact") == "clarification"
    puts "Next step: Human Confirmation Gate before #{next_step}"
  else
    puts "Next step: #{next_step}"
  end
else
  puts "Review blocked #{step.fetch('step_id')}."
  puts "Check #{review_path} and update #{subject_path} before retrying."
end
