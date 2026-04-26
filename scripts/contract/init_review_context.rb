#!/usr/bin/env ruby
require "fileutils"
require "yaml"

require_relative "artifact_utils"
require_relative "workflow_manifest"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/contract/init_review_context.rb [--force] --step contract_spec_ready --step-id contract-04 --contract-id <contract-id> --batch-id <batch-id> --subject <contract-spec.yml> --reviewer reviewer-name <target-review.yml>"
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
subject_path = extract_flag!(args, "--subject")
reviewer = extract_flag!(args, "--reviewer")
target = args[0]

usage if step.nil? || step_id.nil? || contract_id.nil? || batch_id.nil? || subject_path.nil? || reviewer.to_s.strip.empty? || target.nil?

materials = Contract::ArtifactUtils.review_materials(step)
unless materials
  warn "Unknown review step: #{step}"
  exit 1
end

unless File.exist?(subject_path)
  warn "Subject file not found: #{subject_path}"
  exit 1
end

command = ["ruby", File.expand_path("init_artifact.rb", __dir__)]
command << "--force" if force
command.concat([
  "--step", step,
  "--step-id", step_id,
  "--contract-id", contract_id,
  "--batch-id", batch_id,
  "review",
  target
])
system(*command) or exit 1

review_data = YAML.safe_load(File.read(target), permitted_classes: [Time], aliases: true)
review_data["meta"]["subject_path"] = subject_path
review_data["meta"]["reviewer"] = reviewer
File.write(target, YAML.dump(review_data))

materials_target = target.sub(/\.ya?ml\z/, ".materials.yml")
FileUtils.mkdir_p(File.dirname(materials_target))
File.write(materials_target, YAML.dump(materials))

puts "Wrote reviewer materials snapshot to #{materials_target}"
