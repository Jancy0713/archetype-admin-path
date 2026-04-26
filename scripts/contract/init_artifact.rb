#!/usr/bin/env ruby
require "fileutils"
require "time"
require "yaml"

require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/contract/init_artifact.rb [--force] [--step contract_spec_ready] [--step-id contract-01] [--contract-id batch-id] [--batch-id batch-id] [--run-id run-id] <scope_intake|domain_mapping|contract_spec|review> <target.yml>"
  exit 1
end

args = ARGV.dup
force = args.delete("--force")

def extract_flag!(args, flag)
  index = args.index(flag)
  return nil unless index

  value = args[index + 1]
  args.slice!(index, 2)
  value
end

step = extract_flag!(args, "--step")
step_id = extract_flag!(args, "--step-id")
contract_id = extract_flag!(args, "--contract-id")
batch_id = extract_flag!(args, "--batch-id")
run_id = extract_flag!(args, "--run-id")

artifact = args[0]
target = args[1]
usage if artifact.nil? || target.nil?

unless ContractFlow::WorkflowManifest.artifact_types.include?(artifact)
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

template = ContractFlow::WorkflowManifest.template_path(ROOT, artifact)
unless File.exist?(template)
  warn "Template not found: #{template}"
  exit 1
end

if File.exist?(target) && !force
  warn "Target already exists: #{target} (use --force to overwrite)"
  exit 1
end

content = YAML.safe_load(File.read(template), permitted_classes: [Time], aliases: true)
now = Time.now.utc.iso8601
effective_batch_id = batch_id || contract_id
effective_contract_id = contract_id || batch_id

if content["meta"].is_a?(Hash)
  content["meta"]["updated_at"] = now if content["meta"].key?("updated_at")
  content["meta"]["step_id"] = step_id if content["meta"].key?("step_id") && step_id
  if content["meta"].key?("artifact_id")
    derived_artifact_id = step_id && artifact ? "#{step_id}.#{artifact}" : nil
    content["meta"]["artifact_id"] = derived_artifact_id if derived_artifact_id
  end
  content["meta"]["contract_id"] = effective_contract_id if content["meta"].key?("contract_id") && effective_contract_id
  content["meta"]["batch_id"] = effective_batch_id if content["meta"].key?("batch_id") && effective_batch_id
  content["meta"]["run_id"] = run_id if content["meta"].key?("run_id") && run_id
end

if artifact == "review"
  content["status"]["step"] = step if step && content["status"].is_a?(Hash)
elsif step_id && content["status"].is_a?(Hash) && content["status"].key?("step")
  mapped_step = ContractFlow::WorkflowManifest.step_for(step_id)
  content["status"]["step"] = mapped_step ? mapped_step.fetch("artifact") : content["status"]["step"]
end

FileUtils.mkdir_p(File.dirname(target))
File.write(target, YAML.dump(content))
puts "Initialized #{artifact} artifact at #{target}"
