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

def presence(value)
  return nil if value.nil?
  return nil if value.respond_to?(:empty?) && value.empty?

  value
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

def alphabet_label(index)
  alphabet = ("a".."z").to_a
  return alphabet[index] if index < alphabet.length

  prefix = alphabet[(index / alphabet.length) - 1]
  suffix = alphabet[index % alphabet.length]
  "#{prefix}#{suffix}"
end

def option_label_map(options)
  Array(options).each_with_index.to_h do |option, index|
    [option["value"], alphabet_label(index)]
  end
end

def choice_type_label(allow_multiple)
  allow_multiple ? "可多选" : "单选"
end

def render_option_lines(options, recommended:, default_value: nil)
  options = Array(options).compact
  return "- 暂无候选项" if options.empty?

  labels = option_label_map(options)
  lines = options.each_with_index.map do |option, index|
    marker = alphabet_label(index)
    text = "#{marker}. #{format_value(option['label'])}"
    description = presence(option["description"])
    text += "：#{description}" if description
    text
  end

  recommended_marker = labels[recommended]
  default_marker = labels[default_value]

  if recommended_marker
    selected = options.find { |option| option["value"] == recommended }
    lines << ""
    lines << "推荐：`#{recommended_marker}` #{selected['label']}"
  end

  if default_marker && default_marker != recommended_marker
    selected = options.find { |option| option["value"] == default_value }
    lines << "默认：`#{default_marker}` #{selected['label']}"
  end

  lines.join("\n")
end

def append_custom_answer_hint(lines, allow_custom_answer, allow_multiple)
  return lines unless allow_custom_answer

  text = allow_multiple ? "也可回复自定义组合或补充项，例如：`[a,c,自定义: xxx]`" : "如现有选项都不合适，可回复：`[自定义: xxx]`"
  lines << text
  lines
end

def render_project_overview(profile)
  lines = []
  summary = presence(profile["project_summary"])
  lines << summary if summary
  lines << ""
  lines << "- 系统类型：#{format_value(profile['system_type'])}" if presence(profile["system_type"])
  lines << "- 产品类型：#{format_value(profile['product_type'])}" if presence(profile["product_type"])
  lines << "- 商业模式：#{format_value(profile['business_mode'])}" if presence(profile["business_mode"])
  lines << "- 目标用户：#{format_value(profile['target_users'])}" if presence(profile["target_users"])
  lines << "- 主要终端：#{format_value(profile['primary_clients'])}" if presence(profile["primary_clients"])
  lines << "- 目标市场：#{format_value(profile['target_market'])}" if presence(profile["target_market"])
  lines.join("\n")
end

def option_label(options, value)
  matched = Array(options).find { |option| option["value"] == value }
  matched && matched["label"]
end

def question_summary_label(question)
  labels = {
    "system_type" => "系统类型",
    "audience_type" => "主要服务对象",
    "default_region" => "默认地区",
    "default_language" => "默认语言",
    "primary_clients" => "主要使用端",
    "core_usage_scenario" => "核心使用场景"
  }

  labels[question["question_id"]] || question["question"]
end

def render_required_questions(stage)
  questions = Array(stage["required_questions"]).compact
  return "- 当前阶段无固定判断。" if questions.empty?

  questions.map.with_index(1) do |question, index|
    recommended = option_label(question["options"], question["recommended"]) || presence(question["recommended"]) || "待补充"
    lines = []
    lines << "- #{question_summary_label(question)}：#{recommended}"
    reason = presence(question["reason"])
    lines << "  依据：#{reason}" if reason
    lines.join("\n")
  end.join("\n")
end

def confirmation_item_id(step_id, index)
  "#{step_id}-#{format('%02d', index)}"
end

def render_key_decisions(stage, step_id)
  decisions = Array(stage["key_decisions"]).compact
  return ["- 当前阶段没有待人工确认的关键决策。", 0] if decisions.empty?

  body = decisions.map.with_index(1) do |decision, index|
    item_id = confirmation_item_id(step_id, index)
    lines = []
    lines << "### 问题#{index}：#{decision['question']}【#{choice_type_label(decision['allow_multiple'])}】"
    lines << ""
    lines << "编号：`#{item_id}`"
    lines << ""
    lines << append_custom_answer_hint(
      render_option_lines(decision["options"], recommended: decision["recommended"], default_value: decision["default_if_no_answer"]).split("\n"),
      decision["allow_custom_answer"],
      decision["allow_multiple"]
    ).join("\n")
    explanation = presence(decision["explanation"])
    lines << "" if explanation
    lines << "说明：#{explanation}" if explanation
    lines.join("\n")
  end.join("\n\n")

  [body, decisions.length]
end

def render_mandatory_open_questions(stage, step_id, start_index:)
  open_questions = Array(stage.dig("open_questions", "p0")).compact
  return "- 当前阶段没有必须补充的开放问题。" if open_questions.empty?

  open_questions.map.with_index(1) do |question, index|
    item_index = start_index + index
    item_id = confirmation_item_id(step_id, item_index)
    lines = []
    lines << "### 必须回复 #{index}：#{question['question']}"
    lines << ""
    lines << "编号：`#{item_id}`"
    lines << ""
    lines << append_custom_answer_hint(
      render_option_lines(question["options"], recommended: question["recommended"]).split("\n"),
      question["allow_custom_answer"],
      question["allow_multiple"]
    ).join("\n")
    lines << ""
    lines << "说明：#{question['explanation']}"
    lines << "- 该项必须明确回复；未确认前，AI 不应进入下一阶段。"
    lines.join("\n")
  end.join("\n\n")
