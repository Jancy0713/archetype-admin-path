#!/usr/bin/env ruby
ROOT = File.expand_path("../../..", __dir__)

def usage
  warn "Usage: ruby scripts/init/foundation/prepare_design_seed.rb <run_dir> [--force]"
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
source = File.join(run_root, "init/init-05.baseline.yaml")
target = File.join(run_root, "init/init-06.design_seed.yaml")
review = File.join(run_root, "init/init-06.review.yaml")
render = File.join(run_root, "rendered/init-06.design_seed.md")

run_command("ruby", "scripts/init/validate_artifact.rb", "baseline", source)
run_command("ruby", "scripts/init/prefill_from_upstream.rb", "--step-id", "init-06", "design_seed", source, target)
run_command("ruby", "scripts/init/validate_artifact.rb", "design_seed", target)
run_command("ruby", "scripts/init/init_artifact.rb", *(force ? ["--force"] : []), "--step", "initialization_design_seed", "--step-id", "init-06", "review", review)
run_command("ruby", "scripts/init/render_artifact.rb", "design_seed", target, render)
