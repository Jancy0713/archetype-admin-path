#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

artifact = ARGV[0]
source = ARGV[1]
target = ARGV[2]

if artifact.nil? || source.nil? || target.nil?
  warn "Usage: ruby scripts/prd/render_artifact.rb <analysis|clarification|execution_plan|final_prd|review> <source.yml> <target.md>"
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

def bullet_list(items)
  items = Array(items).select { |item| present_value?(item) }
  return "- None" if items.empty?

  items.map { |i| "- #{format_value(i)}" }.join("\n")
end

def key_value(hash)
  return "- None" unless hash.is_a?(Hash) && !hash.empty?

  lines = hash.each_with_object([]) do |(key, value), acc|
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

def humanize_key(key)
  key.to_s.split("_").map(&:capitalize).join(" ")
end

def indent_block(text, spaces = 2)
  text.lines.map { |line| (" " * spaces) + line }.join
end

def scalar_lines(hash, keys)
  keys.map do |key|
    value = hash[key]
    next unless present_value?(value)

    "- #{humanize_key(key)}: #{format_value(value)}"
  end.compact
end

def list_block(hash, keys)
  keys.map do |key|
    value = Array(hash[key]).select { |item| present_value?(item) }
    next if value.empty?

    "- #{humanize_key(key)}:\n#{indent_block(bullet_list(value))}"
  end.compact
end

def render_cards(items, title_key:, scalar_keys: [], list_keys: [])
  items = Array(items).select { |item| item.is_a?(Hash) && !item.empty? }
  return "- None" if items.empty?

  items.each_with_index.map do |item, index|
    title = item[title_key]
    title = "Item #{index + 1}" unless present_value?(title)

    lines = ["### #{title}"]
    lines.concat(scalar_lines(item, scalar_keys))
    lines.concat(list_block(item, list_keys))
    lines << "- Details: None" if lines.length == 1
    lines.join("\n")
  end.join("\n\n")
end

def render_confirmation_items(items)
  items = Array(items).select { |item| item.is_a?(Hash) && !item.empty? }
  return "- None" if items.empty?

  items.each_with_index.map do |item, index|
    heading = item["question"]
    heading = item["item_id"] if !present_value?(heading) && present_value?(item["item_id"])
    heading = "Confirmation Item #{index + 1}" unless present_value?(heading)

    lines = ["### #{heading}"]
    lines << "- Item Id: #{item['item_id']}" if present_value?(item["item_id"])
    lines << "- Level: #{item['level']}" if present_value?(item["level"])
    lines << "- Answer Mode: #{item['answer_mode']}" if present_value?(item["answer_mode"])
    lines << "- Recommended: #{item['recommended']}" if present_value?(item["recommended"])
    if present_value?(item["options"])
      options = Array(item["options"]).map do |option|
        next unless option.is_a?(Hash)

        parts = []
        parts << option["label"] if present_value?(option["label"])
        parts << "(#{option['value']})" if present_value?(option["value"])
        parts << "- #{option['description']}" if present_value?(option["description"])
        parts.compact.join(" ")
      end.compact
      lines << "- Options:"
      lines << indent_block(bullet_list(options))
    end
    lines << "- Reason: #{item['reason']}" if present_value?(item["reason"])
    lines << "- Allow Custom Answer: #{item['allow_custom_answer']}" if item.key?("allow_custom_answer")
    lines << "- Default If No Answer: #{item['default_if_no_answer']}" if present_value?(item["default_if_no_answer"])
    lines.join("\n")
  end.join("\n\n")
end

def render_batch_handoffs(items)
  items = Array(items).select { |item| item.is_a?(Hash) && !item.empty? }
  return "- None" if items.empty?

  items.map do |item|
    batch_id = present_value?(item["batch_id"]) ? item["batch_id"] : "Unknown Batch"
    lines = ["### #{batch_id}"]
    lines << "- Contract Handoff:"
    lines << indent_block(key_value(item["contract_handoff"]))
    lines << "- Decision:"
    lines << indent_block(key_value(item["decision"]))
    lines.join("\n")
  end.join("\n\n")
end

def render_prd_batches(items)
  items = Array(items).select { |item| item.is_a?(Hash) && !item.empty? }
  return "- None" if items.empty?

  items.map do |item|
    title = item["title"]
    title = item["batch_id"] unless present_value?(title)
    title = "Unnamed Batch" unless present_value?(title)

    lines = ["### #{title}"]
    lines << "- Batch Id: #{item['batch_id']}" if present_value?(item["batch_id"])
    lines << "- Goal: #{item['goal']}" if present_value?(item["goal"])
    lines << "- Summary:" << indent_block(bullet_list(item["summary"])) if present_value?(item["summary"])
    lines << "- Grouped Modules:" << indent_block(bullet_list(item["grouped_modules"])) if present_value?(item["grouped_modules"])
    lines << "- Dependency Batches:" << indent_block(bullet_list(item["dependency_batches"])) if present_value?(item["dependency_batches"])
    lines << "- Grouping Reason:" << indent_block(bullet_list(item["grouping_reason"])) if present_value?(item["grouping_reason"])
    lines << "- In Scope Pages:" << indent_block(bullet_list(item["in_scope_pages"])) if present_value?(item["in_scope_pages"])
    lines << "- Key Resources:" << indent_block(bullet_list(item["key_resources"])) if present_value?(item["key_resources"])
    lines << "- Key Flows:" << indent_block(bullet_list(item["key_flows"])) if present_value?(item["key_flows"])
    lines << "- Size Control:" << indent_block(key_value(item["size_control"])) if present_value?(item["size_control"])
    lines << "- Contract Constraints:" << indent_block(bullet_list(item["contract_constraints"])) if present_value?(item["contract_constraints"])
    lines.join("\n")
  end.join("\n\n")
