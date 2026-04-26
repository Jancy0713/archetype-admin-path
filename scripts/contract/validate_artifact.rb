#!/usr/bin/env ruby
require_relative "artifact_utils"

def usage
  warn "Usage: ruby scripts/contract/validate_artifact.rb <scope_intake|domain_mapping|contract_spec|review> <artifact.yml>"
  exit 1
end

artifact = ARGV[0]
path = ARGV[1]
usage if artifact.nil? || path.nil?

unless Contract::ArtifactUtils::ARTIFACT_TYPES.include?(artifact)
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

unless File.exist?(path)
  warn "File not found: #{path}"
  exit 1
end

begin
  data = Contract::ArtifactUtils.load_yaml(path)
rescue ArgumentError => e
  warn e.message
  exit 2
end

errors = Contract::ArtifactUtils.validate_artifact(artifact, data, artifact_path: path)

if errors.empty?
  puts "OK: #{path}"
  exit 0
end

warn "Validation failed for #{path}"
errors.each { |error| warn "- #{error}" }
exit 2
