#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

source = ARGV[0]
target = ARGV[1]

if source.nil?
  warn "Usage: ruby scripts/init/render_project_conventions.rb <bootstrap_plan.yml> [target.md]"
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
  warn "Cannot render project conventions from invalid bootstrap_plan: #{source}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

meta = data["meta"] || {}
conventions = data["project_conventions"] || {}
source_of_truth = conventions["source_of_truth"] || {}
target ||= conventions.dig("output_artifacts", "target_path")

if target.to_s.strip.empty?
  warn "Target path is empty. Provide it as the second argument or set project_conventions.output_artifacts.target_path."
  exit 1
end

highlights = Array(source_of_truth["design_seed_highlights"])
style_rule = highlights.find { |item| item.start_with?("风格方案：") }.to_s.sub("风格方案：", "")
theme_rule = highlights.find { |item| item.start_with?("主题模式：") }.to_s.sub("主题模式：", "")
density_rule = highlights.find { |item| item.start_with?("信息密度：") }.to_s.sub("信息密度：", "")
navigation_rule = highlights.find { |item| item.start_with?("导航原则：") }.to_s.sub("导航原则：", "")
page_pattern_rule = highlights.find { |item| item.start_with?("页面模式：") }.to_s.sub("页面模式：", "")
component_rule = highlights.find { |item| item.start_with?("组件原则：") }.to_s.sub("组件原则：", "")
notes = Array(conventions["notes"])
reviewer_focus = Array(conventions["reviewer_focus"])
design_seed_path = Array(meta["source_paths"]).find { |path| path.to_s.include?("design_seed") }
design_seed = design_seed_path ? InitFlow::ArtifactUtils.load_yaml(design_seed_path) : {}
design_context = design_seed["design_context"] || {}
theme_strategy = design_seed["theme_strategy"] || {}
token_baseline = design_seed["token_baseline"] || {}
layout_principles = design_seed["layout_principles"] || {}
spacing_scale = Array(token_baseline["spacing_scale"])
radius_scale = Array(token_baseline["radius_scale"])
shadow_scale = Array(token_baseline["shadow_scale"])
typography_scale = Array(token_baseline["typography_scale"])
color_roles = Array(token_baseline["color_roles"])
page_patterns = Array(layout_principles["page_patterns"])
component_principles = Array(layout_principles["component_principles"])
prohibited_patterns = Array(layout_principles["prohibited_patterns"])

def numbered_lines(items, indent: "")
  Array(items).each_with_index.map { |item, index| "#{indent}#{index + 1}. #{item}" }.join("\n")
end

def token_lines(items)
  Array(items).map do |item|
    token = item["token"] || item["role"]
    value = item["value"]
    note = item["note"] || item["usage"]
    "- `#{token}` = `#{value}`：#{note}"
  end.join("\n")
end

content = <<~MD
  # Project Conventions

  > 来源步骤：`#{meta['step_id']}`
  > 更新依据：`#{Array(source_of_truth['primary_inputs']).join(' / ')}`
  > design_seed 来源：`#{design_seed_path}`
  > 固定项目路径：`docs/project/project-conventions.md`

  ## 1. 文档定位

  1. 本文档是当前项目的长期规则来源。
  2. 后续新建 PRD run、模块开发、review 默认读取项目内固定路径 `docs/project/project-conventions.md`。
  3. 如需整体修改主题、组件体系、工程基线，进入初始化变更流程，而不是在普通 PRD 中临时重写。

  ## 2. 设计风格总则

  1. 固定风格方案：#{style_rule}
  2. 风格来源基线：#{design_context['current_baseline']}
  3. 固定主题模式：#{theme_rule}
  4. 暗色模式策略：#{theme_strategy['supports_dark_mode']}
  5. 固定信息密度：#{density_rule}
  6. 后续页面默认继承以上规则，不再各模块自行重定一套视觉语言。

  ## 3. 导航与应用骨架规则

  1. 固定导航原则：#{navigation_rule}
  2. 固定 app shell：
  #{numbered_lines([layout_principles['app_shell']], indent: "   ")}
  3. 页面内部不再自建第二套主导航。
  4. 全局壳层、页头容器和正文骨架默认继承统一应用骨架。

  ## 4. Theme / Token 规则

  ### 4.1 Spacing

  #{token_lines(spacing_scale)}

  ### 4.2 Radius

  #{token_lines(radius_scale)}

  ### 4.3 Shadow

  #{token_lines(shadow_scale)}

  ### 4.4 Typography

  #{token_lines(typography_scale)}

  ### 4.5 Color Roles

  #{token_lines(color_roles)}

  ## 5. 页面实现规则

  #{numbered_lines(page_patterns + [
    "页面实现先复用统一容器和页面模式，再补模块私有组合。",
    "不为了单个模块重写导航、全局壳层或页面级布局规则。"
  ])}

  ## 6. 组件风格与封装规则

  #{numbered_lines(component_principles)}

  ## 7. 禁止事项

  #{numbered_lines(prohibited_patterns)}

  ## 8. 使用方式

  1. PRD 阶段先读取本文档，再开始页面模式、组件复用和视觉实现相关设计。
  2. 设计/开发阶段持续将本文档作为项目级视觉与交互规则输入。
  3. 如需补充新的项目级视觉规则，应先判断是否属于当前项目长期特征，再更新本文档。

MD

FileUtils.mkdir_p(File.dirname(target))
File.write(target, content)
puts "Rendered project conventions markdown to #{target}"