end

def render_recommended_defaults(stage)
  defaults = Array(stage["recommended_defaults"]).compact
  return "- 当前阶段没有可直接沿用的推荐默认项。" if defaults.empty?

  defaults.map do |item|
    lines = []
    lines << "### #{item['topic']}"
    lines << ""
    lines << "- 推荐默认值：#{format_value(item['default_value'])}" if presence(item["default_value"])
    lines << "- 为什么这样建议：#{format_value(item['rationale'])}" if presence(item["rationale"])
    lines << "- 可替代方案：#{format_value(item['alternatives'])}" if presence(item["alternatives"])
    lines << "- 什么时候再升级：#{format_value(item['upgrade_condition'])}" if presence(item["upgrade_condition"])
    lines.join("\n")
  end.join("\n\n")
end

def render_open_questions(stage)
  open_questions = stage["open_questions"] || {}
  priorities = %w[p1 p2]
  lines = priorities.map do |priority|
    items = Array(open_questions[priority]).compact
    next if items.empty?

    rendered = items.map do |item|
      text = "- #{item['question']}"
      explanation = presence(item["explanation"])
      text += "\n  说明：#{explanation}" if explanation
      text
    end.join("\n")
    "### #{priority.upcase}\n\n#{rendered}"
  end.compact

  lines.empty? ? "- 当前阶段没有额外未决问题。" : lines.join("\n\n")
end

def render_next_stage_preview(stages, current_stage_id)
  upcoming = Array(stages).drop_while { |stage| stage["stage_id"] != current_stage_id }.drop(1)
  return "- 当前已是最后一个阶段。" if upcoming.empty?

  upcoming.map do |stage|
    "- #{stage['stage_name']}（#{stage['stage_id']}）：#{format_value(stage['objective'])}"
  end.join("\n")
end

def render_confirmation_reply_guide(step_id, required_open_questions_exist:)
  lines = []
  lines << "- 如无修改，直接回复：`按推荐继续`"
  lines << "- 如需修改，使用下面格式："
  lines << ""
  lines << "```md"
  lines << "【修改项】"
  lines << "编号 #{step_id}-01 改为 [b]"
  lines << "编号 #{step_id}-02 改为 [a,c]"
  lines << "编号 #{step_id}-03 改为 [自定义: 仅商家端后台 + 渠道代理协作端]"
  lines << "编号 #{step_id}-04 回复：首期仅中国大陆，不做跨境"
  lines << ""
  lines << "【其余项】"
  lines << "其余按推荐"
  lines << "```"

  if required_open_questions_exist
    lines << ""
    lines << "- 对“必须回复”的开放问题，不能只写“按推荐继续”，需要按编号给出明确文字答案。"
  end

  lines.join("\n")
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
  meta = data["meta"] || {}
  profile = data["project_profile"] || {}
  progress = data["stage_progress"] || {}
  stages = Array(data["stages"]).compact
  current_stage = stages.find { |stage| stage["stage_id"] == progress["current_stage"] } || stages.first || {}
  step_id = presence(meta["step_id"]) || "init-xx"
  key_decisions_body, key_decision_count = render_key_decisions(current_stage, step_id)
  mandatory_open_body = render_mandatory_open_questions(current_stage, step_id, start_index: key_decision_count)
  mandatory_open_exists = Array(current_stage.dig("open_questions", "p0")).compact.any?

  md << "# #{presence(meta['title']) || 'Project Profile'}\n\n"
  md << "> 当前步骤：`#{format_value(meta['step_id'])}`  \n" if presence(meta["step_id"])
  md << "> 当前阶段：`#{format_value(current_stage['stage_id'])}` / #{format_value(current_stage['stage_name'])}  \n" if presence(current_stage["stage_id"])
  md << "> 最近更新时间：`#{format_value(meta['updated_at'])}`\n\n" if presence(meta["updated_at"])
  md << section("项目概览", render_project_overview(profile))
  md << section("当前阶段结论", [
    presence(current_stage["summary"]),
    "",
    "- 本阶段目标：#{format_value(current_stage['objective'])}",
    "- 当前状态：#{format_value(current_stage['status'])}",
    "- 是否已人工确认：#{current_stage.dig('confirmation', 'confirmed') ? '是' : '否'}"
  ].compact.join("\n"))
  md << section("AI 当前判断", render_required_questions(current_stage))
  md << section("待你确认的关键问题", key_decisions_body)
  md << section("必须明确回复的问题", mandatory_open_body)
  md << section("推荐默认项", render_recommended_defaults(current_stage))
  md << section("如何回复本轮确认", render_confirmation_reply_guide(step_id, required_open_questions_exist: mandatory_open_exists))
  md << section("仍待补充的问题", render_open_questions(current_stage))
  md << section("后续阶段预览", render_next_stage_preview(stages, current_stage["stage_id"]))
  md << section("推进状态", render_stage_progress(progress))
  md << section("是否可进入 Baseline", key_value(data["decision"]))
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
  md << section("P0", Array(data.dig("open_questions", "p0")).map { |item| "- #{item['question']}" }.join("\n"))
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
