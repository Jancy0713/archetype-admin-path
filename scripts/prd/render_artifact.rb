#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

artifact = ARGV[0]
source = ARGV[1]
target = ARGV[2]

if artifact.nil? || source.nil? || target.nil?
  warn "Usage: ruby scripts/prd/render_artifact.rb <clarification|review|brief|decomposition> <source.yml> <target.md>"
  exit 1
end

unless File.exist?(source)
  warn "File not found: #{source}"
  exit 1
end

unless Prd::ArtifactUtils::ARTIFACT_TYPES.include?(artifact)
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

begin
  data = Prd::ArtifactUtils.load_yaml(source)
rescue ArgumentError => e
  warn e.message
  exit 2
end

errors = Prd::ArtifactUtils.validate_artifact(artifact, data, artifact_path: source)
unless errors.empty?
  warn "Cannot render invalid artifact: #{source}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

def section(title, body)
  "## #{title}\n\n#{body}\n"
end

def bullet_list(items)
  items = Array(items).compact
  return "- " if items.empty?
  items.map { |i| "- #{i}" }.join("\n")
end

def nested_list(items)
  items = Array(items).compact
  return "- " if items.empty?

  items.map do |item|
    if item.is_a?(Hash)
      first_key, first_value = item.first
      lines = ["- #{first_key}: #{format_value(first_value)}"]
      item.drop(1).each do |key, value|
        lines << "  - #{key}: #{format_value(value)}"
      end
      lines.join("\n")
    else
      "- #{item}"
    end
  end.join("\n")
end

def key_value(hash)
  return "- " unless hash.is_a?(Hash) && !hash.empty?
  hash.map { |k, v| "- #{k}: #{format_value(v)}" }.join("\n")
end

def format_value(value)
  case value
  when Array
    return "" if value.empty?
    if value.all? { |item| item.is_a?(Hash) }
      value.map { |item| item.map { |k, v| "#{k}=#{format_value(v)}" }.join(" / ") }.join(" ; ")
    else
      value.join(", ")
    end
  when TrueClass, FalseClass
    value.to_s
  else
    value
  end
end

md = +""

case artifact
when "clarification"
  md << "# Clarification\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Confirmed", key_value(data["confirmed"]))
  md << section("P0 Gaps", bullet_list(data.dig("gaps", "p0")))
  md << section("P1 Gaps", bullet_list(data.dig("gaps", "p1")))
  md << section("Questions", key_value(data["questions"]))
  md << section("Decision Candidates", nested_list(data["decision_candidates"]))
  md << section("Proposed Defaults", nested_list(data["proposed_defaults"]))
  md << section("Decision", key_value(data["decision"]))
when "review"
  md << "# Review Result\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Issues", bullet_list(data.dig("findings", "issues")))
  md << section("Missing Info", bullet_list(data.dig("findings", "missing_info")))
  md << section("P0", bullet_list(data.dig("findings", "p0")))
  md << section("Decision", key_value(data["decision"]))
  md << section("Required Revisions", bullet_list(data["required_revisions"]))
  md << section("Notes", bullet_list(data["notes"]))
when "brief"
  md << "# Clarified Brief\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Summary", key_value(data["summary"]))
  md << section("Scope", key_value(data["scope"]))
  md << section("Roles", nested_list(data["roles"]))
  md << section("Core Flows", nested_list(data["core_flows"]))
  md << section("Core Resources", nested_list(data["core_resources"]))
  md << section("MVP", key_value(data["mvp"]))
  md << section("Constraints", key_value(data["constraints"]))
  md << section("Decision Candidates", nested_list(data["decision_candidates"]))
  md << section("Proposed Defaults", nested_list(data["proposed_defaults"]))
  md << section("P0", bullet_list(data.dig("open_questions", "p0")))
  md << section("Decision", key_value(data["decision"]))
when "decomposition"
  md << "# Decomposition\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Modules", nested_list(data["modules"]))
  md << section("Pages", nested_list(data["pages"]))
  md << section("Roles", nested_list(data["roles"]))
  md << section("Resources", nested_list(data["resources"]))
  md << section("Flows", nested_list(data["flows"]))
  md << section("States", nested_list(data["states"]))
  md << section("Observations", key_value(data["observations"]))
  md << section("P0", bullet_list(data.dig("open_questions", "p0")))
  md << section("Decision", key_value(data["decision"]))
else
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

FileUtils.mkdir_p(File.dirname(target))
File.write(target, md)
puts "Rendered #{artifact} markdown to #{target}"
