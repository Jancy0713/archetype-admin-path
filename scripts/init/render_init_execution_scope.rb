#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

source = ARGV[0]
target = ARGV[1]

if source.nil?
  warn "Usage: ruby scripts/init/render_init_execution_scope.rb <bootstrap_plan.yml> [target.md]"
  exit 1
end

unless File.exist?(source)
  warn "File not found: #{source}"
  exit 1
end

begin
  data = InitFlow::ArtifactUtils.load_yaml(source)
rescue ArgumentError => e
  warn e.message
  exit 2
end

errors = InitFlow::ArtifactUtils.validate_artifact("bootstrap_plan", data, artifact_path: source)
unless errors.empty?
  warn "Cannot render init execution scope from invalid bootstrap_plan: #{source}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

meta = data["meta"] || {}
scope = data["init_execution_scope"] || {}
target ||= scope.dig("output_artifacts", "target_path")

if target.to_s.strip.empty?
  warn "Target path is empty. Provide it as the second argument or set init_execution_scope.output_artifacts.target_path."
  exit 1
end

def numbered_lines(items)
  Array(items).each_with_index.map { |item, index| "#{index + 1}. #{item}" }.join("\n")
end

def preset_pack_sections(items)
  Array(items).map do |item|
    [
      "### #{item['name']}（#{item['pack_id']}）",
      "",
      "- 启用条件：#{item['enabled_when']}",
      "- 预制动作：#{Array(item['preset_actions']).join('；')}",
      "- 建议命令：#{Array(item['install_commands']).join('；')}",
      "- 代码落位：#{Array(item['generated_files']).join('；')}",
      "- AI 补强：#{Array(item['ai_followups']).join('；')}"
    ].join("\n")
  end.join("\n\n")
end

def conditional_parameter_sections(items)
  Array(items).map do |item|
    [
      "### #{item['parameter_id']}",
      "",
      "- 来源字段：#{item['source_field']}",
      "- 当前值：#{item['current_value']}",
      "- 影响范围：#{Array(item['effect_on_scope']).join('；')}"
    ].join("\n")
  end.join("\n\n")
end

content = <<~MD
  # Init Execution Scope

  > 来源步骤：`#{meta['step_id']}`

  ## 1. 文档定位

  1. 本文档用于指导第8步初始化代码执行。
  2. 本文档只约束纯工程初始化范围，不替代后续 PRD。
  3. 如某项内容需要具体业务 contract、接口字段或业务页面细节，应停止并转入后续 PRD 流程。

  ## 2. 预制能力包

  #{preset_pack_sections(scope["preset_capability_packs"])}

  ## 3. 条件参数

  #{conditional_parameter_sections(scope["conditional_parameters"])}

  ## 4. 命令蓝图

  #{numbered_lines(scope["command_blueprints"])}

  ## 5. 代码与文件落位

  #{numbered_lines(scope["code_artifacts"])}

  ## 6. AI 补强动作

  #{numbered_lines(scope["ai_followups"])}

  ## 7. 允许执行

  #{numbered_lines(scope["allowed_work"])}

  ## 8. 明确不做

  #{numbered_lines(scope["excluded_work"])}

  ## 9. 必须交付

  #{numbered_lines(scope["deliverables"])}

  ## 10. 完成标准

  #{numbered_lines(scope["completion_criteria"])}

  ## 11. reviewer 检查点

  #{numbered_lines(scope["reviewer_focus"])}
MD

FileUtils.mkdir_p(File.dirname(target))
File.write(target, content)
puts "Rendered init execution scope markdown to #{target}"
