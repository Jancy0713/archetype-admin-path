#!/usr/bin/env ruby
require "fileutils"

require_relative "artifact_utils"

artifact = ARGV[0]
source = ARGV[1]
target = ARGV[2]

if artifact.nil? || source.nil? || target.nil?
  warn "Usage: ruby scripts/init/render_artifact.rb <project_profile|review|baseline|design_seed|bootstrap_plan|change_request> <source.yml> <target.md>"
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

def optional_section(title, body)
  body = presence(body)
  return "" unless body

  section(title, body)
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

def field_section_label(key)
  {
    "project_summary" => "项目基线来源",
    "identity_access" => "租户与权限来源",
    "ui_foundation" => "体验基线来源",
    "platform_defaults" => "平台能力来源"
  }[key] || key
end

def enabled_platform_capabilities(platform_defaults)
  items = []
  items << "上传" unless platform_defaults["upload"].to_s.include?("不")
  items << "导出" unless platform_defaults["export"].to_s.include?("不")
  items << "通知" unless platform_defaults["notifications"].to_s.include?("不")
  items << "关键操作审计" unless platform_defaults["audit_log"].to_s.include?("不")
  items << "简体中文单语言" if platform_defaults["i18n"].to_s.include?("不")
  items
end

def unique_compact(items)
  Array(items).map { |item| item.to_s.strip }.reject(&:empty?).uniq
end

def slugify_ascii(text)
  ascii = text.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
  ascii.empty? ? nil : ascii
end

def bootstrap_name_seed(data)
  meta_title = data.dig("meta", "title").to_s
  seed = meta_title.sub(/\s*-\s*初始化底座计划\z/, "").sub(/初始化基线\z/, "").strip
  return seed unless seed.empty?

  project_overview = Array(data.dig("prd_bootstrap_context", "project_overview"))
  positioning = project_overview.find { |item| item.start_with?("项目定位：") }.to_s.sub("项目定位：", "").strip
  positioning
end

def bootstrap_project_name_candidates(data)
  seed = bootstrap_name_seed(data)
  normalized = seed.dup
  normalized = normalized.gsub("系统商家端", "商家端")
  normalized = normalized.gsub("商家端系统", "商家端")
  normalized = normalized.gsub("AI视频生成", "AI视频")
  normalized = normalized.gsub("后台", "管理后台")
  base = normalized.empty? ? "项目管理后台" : normalized

  candidates = []
  candidates << "#{base}管理系统" unless base.end_with?("管理系统")
  candidates << "#{base}管理后台" unless base.end_with?("管理后台")
  candidates << "#{base}工作台" unless base.end_with?("工作台")
  unique_compact(candidates).first(3)
end

def bootstrap_slug_candidates(data)
  project_overview = Array(data.dig("prd_bootstrap_context", "project_overview")).join(" ")
  audience_token = project_overview.include?("商家") ? "merchant" : "admin"
  domain_token =
    if project_overview.include?("AI") || data.dig("meta", "title").to_s.include?("AI")
      "ai-video"
    else
      "app"
    end

  candidates = [
    "#{audience_token}-#{domain_token}-admin",
    "#{domain_token}-#{audience_token}-admin",
    "#{audience_token}-#{domain_token}-workspace"
  ]

  unique_compact(candidates.map { |item| slugify_ascii(item) }).first(3)
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

def question_summary_label(item)
  labels = {
    "system_type" => "系统类型",
    "audience_type" => "主要服务对象",
    "default_region" => "默认地区",
    "default_language" => "默认语言",
    "primary_clients" => "主要使用端",
    "core_usage_scenario" => "核心使用场景",
    "tenant_model" => "租户模型",
    "tenant_subject" => "租户主体",
    "platform_tenant_layers" => "平台与租户层级",
    "org_structure_needed" => "组织结构需求",
    "org_structure_purpose" => "组织结构用途",
    "governance_boundary" => "治理边界",
    "login_method" => "登录方式",
    "account_identifier" => "账号唯一标识",
    "account_system" => "账号体系",
    "cross_tenant_account" => "跨租户账号",
    "permission_model" => "权限模型",
    "privileged_roles" => "高权限角色",
    "member_permission_basis" => "普通成员权限分配方式",
    "visual_direction" => "UI 风格方向",
    "ui_style_recipe" => "UI 风格方案",
    "theme_mode" => "主题模式",
    "navigation_style" => "导航方式",
    "information_density" => "信息密度偏好",
    "notifications_needed" => "通知能力",
    "audit_log_needed" => "审计日志能力",
    "export_needed" => "导出能力",
    "upload_needed" => "上传能力",
    "i18n_needed" => "国际化/多语言支持"
  }

  labels[item["item_id"]] || item["question"]
