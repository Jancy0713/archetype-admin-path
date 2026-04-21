#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

source = ARGV[0]
target = ARGV[1]

if source.nil?
  warn "Usage: ruby scripts/init/render_prd_bootstrap_context.rb <bootstrap_plan.yml> [target.md]"
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
  warn "Cannot render prd bootstrap context from invalid bootstrap_plan: #{source}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

meta = data["meta"] || {}
context = data["prd_bootstrap_context"] || {}
target ||= context.dig("output_artifacts", "target_path")

if target.to_s.strip.empty?
  warn "Target path is empty. Provide it as the second argument or set prd_bootstrap_context.output_artifacts.target_path."
  exit 1
end

def numbered_lines(items)
  Array(items).each_with_index.map { |item, index| "#{index + 1}. #{item}" }.join("\n")
end

content = <<~MD
  # PRD Bootstrap Context

  > 来源步骤：`#{meta['step_id']}`
  > 当前产物定位：`init -> prd` 的基础 PRD 输入文档

  ## 1. 文档目标

  #{numbered_lines(context["document_goal"])}

  ## 2. 项目概况

  #{numbered_lines(context["project_overview"])}

  ## 3. 已确认基础前提

  #{numbered_lines(context["confirmed_foundation"])}

  ## 4. 基础模块需求

  #{Array(context["priority_modules"]).map { |item|
    [
      "### #{item['name']}（#{item['module_id']}）",
      "",
      "- 模块目标：#{item['objective']}",
      "- 需求清单：",
      numbered_lines(item["requirements"]).lines.map { |line| "  #{line}" }.join
    ].join("\n")
  }.join("\n\n")}

  ## 5. 本轮 PRD 关注点

  #{numbered_lines(context["prd_focus"])}

  ## 6. 备注

  #{numbered_lines(context["notes"])}

  ## 7. reviewer 检查点

  #{numbered_lines(context["reviewer_focus"])}
MD

FileUtils.mkdir_p(File.dirname(target))
File.write(target, content)
puts "Rendered prd bootstrap context markdown to #{target}"
