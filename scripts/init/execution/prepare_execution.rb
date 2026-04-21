#!/usr/bin/env ruby
ROOT = File.expand_path("../../..", __dir__)

def usage
  warn "Usage: ruby scripts/init/execution/prepare_execution.rb <run_dir> [execute_init_scope args...]"
  exit 1
end

def run_command(*command)
  puts "$ #{command.join(' ')}"
  success = system(*command, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

run_dir = ARGV[0]
execution_args = ARGV.drop(1)
usage if run_dir.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
source = File.join(run_root, "init/init-07.bootstrap_plan.yaml")
scope_render = File.join(run_root, "rendered/init-07.init-execution-scope.md")

run_command("ruby", "scripts/init/validate_artifact.rb", "bootstrap_plan", source)
run_command("ruby", "scripts/init/render_init_execution_scope.rb", source, scope_render)
run_command("ruby", "scripts/init/execute_init_scope.rb", source, *execution_args)