end

def choice_type_label(answer_mode)
  return "可多选" if answer_mode == "multi_choice"
  return "文本" if answer_mode == "text"

  "单选"
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

def render_confirmation_block(title:, item_id:, item:)
  answer_mode = item["answer_mode"]
  lines = []
  lines << "### #{title}【#{choice_type_label(answer_mode)}】"
  lines << ""
  lines << "编号：`#{item_id}`"
  lines << ""

  if answer_mode == "text"
    lines << "- 请直接用文字回复。"
    lines << "- 推荐回答方向：#{item['recommended']}" if presence(item["recommended"])
  else
    lines << append_custom_answer_hint(
      render_option_lines(item["options"], recommended: item["recommended"], default_value: item["default_if_no_answer"]).split("\n"),
      item["allow_custom_answer"],
      answer_mode == "multi_choice"
    ).join("\n")
  end

  reason = presence(item["reason"])
  if reason
    lines << ""
    lines << "说明：#{reason}"
  end

  lines.join("\n")
end

def render_confirmation_items(items, step_id, title_prefix:, empty_text:, note: nil, start_index: 0)
  items = Array(items).compact
  return [empty_text, start_index] if items.empty?

  body = items.map.with_index(1) do |item, offset|
    index = start_index + offset
    title = "#{title_prefix}#{offset}：#{question_summary_label(item)}"
    block = render_confirmation_block(title: title, item_id: "#{step_id}-#{format('%02d', index)}", item: item)
    note ? "#{block}\n\n- #{note}" : block
  end.join("\n\n")

  [body, start_index + items.length]
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

def render_next_stage_preview(stages, current_stage_id)
  upcoming = Array(stages).drop_while { |stage| stage["stage_id"] != current_stage_id }.drop(1)
  return nil if upcoming.empty?

  upcoming.map do |stage|
    "- #{stage['stage_name']}（#{stage['stage_id']}）：#{format_value(stage['objective'])}"
  end.join("\n")
end

def render_baseline_confirmation_items(items)
  items = Array(items).compact
  return nil if items.empty?

  groups = [
    ["重点确认项", items.select { |item| item["level"] == "primary" }],
    ["次要确认项", items.select { |item| item["level"] == "secondary" }],
    ["必须明确回复的问题", items.select { |item| item["level"] == "required" }]
  ]

  groups.map do |title, grouped_items|
    next if grouped_items.empty?

    lines = ["### #{title}", ""]
    grouped_items.each do |item|
      lines << "- #{question_summary_label(item)}：#{item['question']}"
      lines << "  建议：#{format_value(item['recommended'])}" if presence(item["recommended"])
      lines << "  说明：#{format_value(item['reason'])}" if presence(item["reason"])
      lines << "  候选项：#{Array(item['options']).map { |option| option['label'] }.join('，')}" if Array(item["options"]).any?
    end
    lines.join("\n")
  end.compact.join("\n\n")
end

