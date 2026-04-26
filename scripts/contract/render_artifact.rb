#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

def usage
  warn "Usage: ruby scripts/contract/render_artifact.rb <scope_intake|domain_mapping|contract_spec|review> <source.yml> <target.md>"
  exit 1
end

def present_value?(value)
  case value
  when nil
    false
  when String
    !value.strip.empty?
  when Array, Hash
    !value.empty?
  else
    true
  end
end

def humanize_key(key)
  key.to_s.split("_").map(&:capitalize).join(" ")
end

def format_value(value)
  case value
  when TrueClass, FalseClass
    value.to_s
  when Array
    value.map { |item| item.is_a?(Hash) ? item.map { |k, v| "#{k}=#{format_value(v)}" }.join(" / ") : item.to_s }.join(", ")
  else
    value.to_s
  end
end

def indent_block(text, spaces = 2)
  text.lines.map { |line| (" " * spaces) + line }.join
end

def bullet_list(items)
  values = Array(items).select { |item| present_value?(item) }
  return "- None" if values.empty?

  values.map do |item|
    if item.is_a?(Hash)
      "- #{item.map { |key, value| "#{humanize_key(key)}: #{format_value(value)}" }.join(" | ")}"
    else
      "- #{item}"
    end
  end.join("\n")
end

def key_value(hash)
  entries = hash.is_a?(Hash) ? hash : {}
  lines = entries.each_with_object([]) do |(key, value), acc|
    next unless present_value?(value)

    if value.is_a?(Array)
      acc << "- #{humanize_key(key)}:"
      acc << indent_block(bullet_list(value))
    elsif value.is_a?(Hash)
      acc << "- #{humanize_key(key)}:"
      acc << indent_block(key_value(value))
    else
      acc << "- #{humanize_key(key)}: #{format_value(value)}"
    end
  end

  lines.empty? ? "- None" : lines.join("\n")
end

def section(title, body)
  return "" unless present_value?(body)

  "## #{title}\n\n#{body}\n\n"
end

def render_cards(items, title_key:, scalar_keys: [], list_keys: [])
  values = Array(items).select { |item| item.is_a?(Hash) && !item.empty? }
  return "- None" if values.empty?

  values.each_with_index.map do |item, index|
    title = item[title_key]
    title = "Item #{index + 1}" unless present_value?(title)

    lines = ["### #{title}"]
    scalar_keys.each do |key|
      next unless present_value?(item[key])

      lines << "- #{humanize_key(key)}: #{format_value(item[key])}"
    end
    list_keys.each do |key|
      next unless present_value?(item[key])

      lines << "- #{humanize_key(key)}:"
      lines << indent_block(bullet_list(item[key]))
    end
    lines.join("\n")
  end.join("\n\n")
end

def render_scope_intake(data)
  md = +"# Scope Intake\n\n"
  md << section("Status", key_value(data["status"]))
  md << section("Meta", key_value(data["meta"]))
  md << section("Intake Basis", key_value(data["intake_basis"]))
  md << section("Batch Scope", key_value(data["batch_scope"]))
  md << section("Dependencies", key_value(data["dependencies"]))
  md << section("Do Not Assume", bullet_list(data["do_not_assume"]))
  md << section("Blocking Items", key_value(data["blocking_items"]))
  md << section("Decision", key_value(data["decision"]))
  md
end

def render_domain_mapping(data)
  md = +"# Domain Mapping\n\n"
  md << section("Status", key_value(data["status"]))
  md << section("Meta", key_value(data["meta"]))
  md << section("Mapping Basis", key_value(data["mapping_basis"]))
  md << section(
    "Resource Map",
    render_cards(
      data.dig("resource_map", "resources"),
      title_key: "name",
      scalar_keys: %w[kind ownership summary shared_or_new],
      list_keys: %w[related_views]
    )
  )
  md << section(
    "Action Map",
    render_cards(
      data.dig("action_map", "actions"),
      title_key: "name",
      scalar_keys: %w[resource_name action_type summary],
      list_keys: %w[related_views]
    )
  )
  md << section(
    "State And Enum Map",
    render_cards(
      data.dig("state_and_enum_map", "state_groups"),
      title_key: "resource_name",
      list_keys: %w[states_defined_here shared_states enums_defined_here shared_enums]
    )
  )
  md << section("Access Map", key_value(data["access_map"]))
  md << section(
    "Consumer View Map",
    render_cards(
      data.dig("consumer_view_map", "views"),
      title_key: "name",
      scalar_keys: %w[view_type goal],
      list_keys: %w[primary_resources primary_actions]
    )
  )
  md << section("Reference Plan", key_value(data["reference_plan"]))
  md << section("Decision", key_value(data["decision"]))
  md
end

def render_contract_spec(data)
  md = +"# Contract Spec\n\n"
  md << section("Status", key_value(data["status"]))
  md << section("Meta", key_value(data["meta"]))
  md << section("Spec Scope", key_value(data["spec_scope"]))
  md << section("Shared References", key_value(data["shared_references"]))
  md << section(
    "Resource Contracts",
    render_cards(
      data.dig("resource_contracts", "resources"),
      title_key: "name",
      scalar_keys: %w[purpose ownership],
      list_keys: %w[fields states constraints references]
    )
  )
  md << section(
    "Consumer Views",
    render_cards(
      data.dig("consumer_views", "views"),
      title_key: "name",
      scalar_keys: %w[view_type goal],
      list_keys: %w[consumers required_resources required_fields required_actions]
    )
  )
  md << section("Query And Command Semantics", key_value(data["query_and_command_semantics"]))
  md << section(
    "API Surface",
    render_cards(
      data.dig("api_surface", "endpoints"),
      title_key: "operation_id",
      scalar_keys: %w[method path summary],
      list_keys: %w[tags request response errors]
    )
  )
  md << section("Access And Tenant Rules", key_value(data["access_and_tenant_rules"]))
  md << section("Validation And Error Semantics", key_value(data["validation_and_error_semantics"]))
  md << section("Implementation Notes For Consumers", key_value(data["implementation_notes_for_consumers"]))
  md << section("Decision", key_value(data["decision"]))
  md
end

def render_review(data)
  md = +"# Review Result\n\n"
  md << section("Status", key_value(data["status"]))
  md << section("Meta", key_value(data["meta"]))
  md << section("Review Scope", key_value(data["review_scope"]))
  md << section("Issues", bullet_list(data.dig("findings", "issues")))
  md << section("Missing Info", bullet_list(data.dig("findings", "missing_info")))
  md << section("P0", bullet_list(data.dig("findings", "p0")))
  md << section("Decision", key_value(data["decision"]))
  md << section("Required Revisions", bullet_list(data["required_revisions"]))
  md << section("Notes", bullet_list(data["notes"]))
  md
end

artifact = ARGV[0]
source = ARGV[1]
target = ARGV[2]
usage if artifact.nil? || source.nil? || target.nil?

unless Contract::ArtifactUtils::ARTIFACT_TYPES.include?(artifact)
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

unless File.exist?(source)
  warn "File not found: #{source}"
  exit 1
end

data = Contract::ArtifactUtils.load_yaml(source)
md =
  case artifact
  when "scope_intake" then render_scope_intake(data)
  when "domain_mapping" then render_domain_mapping(data)
  when "contract_spec" then render_contract_spec(data)
  when "review" then render_review(data)
  end

FileUtils.mkdir_p(File.dirname(target))
File.write(target, md)
puts "Rendered #{artifact} markdown to #{target}"
