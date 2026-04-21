#!/usr/bin/env ruby
require "pathname"

ROOT = File.expand_path("../../..", __dir__)

def usage
  warn "Usage: ruby scripts/init/foundation/prepare_baseline.rb <run_dir> [--force]"
  exit 1
end

def run_command(*command)
  puts "$ #{command.join(' ')}"
  success = system(*command, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

run_dir = ARGV[0]
force = ARGV[1..].to_a.include?("--force")
usage if run_dir.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
source = File.join(run_root, "init/init-04.project_profile.yaml")
target = File.join(run_root, "init/init-05.baseline.yaml")
render = File.join(run_root, "rendered/init-05.baseline.md")

run_command("ruby", "scripts/init/validate_artifact.rb", "project_profile", source)
run_command("ruby", "scripts/init/init_artifact.rb", *(force ? ["--force"] : []), "--step-id", "init-05", "baseline", target)
run_command("ruby", "scripts/init/render_artifact.rb", "baseline", target, render)