def render_baseline_summary(data)
  sections = []

  project_summary = data["project_summary"] || {}
  sections << [
    "### 项目基线",
    "",
    "- 产品形态：#{format_value(project_summary['product_type'])}",
    "- 商业模式：#{format_value(project_summary['business_mode'])}",
    "- 目标市场：#{format_value(project_summary['target_market'])}",
    "- 默认地区与语言：#{format_value(project_summary['default_region'])} / #{format_value(project_summary['default_language'])}"
  ].join("\n")

  identity_access = data["identity_access"] || {}
  sections << [
    "### 租户与权限",
    "",
    "- 租户模型：#{format_value(identity_access['tenant_model'])}",
    "- 登录方式：#{format_value(identity_access['login_methods'])}",
    "- 账号标识：#{format_value(identity_access['account_identifier'])}",
    "- 账号模型：#{format_value(identity_access['account_model'])}",
    "- 权限模型：#{format_value(identity_access['permission_model'])}"
  ].join("\n")

  ui_foundation = data["ui_foundation"] || {}
  sections << [
    "### 体验基线",
    "",
    "- 视觉方向：#{format_value(ui_foundation['visual_direction'])}",
    "- UI 风格方案：#{format_value(ui_foundation['style_recipe'])}",
    "- 主题模式：#{format_value(ui_foundation['theme_mode'])}",
    "- 信息密度：#{format_value(ui_foundation['density'])}",
    "- 导航方式：#{format_value(ui_foundation['navigation_style'])}"
  ].join("\n")

  platform_defaults = data["platform_defaults"] || {}
  sections << [
    "### 平台默认能力",
    "",
    "- 上传：#{format_value(platform_defaults['upload'])}",
    "- 导出：#{format_value(platform_defaults['export'])}",
    "- 通知：#{format_value(platform_defaults['notifications'])}",
    "- 审计日志：#{format_value(platform_defaults['audit_log'])}",
    "- 国际化：#{format_value(platform_defaults['i18n'])}"
  ].join("\n")

  sections.join("\n\n")
end

def render_design_seed_summary(data)
  sections = []
  design_context = data["design_context"] || {}
  sections << [
    "### 生成上下文",
    "",
    "- 当前 baseline：#{format_value(design_context['current_baseline'])}",
    "- 选定风格方案：#{format_value(design_context['selected_style_recipe'])}",
    "- 参考来源：#{format_value(design_context['source_style_reference'])}",
    "- 生成策略：#{format_value(design_context['generation_policy'])}"
  ].join("\n")

  theme_strategy = data["theme_strategy"] || {}
  sections << [
    "### 主题策略",
    "",
    "- 默认模式：#{format_value(theme_strategy['default_mode'])}",
    "- 深色支持：#{format_value(theme_strategy['supports_dark_mode'])}",
    "- 信息密度策略：#{format_value(theme_strategy['density_strategy'])}",
    "- 导航原则：#{format_value(theme_strategy['navigation_principle'])}"
  ].join("\n")

  token_baseline = data["token_baseline"] || {}
  sections << [
    "### Token 基线",
    "",
    "#### 间距",
    "",
    bullet_list(Array(token_baseline["spacing_scale"]).map { |item| "#{item['token']} = #{item['value']}：#{item['note']}" }),
    "",
    "#### 圆角",
    "",
    bullet_list(Array(token_baseline["radius_scale"]).map { |item| "#{item['token']} = #{item['value']}：#{item['note']}" }),
    "",
    "#### 阴影",
    "",
    bullet_list(Array(token_baseline["shadow_scale"]).map { |item| "#{item['token']} = #{item['value']}：#{item['note']}" }),
    "",
    "#### 字体",
    "",
    bullet_list(Array(token_baseline["typography_scale"]).map { |item| "#{item['token']} = #{item['value']}：#{item['note']}" }),
    "",
    "#### 颜色角色",
    "",
    bullet_list(Array(token_baseline["color_roles"]).map { |item| "#{item['role']} = #{item['value']}：#{item['usage']}" })
  ].join("\n")

  layout_principles = data["layout_principles"] || {}
  sections << [
    "### 布局与组件原则",
    "",
    "- App Shell：#{format_value(layout_principles['app_shell'])}",
    "",
    "#### 页面模式",
    "",
    bullet_list(layout_principles['page_patterns']),
    "",
    "#### 组件原则",
    "",
    bullet_list(layout_principles['component_principles']),
    "",
    "#### 禁止项",
    "",
    bullet_list(layout_principles['prohibited_patterns'])
  ].join("\n")

  sections.join("\n\n")
end

