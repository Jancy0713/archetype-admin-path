#!/usr/bin/env ruby
require "time"
require "yaml"

require_relative "../progress_board"
require_relative "artifact_utils"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/prd/confirm_clarification.rb <run_dir> <clarification.yml> --summary <text> [--confirmed-by <name>] [--confirmed-at <iso8601>]"
  exit 1
end

def progress_path_for(run_root)
  File.join(run_root, "progress/workflow-progress.md")
end

def update_progress(run_root, clarification_path, allow_execution_plan)
  progress_path = progress_path_for(run_root)
  return unless File.exist?(progress_path)

  step_id = "prd-02"
  next_step = PrdFlow::WorkflowManifest.next_step_id(step_id) || "contract"
  board = WorkflowProgressBoard::Board.new(progress_path)

  if allow_execution_plan
    board.update_row(step_id, status: "confirmed", output: "prd/prd-02.clarification.yaml", reviewer: "prd/prd-02.review.yaml", human_confirmation: "confirmed", next_step: next_step)
    board.set_meta("current_step_id", next_step)
    board.set_meta("overall_status", "doing")
    board.set_meta("current_goal", "Proceed to #{next_step}")
    board.set_meta("current_blocker", "")
    board.set_meta("next_agent_input", "prd/prd-02.clarification.yaml")
    board.set_meta("next_expected_output", PrdFlow::WorkflowManifest.artifact_relative_path(next_step))
  else
    board.update_row(step_id, status: "blocked", output: "prd/prd-02.clarification.yaml", reviewer: "prd/prd-02.review.yaml", human_confirmation: "confirmed", next_step: next_step)
    board.set_meta("current_step_id", "prd-02.blocked")
    board.set_meta("overall_status", "blocked")
    board.set_meta("current_goal", "Resolve remaining clarification blockers before execution_plan")
    board.set_meta("current_blocker", "Human confirmation completed but required clarification items are still unresolved")
    board.set_meta("next_agent_input", "prd/prd-02.clarification.yaml")
    board.set_meta("next_expected_output", "prd/prd-02.clarification.yaml")
  end

  board.save
end

run_dir = ARGV[0]
clarification_arg = ARGV[1]
remaining = ARGV.drop(2)
usage if run_dir.to_s.strip.empty? || clarification_arg.to_s.strip.empty?

summary = nil
confirmed_by = nil
confirmed_at = Time.now.utc.iso8601

while remaining.any?
  token = remaining.shift
  case token
  when "--summary"
    summary = remaining.shift
  when "--confirmed-by"
    confirmed_by = remaining.shift
  when "--confirmed-at"
    confirmed_at = remaining.shift
  else
    usage
  end
end

usage if summary.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

clarification_path = File.expand_path(clarification_arg, ROOT)
unless File.exist?(clarification_path)
  warn "Clarification file not found: #{clarification_path}"
  exit 1
end

data = Prd::ArtifactUtils.load_yaml(clarification_path)
unless data["artifact_type"] == "clarification"
  warn "Expected a clarification artifact: #{clarification_path}"
  exit 1
end

data["human_confirmation"]["required"] = true if data["human_confirmation"].is_a?(Hash)
data["human_confirmation"]["confirmed"] = true
data["human_confirmation"]["summary"] = summary
data["human_confirmation"]["confirmed_by"] = confirmed_by.to_s
data["human_confirmation"]["confirmed_at"] = confirmed_at

required_items = Array(data["confirmation_items"]).select do |item|
  item.is_a?(Hash) && item["level"] == "required"
end
resolved_item_ids = Array(data["clarified_decisions"]).map { |item| item["item_id"].to_s.strip }.reject(&:empty?)
unresolved_required_ids = required_items.each_with_object([]) do |item, acc|
  item_id = item["item_id"].to_s.strip
  next if item_id.empty? || resolved_item_ids.include?(item_id)

  acc << item_id
end

allow_execution_plan = unresolved_required_ids.empty?

data["decision"]["allow_execution_plan"] = allow_execution_plan
data["decision"]["reason"] =
  if allow_execution_plan
    "Human confirmation completed and all required clarification items are resolved."
  else
    "Human confirmation completed, but required clarification items are still unresolved: #{unresolved_required_ids.join(', ')}."
  end
data["status"]["ready_for_next"] = allow_execution_plan

File.write(clarification_path, YAML.dump(data))

errors = Prd::ArtifactUtils.validate_artifact("clarification", data, artifact_path: clarification_path)
unless errors.empty?
  warn "Validation failed for #{clarification_path}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

update_progress(run_root, clarification_path, allow_execution_plan)

puts "Recorded human confirmation in #{clarification_path}."
if allow_execution_plan
  puts "Clarification is now ready for execution_plan."
else
  puts "Clarification remains blocked by P0 items."
end
