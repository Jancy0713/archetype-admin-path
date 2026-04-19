#!/usr/bin/env ruby
require "fileutils"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/init/continue_run.rb <run_dir> <init-05|init-06|init-07|init-08> [--force] [--project-root PATH] [--project-name NAME] [--keep-git] [--remote-url URL] [--owner NAME] [--prd-run-id RUN_ID]"
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

commands =
  case step_id
  when "init-05"
    source = File.join(run_root, "init/init-04.project_profile.yaml")
    target = File.join(run_root, "init/init-05.baseline.yaml")
    render = File.join(run_root, "rendered/init-05.baseline.md")
    [
      ["ruby", "scripts/init/validate_artifact.rb", "project_profile", source],
      ["ruby", "scripts/init/init_artifact.rb", *(force ? ["--force"] : []), "--step-id", "init-05", "baseline", target],
      ["ruby", "scripts/init/render_artifact.rb", "baseline", target, render]
    ]
  when "init-06"
    source = File.join(run_root, "init/init-05.baseline.yaml")
    target = File.join(run_root, "init/init-06.design_seed.yaml")
    render = File.join(run_root, "rendered/init-06.design_seed.md")
    [
      ["ruby", "scripts/init/validate_artifact.rb", "baseline", source],
      ["ruby", "scripts/init/prefill_from_upstream.rb", *(force ? ["--step-id", "init-06"] : ["--step-id", "init-06"]), "design_seed", source, target],
      ["ruby", "scripts/init/validate_artifact.rb", "design_seed", target],
      ["ruby", "scripts/init/render_artifact.rb", "design_seed", target, render]
    ]
  when "init-07"
    source = File.join(run_root, "init/init-06.design_seed.yaml")
    target = File.join(run_root, "init/init-07.bootstrap_plan.yaml")
    render = File.join(run_root, "rendered/init-07.bootstrap_plan.md")
    prd_context_render = File.join(run_root, "rendered/init-07.prd-bootstrap-context.md")
    [
      ["ruby", "scripts/init/validate_artifact.rb", "design_seed", source],
      ["ruby", "scripts/init/prefill_from_upstream.rb", *(force ? ["--step-id", "init-07"] : ["--step-id", "init-07"]), "bootstrap_plan", source, target],
      ["ruby", "scripts/init/validate_artifact.rb", "bootstrap_plan", target],
      ["ruby", "scripts/init/render_artifact.rb", "bootstrap_plan", target, render],
      ["ruby", "scripts/init/render_prd_bootstrap_context.rb", target, prd_context_render]
    ]
  when "init-08"
    source = File.join(run_root, "init/init-07.bootstrap_plan.yaml")
    scope_render = File.join(run_root, "rendered/init-08.init-execution-scope.md")
    execution_args = remaining.dup
    [
      ["ruby", "scripts/init/validate_artifact.rb", "bootstrap_plan", source],
      ["ruby", "scripts/init/render_init_execution_scope.rb", source, scope_render],
      ["ruby", "scripts/init/execute_init_scope.rb", source, *execution_args]
    ]
  else
    usage
  end

commands.each do |cmd|
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  exit($CHILD_STATUS.exitstatus || 1) unless success
end

case step_id
when "init-05"
  puts "Initialized baseline from existing init-04 output at #{run_root}."
  puts "Next: fill #{File.join(run_root, 'init/init-05.baseline.yaml')}, validate it, then rerun this script for init-06."
when "init-06"
  puts "Rendered design_seed for review at #{File.join(run_root, 'rendered/init-06.design_seed.md')}."
when "init-07"
  puts "Rendered bootstrap_plan for review at #{File.join(run_root, 'rendered/init-07.bootstrap_plan.md')}."
  puts "Rendered prd bootstrap context sample at #{File.join(run_root, 'rendered/init-07.prd-bootstrap-context.md')}."
  puts "At the human gate, review both rendered/init-06.design_seed.md and rendered/init-07.bootstrap_plan.md together."
when "init-08"
  puts "Executed init-08 from #{File.join(run_root, 'init/init-07.bootstrap_plan.yaml')}."
  puts "Review the execution summary at #{File.join(run_root, 'rendered/init-08.execution-summary.md')}."
  puts "Hand #{File.join(run_root, 'prompts/init-08-execution-prompt.md')} to the execution agent; it must run post_init_to_prd.rb after initialization completes."
end