end

md = +""

case artifact
when "analysis"
  md << "# Analysis\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Input Summary", key_value(data["input_summary"]))
  md << section("Scope Analysis", key_value(data["scope_analysis"]))
  md << section("Modules", render_cards(data.dig("domain_breakdown", "modules"), title_key: "name", scalar_keys: %w[module_id objective priority], list_keys: %w[dependencies notes]))
  md << section("Pages", render_cards(data.dig("domain_breakdown", "pages"), title_key: "name", scalar_keys: %w[client module goal priority]))
  md << section("Resources", render_cards(data.dig("domain_breakdown", "resources"), title_key: "name", scalar_keys: %w[purpose owner priority], list_keys: %w[notes]))
  md << section("Flows", render_cards(data.dig("domain_breakdown", "flows"), title_key: "name", scalar_keys: %w[trigger outcome priority], list_keys: %w[notes]))
  md << section("Risk Analysis", key_value(data["risk_analysis"]))
  md << section("Clarification Candidates", render_confirmation_items(data.dig("clarification_candidates", "confirmation_items")))
  md << section("Handoff", key_value(data["handoff"]))
when "clarification"
  md << "# Clarification\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Context", key_value(data["clarification_context"]))
  md << section("Confirmation Items", render_confirmation_items(data["confirmation_items"]))
  md << section("Applied Defaults", render_cards(data["applied_defaults"], title_key: "topic", scalar_keys: %w[adopted_value rationale upgrade_condition]))
  md << section("Clarified Decisions", render_cards(data["clarified_decisions"], title_key: "topic", scalar_keys: %w[item_id decision source], list_keys: %w[impact]))
  md << section("Human Confirmation", key_value(data["human_confirmation"]))
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
when "execution_plan"
  md << "# Execution Plan\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Planning Basis", key_value(data["planning_basis"]))
  md << section("Delivery Strategy", key_value(data["delivery_strategy"]))
  md << section("Workstreams", render_cards(data["workstreams"], title_key: "name", scalar_keys: %w[workstream_id objective can_run_in_parallel], list_keys: %w[depends_on outputs]))
  md << section("Plan Steps", render_cards(data["plan_steps"], title_key: "name", scalar_keys: %w[step_order goal handoff_to], list_keys: %w[inputs outputs dependencies]))
  md << section("Contract Priorities", render_cards(data["contract_priorities"], title_key: "module", scalar_keys: %w[priority reason], list_keys: %w[required_inputs not_in_scope_for_now]))
  md << section("Batching Principles", bullet_list(data.dig("batching_strategy", "principles")))
  md << section("Planned Batches", render_cards(data.dig("batching_strategy", "batches"), title_key: "title", scalar_keys: %w[batch_id goal handoff_to], list_keys: %w[included_modules depends_on_batches contract_views]))
  md << section("Batch Order", bullet_list(data.dig("batching_strategy", "batch_order")))
  md << section("Risks And Watchpoints", key_value(data["risks_and_watchpoints"]))
  md << section("Decision", key_value(data["decision"]))
when "final_prd"
  md << "# Final PRD\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Overview", key_value(data["overview"]))
  md << section("Scope", key_value(data["scope"]))
  md << section("Roles", render_cards(data.dig("roles_and_permissions", "roles"), title_key: "name", scalar_keys: %w[client main_goal], list_keys: %w[visible_scope permission_notes]))
  md << section("Tenant Boundary", bullet_list(data.dig("roles_and_permissions", "tenant_boundary")))
  md << section("Resources", render_cards(data.dig("domain_model", "resources"), title_key: "name", scalar_keys: %w[resource_type purpose owner], list_keys: %w[key_attributes known_states]))
  md << section("Experience Modules", render_cards(data.dig("experience_design", "modules"), title_key: "name", scalar_keys: %w[objective], list_keys: %w[in_scope_pages key_actions]))
  md << section("Experience Pages", render_cards(data.dig("experience_design", "pages"), title_key: "name", scalar_keys: %w[client module page_type goal], list_keys: %w[primary_actions]))
  md << section("Flows", render_cards(data.dig("workflow_design", "flows"), title_key: "name", scalar_keys: %w[trigger start end is_async], list_keys: %w[key_steps]))
  md << section("States", render_cards(data.dig("workflow_design", "states"), title_key: "resource_name", list_keys: %w[current_states missing_states]))
  md << section("Constraints", key_value(data["constraints"]))
  md << section("Blocking Questions", key_value(data["blocking_questions"]))
  md << section("Contract Execution", key_value(data["contract_execution"]))
  md << section("PRD Batches", render_prd_batches(data["prd_batches"]))
  md << section("Batch Handoffs", render_batch_handoffs(data["prd_batches"]))
  md << section("Decision", key_value(data["decision"]))
else
  warn "Unknown artifact type: #{artifact}"
  exit 1
end

FileUtils.mkdir_p(File.dirname(target))
File.write(target, md)
puts "Rendered #{artifact} markdown to #{target}"
