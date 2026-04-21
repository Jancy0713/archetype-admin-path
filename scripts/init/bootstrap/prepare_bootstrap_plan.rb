#!/usr/bin/env ruby
ROOT = File.expand_path("../../..", __dir__)

def usage
  warn "Usage: ruby scripts/init/bootstrap/prepare_bootstrap_plan.rb <run_dir> [--force]"
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
source = File.join(run_root, "init/init-06.design_seed.yaml")
target = File.join(run_root, "init/init-07.bootstrap_plan.yaml")
review = File.join(run_root, "init/init-07.review.yaml")
render = File.join(run_root, "rendered/init-07.bootstrap_plan.md")
prd_context_render = File.join(run_root, "rendered/init-07.prd-bootstrap-context.md")
conventions_render = File.join(run_root, "rendered/init-07.project-conventions.md")
scope_render = File.join(run_root, "rendered/init-07.init-execution-scope.md")

run_command("ruby", "scripts/init/validate_artifact.rb", "design_seed", source)
run_command("ruby", "scripts/init/prefill_from_upstream.rb", "--step-id", "init-07", "bootstrap_plan", source, target)
run_command("ruby", "scripts/init/validate_artifact.rb", "bootstrap_plan", target)
run_command("ruby", "scripts/init/init_artifact.rb", *(force ? ["--force"] : []), "--step", "initialization_bootstrap_plan", "--step-id", "init-07", "review", review)
run_command("ruby", "scripts/init/render_artifact.rb", "bootstrap_plan", target, render)
run_command("ruby", "scripts/init/render_project_conventions.rb", target, conventions_render)
run_command("ruby", "scripts/init/render_prd_bootstrap_context.rb", target, prd_context_render)
run_command("ruby", "scripts/init/render_init_execution_scope.rb", target, scope_render)
