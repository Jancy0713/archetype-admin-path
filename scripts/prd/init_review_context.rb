#!/usr/bin/env ruby
require "fileutils"
require "yaml"

require_relative "artifact_utils"

args = ARGV.dup
step = nil
step_id = nil
subject_path = nil
reviewer = nil
target = nil
force = false

while args.any?
  token = args.shift
  case token
  when "--force"
    force = true
  when "--step"
    step = args.shift
  when "--step-id"
    step_id = args.shift
  when "--subject"
    subject_path = args.shift
  when "--reviewer"
    reviewer = args.shift
  else
    target = token
  end
end

if step.nil? || step_id.nil? || subject_path.nil? || target.nil?
  warn "Usage: ruby scripts/prd/init_review_context.rb [--force] --step <prd_analysis|prd_clarification|prd_execution_plan|final_prd_ready> --step-id <prd-01> --subject <subject.yml> [--reviewer reviewer-name] <target-review.yml>"
  exit 1
end

materials = Prd::ArtifactUtils.review_materials(step)
unless materials
  warn "Unknown review step: #{step}"
  exit 1
end

unless File.exist?(subject_path)
  warn "Subject file not found: #{subject_path}"
  exit 1
end

FileUtils.mkdir_p(File.dirname(target))
command = ["ruby", File.expand_path("init_artifact.rb", __dir__)]
command << "--force" if force
command.concat(["--step", step, "--step-id", step_id, "review", target])
system(*command) or exit 1

review = Prd::ArtifactUtils.load_yaml(target)
review["meta"]["subject_path"] = subject_path
review["meta"]["reviewer"] = reviewer if reviewer && !reviewer.strip.empty?
File.write(target, YAML.dump(review))

materials_target = target.sub(/\.ya?ml\z/, ".materials.yml")
File.write(materials_target, YAML.dump(materials))

puts "Wrote reviewer materials snapshot to #{materials_target}"
