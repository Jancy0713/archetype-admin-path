#!/usr/bin/env ruby
require "fileutils"
require "time"

require_relative "artifact_utils"

ROOT = File.expand_path("../..", __dir__)
TEMPLATE_DIR = File.join(ROOT, "docs/prd/templates/structured")

args = ARGV.dup
force = args.delete("--force")
step_index = args.index("--step")
step = nil
if step_index
  step = args[step_index + 1]
  args.slice!(step_index, 2)
end
step_id_index = args.index("--step-id")
step_id = nil
if step_id_index
  step_id = args[step_id_index + 1]
  args.slice!(step_id_index, 2)
end
flow_id_index = args.index("--flow-id")
flow_id = nil
if flow_id_index
  flow_id = args[flow_id_index + 1]
  args.slice!(flow_id_index, 2)
end
artifact_id_index = args.index("--artifact-id")
artifact_id = nil
if artifact_id_index
  artifact_id = args[artifact_id_index + 1]
  args.slice!(artifact_id_index, 2)
end
artifact = args[0]
target = args[1]

if artifact.nil? || target.nil?
  warn "Usage: ruby scripts/prd/init_artifact.rb [--force] [--step prd_analysis|prd_clarification|prd_execution_plan|final_prd_ready] [--step-id prd-01] [--flow-id prd] [--artifact-id prd-01.analysis] <analysis|clarification|execution_plan|final_prd|review> <target.yml>"
  exit 1
end

unless Prd::ArtifactUtils::ARTIFACT_TYPES.include?(artifact)
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

template = File.join(TEMPLATE_DIR, "#{artifact}.template.yaml")
target_exists = File.exist?(target)
if target_exists && !force
  warn "Target already exists: #{target} (use --force to overwrite)"
  exit 1
end

FileUtils.mkdir_p(File.dirname(target))
content = Prd::ArtifactUtils.load_yaml(template)
if content["meta"].is_a?(Hash) && content["meta"].key?("updated_at")
  content["meta"]["updated_at"] = Time.now.utc.iso8601
  derived_flow_id = flow_id || step_id.to_s.split("-", 2).first
  content["meta"]["flow_id"] = derived_flow_id if content["meta"].key?("flow_id") && derived_flow_id && !derived_flow_id.empty?
  content["meta"]["step_id"] = step_id if content["meta"].key?("step_id") && step_id && !step_id.empty?
  if content["meta"].key?("artifact_id")
    derived_artifact_id = artifact_id
    derived_artifact_id ||= "#{step_id}.#{artifact}" if step_id && !step_id.empty?
    content["meta"]["artifact_id"] = derived_artifact_id if derived_artifact_id && !derived_artifact_id.empty?
  end
end
if artifact == "review" && step
  unless Prd::ArtifactUtils::REVIEWABLE_SUBJECTS.key?(step)
    warn "Invalid review step: #{step}"
    exit 1
  end
  content["status"]["step"] = step
  content["meta"]["subject_type"] = Prd::ArtifactUtils::REVIEWABLE_SUBJECTS.fetch(step)
end
File.write(target, YAML.dump(content))
puts "Initialized #{artifact} artifact at #{target}"