def render_bootstrap_plan_summary(data)
  sections = []
  scope = data["init_execution_scope"] || {}
  scope_outputs = scope["output_artifacts"] || {}
  scope_preview_path = scope_outputs["target_path"]
  sections << [
    "### 本次确认材料",
    "",
    "- `#{format_value(scope_preview_path)}`：确认第8步允许做什么、不做什么、交付什么，以及做到什么程度算完成。"
  ].join("\n")

  conventions = data["project_conventions"] || {}
  outputs = conventions["output_artifacts"] || {}
  conventions_preview_path = "rendered/init-07.project-conventions.md"
  sections << [
    "### 项目长期规则",
    "",
    "- 当前确认材料：`#{conventions_preview_path}`",
    "- 后续项目固定路径：`#{format_value(outputs['target_path'])}`",
    "- 用途：沉淀项目长期复用的视觉、页面模式、组件封装与禁止项规则；后续 PRD、开发、review 默认读取项目固定路径。"
  ].join("\n")

  prd_context = data["prd_bootstrap_context"] || {}
  prd_outputs = prd_context["output_artifacts"] || {}
  sections << [
    "### 下一轮 PRD 交接",
    "",
    "- 当前确认材料：`#{format_value(prd_outputs['target_path'])}`",
    "- 用途：给下一轮 PRD 提供基础输入，承接项目概况、已确认前提与基础模块方向；它不是项目长期规则文件。"
  ].join("\n")

  sections << [
    "### 后续使用方式",
    "",
    "- `init-08` 执行时，直接以 `#{format_value(scope_preview_path)}` 作为工程初始化范围依据。",
    "- 工程初始化完成后，把已确认的长期规则写入 `#{format_value(outputs['target_path'])}`。",
    "- 下一轮 `prd` 直接继承 `#{format_value(prd_outputs['target_path'])}` 与 `#{format_value(outputs['target_path'])}`。"
  ].join("\n")

  project_name_candidates = bootstrap_project_name_candidates(data)
  slug_candidates = bootstrap_slug_candidates(data)
  recommended_project_name = project_name_candidates.first || "项目管理系统"
  recommended_slug = slug_candidates.first || "project-admin"
  sections << [
    "### 执行参数确认",
    "",
    "- 这一步仍需人工确认项目名称与目录 slug；如无异议，默认按推荐项进入 `init-08`。",
    "- 项目名称候选：",
    "  `a.` `#{project_name_candidates[0]}`（推荐）",
    "  `b.` `#{project_name_candidates[1] || recommended_project_name}`",
    "  `c.` `#{project_name_candidates[2] || recommended_project_name}`",
    "- 目录 slug 候选：",
    "  `a.` `#{slug_candidates[0]}`（推荐）",
    "  `b.` `#{slug_candidates[1] || recommended_slug}`",
    "  `c.` `#{slug_candidates[2] || recommended_slug}`",
    "- 默认初始化位置：当前工作区根目录下创建目录 `#{recommended_slug}`，该目录本身就是项目根目录。",
    "- 如需调整，可直接回复：`项目名称改为 [b]`、`项目名称改为 [自定义: xxx]`、`目录名称改为 [b]`、`目录名称改为 [自定义: xxx]`。"
  ].join("\n")

  sections << [
    "### 人工确认方式",
    "",
    "- 这一步不是继续答题，而是确认第8步执行范围、项目长期规则和下一轮 PRD 输入是否都足够清楚。",
    "- 重点检查：scope 是否越界，长期规则是否适合沉淀到项目固定路径，PRD 输入是否足以支撑下一轮展开。",
    "- 如无修改，回复“bootstrap_plan 确认，继续”即可。",
    "- 如需修改，直接指出要改的执行范围、长期规则或 PRD 交接边界。"
  ].join("\n")

  sections.join("\n\n")
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
  confirmation_items = Array(current_stage["confirmation_items"]).compact
  primary_items = confirmation_items.select { |item| item["level"] == "primary" }
  secondary_items = confirmation_items.select { |item| item["level"] == "secondary" }
  required_items = confirmation_items.select { |item| item["level"] == "required" }

  primary_body, next_index = render_confirmation_items(
    primary_items,
    step_id,
    title_prefix: "问题",
    empty_text: "- 当前阶段没有重点确认项。"
  )
  secondary_body, next_index = render_confirmation_items(
    secondary_items,
    step_id,
    title_prefix: "次要确认项",
    empty_text: "- 当前阶段没有次要确认项。",
    start_index: next_index
  )
  required_body, = render_confirmation_items(
    required_items,
    step_id,
    title_prefix: "必须回复",
    empty_text: "- 当前阶段没有必须补充的项。",
    note: "该项必须明确回复；未确认前，AI 不应进入下一阶段。",
    start_index: next_index
  )

  md << "# #{presence(meta['title']) || 'Project Profile'}\n\n"
  md << "> 当前步骤：`#{format_value(meta['step_id'])}`  \n" if presence(meta["step_id"])
  md << "> 当前阶段：`#{format_value(current_stage['stage_id'])}` / #{format_value(current_stage['stage_name'])}  \n" if presence(current_stage["stage_id"])
  md << "> 最近更新时间：`#{format_value(meta['updated_at'])}`\n\n" if presence(meta["updated_at"])
  md << section("项目概览", render_project_overview(profile))
  md << section("当前阶段结论", [
    presence(current_stage["summary"]),
    "",
    "- 本阶段目标：#{format_value(current_stage['objective'])}"
  ].compact.join("\n"))
  md << section("重点确认项", primary_body)
  md << section("次要确认项（当前按推荐收敛，如需可改）", secondary_body)
  md << section("必须明确回复的问题", required_body)
  next_stage_preview = if progress["profile_ready"] == true || data.dig("decision", "allow_baseline") == true
    "- 本轮确认完成后，可以进入 `init-05 baseline` 汇总定稿。"
  else
    render_next_stage_preview(stages, current_stage["stage_id"])
  end
  md << optional_section("下一步", next_stage_preview)
