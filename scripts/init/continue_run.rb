#!/usr/bin/env ruby
require "fileutils"
require_relative "../progress_board"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)

def progress_path_for(run_root)
  File.join(run_root, "progress/workflow-progress.md")
end

def update_progress(run_root, step_id)
  progress_path = progress_path_for(run_root)
  return unless File.exist?(progress_path)

  board = WorkflowProgressBoard::Board.new(progress_path)
  updates = InitFlow::WorkflowManifest.progress_updates_for(step_id)
  return unless updates

  updates.fetch(:rows, {}).each do |row_step_id, row_updates|
    board.update_row(row_step_id, row_updates)
  end
  updates.fetch(:meta, {}).each do |field, value|
    board.set_meta(field, value)
  end

  board.save
end

def usage
  warn "Usage: ruby scripts/init/continue_run.rb <run_dir> <#{InitFlow::WorkflowManifest.continue_usage}> [--force] [--project-root PATH] [--project-dir-name NAME] [--project-name NAME] [--keep-git] [--remote-url URL] [--owner NAME] [--prd-run-id RUN_ID]"
  exit 1
end

run_dir = ARGV[0]
step_id = ARGV[1]
remaining = ARGV.drop(2)
force = remaining.delete("--force")

usage if run_dir.to_s.strip.empty? || step_id.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

commands = InitFlow::WorkflowManifest.commands_for(step_id, run_root: run_root, force: force, execution_args: remaining.dup)
usage unless commands

commands.each do |cmd|
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  exit(Process.last_status&.exitstatus || 1) unless success
end

update_progress(run_root, step_id)
InitFlow::WorkflowManifest.completion_messages_for(step_id, run_root).each { |line| puts line }
