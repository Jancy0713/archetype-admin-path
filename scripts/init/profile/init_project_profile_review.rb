#!/usr/bin/env ruby
ROOT = File.expand_path("../../..", __dir__)

STEP_STAGE_MAP = {
  "init-01" => "foundation_context",
  "init-02" => "tenant_governance",
  "init-03" => "identity_access",
  "init-04" => "experience_platform"
}.freeze

def usage
  warn "Usage: ruby scripts/init/profile/init_project_profile_review.rb <run_dir> <init-01|init-02|init-03|init-04> [--force]"
  exit 1
end

run_dir = ARGV[0]
step_id = ARGV[1]
force = ARGV[2..].to_a.include?("--force")
usage if run_dir.to_s.strip.empty? || !STEP_STAGE_MAP.key?(step_id)

run_root = File.expand_path(run_dir, ROOT)
target = File.join(run_root, "init/#{step_id}.review.yaml")
command = ["ruby", "scripts/init/init_artifact.rb"]
command << "--force" if force
command += ["--step", "project_initialization", "--step-id", step_id, "review", target]

puts "$ #{command.join(' ')}"
success = system(*command, chdir: ROOT)
exit(Process.last_status&.exitstatus || 1) unless success