when "review"
  md << "# Init Review\n\n"
  md << section("Meta", key_value(data["meta"]))
  md << section("Current Stage Review", key_value(data["current_stage_review"]))
  md << section("Issues", bullet_list(data.dig("findings", "issues")))
  md << section("Missing Info", bullet_list(data.dig("findings", "missing_info")))
  md << section("P0", bullet_list(data.dig("findings", "p0")))
  md << section("Decision", key_value(data["decision"]))
when "baseline"
  meta = data["meta"] || {}
  md << "# #{presence(meta['title']) || 'Initialization Baseline'}\n\n"
  md << "> 当前步骤：`#{format_value(meta['step_id'])}`  \n" if presence(meta["step_id"])
  md << "> 最近更新时间：`#{format_value(meta['updated_at'])}`\n\n" if presence(meta["updated_at"])
  md << section("本次定稿内容", render_baseline_summary(data))
  md << section("人工确认方式", [
    "- 这一步不是继续回答 01-04 的问题，而是确认这份 baseline 是否已经足够准确、足够细，能作为后续 design_seed / bootstrap / PRD 的默认输入。",
    "- 如无修改，回复“baseline 确认，继续”即可。",
    "- 如需修改，直接指出要改的字段或描述。"
  ].join("\n"))
when "design_seed"
  meta = data["meta"] || {}
  md << "# #{presence(meta['title']) || 'Design Seed'}\n\n"
  md << "> 当前步骤：`#{format_value(meta['step_id'])}`  \n" if presence(meta["step_id"])
  md << "> 最近更新时间：`#{format_value(meta['updated_at'])}`\n\n" if presence(meta["updated_at"])
  md << section("设计约束基线", render_design_seed_summary(data))
when "bootstrap_plan"
  meta = data["meta"] || {}
  md << "# #{presence(meta['title']) || 'Bootstrap Plan'}\n\n"
  md << "> 当前步骤：`#{format_value(meta['step_id'])}`  \n" if presence(meta["step_id"])
  md << "> 最近更新时间：`#{format_value(meta['updated_at'])}`\n\n" if presence(meta["updated_at"])
  md << section("初始化底座计划", render_bootstrap_plan_summary(data))
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
