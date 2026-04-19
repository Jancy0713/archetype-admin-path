#!/usr/bin/env ruby
require_relative "artifact_utils"

include InitFlow::ArtifactUtils

artifact = ARGV[0]
path = ARGV[1]

if artifact.nil? || path.nil?
  warn "Usage: ruby scripts/init/validate_artifact.rb <project_profile|review|baseline|design_seed|bootstrap_plan|change_request> <artifact.yml>"
  exit 1
end

unless File.exist?(path)
  warn "File not found: #{path}"
  exit 1
end

unless ARTIFACT_TYPES.include?(artifact)
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

begin
  data = load_yaml(path)
rescue ArgumentError => e
  warn e.message
  exit 2
end

errors = validate_artifact(artifact, data, artifact_path: path)
if errors.empty?
  puts "OK: #{path}"
  exit 0
else
  warn "Validation failed for #{path}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end
