#!/usr/bin/env ruby
require "yaml"

require_relative "artifact_utils"

args = ARGV.dup
artifact_index = args.index("--artifact")
artifact = artifact_index ? args[artifact_index + 1] : nil
review_step_index = args.index("--review-step")
review_step = review_step_index ? args[review_step_index + 1] : nil

if [artifact, review_step].compact.size != 1
  warn "Usage: ruby scripts/contract/materials.rb --artifact <scope_intake|domain_mapping|contract_spec|review> | --review-step <contract_spec_ready>"
  exit 1
end

payload =
  if artifact
    Contract::ArtifactUtils.artifact_materials(artifact)
  else
    Contract::ArtifactUtils.review_materials(review_step)
  end

unless payload
  warn "Unknown artifact or review step"
  exit 1
end

puts YAML.dump(payload)
