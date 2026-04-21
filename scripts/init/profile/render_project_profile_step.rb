#!/usr/bin/env ruby
ROOT = File.expand_path("../../..", __dir__)

STEP_STAGE_MAP = {
  "init-01" => "foundation_context",
  "init-02" => "tenant_governance",
  "init-03" => "identity_access",
  "init-04" => "experience_platform"
}.freeze

def usage
  warn "Usage: ruby scripts/init/profile/render_project_profile_step.rb <run_dir> <init-01|init-02|init-03|init-04>"
  exit 1
end

run_dir = ARGV[0]
step_id = ARGV[1]
usage if run_dir.to_s.strip.empty? || !STEP_STAGE_MAP.key?(step_id)

run_root = File.expand_path(run_dir, ROOT)
source = File.join(run_root, "init/#{step_id}.project_profile.yaml")
target = File.join(run_root, "rendered/#{step_id}.project_profile.md")

[
  ["ruby", "scripts/init/validate_artifact.rb", "project_profile", source],
  ["ruby", "scripts/init/render_artifact.rb", "project_profile", source, target]
].each do |command|
  puts "$ #{command.join(' ')}"
  success = system(*command, chdir: ROOT)
  exit(Process.last_status&.exitstatus || 1) unless success
end
