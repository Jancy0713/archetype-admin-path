#!/usr/bin/env ruby
require_relative "workflow_manifest"
require_relative "progress_board"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/contract/continue_run.rb <run_dir> <flow_id> <#{ContractFlow::WorkflowManifest.continue_usage}> [--mode artifact|review|render] [--force] [--reviewer <name>]"
  exit 1
end

run_dir = ARGV[0]
flow_id = ARGV[1]
step_id = ARGV[2]
remaining = ARGV.drop(3)
usage if run_dir.to_s.strip.empty? || flow_id.to_s.strip.empty? || step_id.to_s.strip.empty?

mode = "artifact"
force = false
reviewer = nil

while remaining.any?
  token = remaining.shift
  case token
  when "--mode"
    mode = remaining.shift.to_s
  when "--force"
    force = true
  when "--reviewer"
    reviewer = remaining.shift
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

manifest_flow_id = ContractFlow::WorkflowManifest.manifest_flow_id(run_root)
if manifest_flow_id && manifest_flow_id != flow_id
  warn "Run directory flow_id (#{manifest_flow_id}) does not match argument flow_id (#{flow_id})"
  exit 2
end

# Backward compatibility for runs without run.yaml (legacy)
if !manifest_flow_id && File.basename(run_root) != "contract-#{flow_id}"
  # If it's a legacy run, we check for 'contract-flow_id'
  warn "Legacy run directory does not match flow_id #{flow_id}"
  exit 2
end

commands = ContractFlow::WorkflowManifest.commands_for(
  step_id,
  run_root: run_root,
  flow_id: flow_id,
  mode: mode,
  force: force,
  reviewer: reviewer
)
usage unless commands

commands.each do |cmd|
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  exit(Process.last_status&.exitstatus || 1) unless success
end

ContractFlow::ProgressBoard.update_for_continue(
  run_root: run_root,
  flow_id: flow_id,
  step_id: step_id,
  mode: mode
)
