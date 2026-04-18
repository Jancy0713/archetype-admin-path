#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

artifact = ARGV[0]
source = ARGV[1]
target = ARGV[2]

if artifact.nil? || source.nil? || target.nil?
  warn "Usage: ruby scripts/init/render_artifact.rb <project_profile|review|baseline|change_request> <source.yml> <target.md>"
  exit 1
end

unless File.exist?(source)
  warn "File not found: #{source}"
  exit 1
end

unless InitFlow::ArtifactUtils::ARTIFACT_TYPES.include?(artifact)
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

begin
  data = InitFlow::ArtifactUtils.load_yaml(source)
rescue ArgumentError => e
  warn e.message
  exit 2
end

errors = InitFlow::ArtifactUtils.validate_artifact(artifact, data, artifact_path: source)
unless errors.empty?
  warn "Cannot render invalid artifact: #{source}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

def section(title, body)
  "## #{title}\n\n#{body}\n"
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

def key_value(hash)
  return "- " unless hash.is_a?(Hash) && !hash.empty?
  hash.map { |k, v| "- #{k}: #{format_value(v)}" }.join("\n")
end

def bullet_list(items)
  items = Array(items).compact
  return "- " if items.empty?
  items.map { |item| "- #{item}" }.join("\n")
end

def nested_list(items)
  items = Array(items).compact
  return "- " if items.empty?
  items.map do |item|
    if item.is_a?(Hash)
      first_key, first_value = item.first
      lines = ["- #{first_key}: #{format_value(first_value)}"]
      item.drop(1).each { |key, value| lines << "  - #{key}: #{format_value(value)}" }
      lines.join("\n")
    else
      "- #{item}"
    end
  end.join("\n")
end

def render_stage_progress(progress)
  key_value(progress)
end

def render_profile_stages(stages)
  stages = Array(stages).compact
  return "- " if stages.empty?

  stages.map do |stage|
    lines = []
    lines << "- stage_id: #{format_value(stage['stage_id'])}"
    lines << "  - stage_name: #{format_value(stage['stage_name'])}"
    lines << "  - priority: #{format_value(stage['priority'])}"
    lines << "  - objective: #{format_value(stage['objective'])}"
    lines << "  - status: #{format_value(stage['status'])}"
    lines << "  - summary: #{format_value(stage['summary'])}"
    lines << "  - confirmation: #{format_value(stage['confirmation'])}"
    lines << "  - required_questions: #{format_value(stage['required_questions'])}"
    lines << "  - adaptive_questions: #{format_value(stage['adaptive_questions'])}"
    lines << "  - key_decisions: #{format_value(stage['key_decisions'])}"
    lines << "  - recommended_defaults: #{format_value(stage['recommended_defaults'])}"
    lines << "  - open_questions: #{format_value(stage['open_questions'])}"
    lines.join("\n")
  end.join("\n")
end

md = +""

case artifact
when "project_profile"
  md << "# Project Profile\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Profile", key_value(data["project_profile"]))
  md << section("Stage Progress", render_stage_progress(data["stage_progress"]))
  md << section("Stages", render_profile_stages(data["stages"]))
  md << section("Decision", key_value(data["decision"]))
when "review"
  md << "# Init Review\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Current Stage Review", key_value(data["current_stage_review"]))
  md << section("Issues", bullet_list(data.dig("findings", "issues")))
  md << section("Missing Info", bullet_list(data.dig("findings", "missing_info")))
  md << section("P0", bullet_list(data.dig("findings", "p0")))
  md << section("Decision", key_value(data["decision"]))
when "baseline"
  md << "# Initialization Baseline\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Project Summary", key_value(data["project_summary"]))
  md << section("Identity Access", key_value(data["identity_access"]))
  md << section("UI Foundation", key_value(data["ui_foundation"]))
  md << section("Platform Defaults", key_value(data["platform_defaults"]))
  md << section("Field Sources", key_value(data["field_sources"]))
  md << section("Key Decisions", nested_list(data["key_decisions"]))
  md << section("Recommended Defaults", nested_list(data["recommended_defaults"]))
  md << section("P0", bullet_list(data.dig("open_questions", "p0")))
  md << section("Decision", key_value(data["decision"]))
when "change_request"
  md << "# Initialization Change Request\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Change", key_value(data["change"]))
  md << section("Impact", key_value(data["impact"]))
  md << section("Decision", key_value(data["decision"]))
end

FileUtils.mkdir_p(File.dirname(target))
File.write(target, md)
puts "Rendered #{artifact} markdown to #{target}"
