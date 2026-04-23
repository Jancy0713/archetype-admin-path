#!/usr/bin/env ruby
require_relative "../progress_board"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/prd/continue_run.rb <run_dir> <#{PrdFlow::WorkflowManifest.continue_usage}> [--mode artifact|review|render] [--force]"
  exit 1
end

def progress_path_for(run_root)
  File.join(run_root, "progress/workflow-progress.md")
end

def update_progress(run_root, step_id, mode)
  progress_path = progress_path_for(run_root)
  return unless File.exist?(progress_path)

  board = WorkflowProgressBoard::Board.new(progress_path)
  updates = PrdFlow::WorkflowManifest.progress_updates_for(step_id, mode)
  return unless updates

  updates.fetch(:rows, {}).each do |row_step_id, row_updates|
    board.update_row(row_step_id, row_updates)
  end
  updates.fetch(:meta, {}).each do |field, value|
    board.set_meta(field, value)
  end

  board.save
end

run_dir = ARGV[0]
step_id = ARGV[1]
remaining = ARGV.drop(2)
usage if run_dir.to_s.strip.empty? || step_id.to_s.strip.empty?

mode = "artifact"
force = false

while remaining.any?
  token = remaining.shift
  case token
  when "--mode"
    mode = remaining.shift.to_s
  when "--force"
    force = true
  else
    usage
  end
end

usage unless %w[artifact review render].include?(mode)

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

commands = PrdFlow::WorkflowManifest.commands_for(step_id, run_root: run_root, mode: mode, force: force)
usage unless commands

commands.each do |cmd|
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  exit(Process.last_status&.exitstatus || 1) unless success
end

update_progress(run_root, step_id, mode)
PrdFlow::WorkflowManifest.completion_messages_for(step_id, mode, run_root).each { |line| puts line }
