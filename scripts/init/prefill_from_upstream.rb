#!/usr/bin/env ruby
require "fileutils"
require "time"
require "yaml"

require_relative "artifact_utils"

ROOT = File.expand_path("../..", __dir__)
TEMPLATE_DIR = File.join(ROOT, "docs/init/templates/structured")
STYLE_REFERENCE_PATH = File.join(ROOT, "docs/init/references/UI_UX_PRO_MAX_STYLE_REFERENCE.md")

args = ARGV.dup
step_id_index = args.index("--step-id")
step_id = nil
if step_id_index
  step_id = args[step_id_index + 1]
  args.slice!(step_id_index, 2)
end

artifact = args[0]
source = args[1]
target = args[2]

if artifact.nil? || source.nil? || target.nil?
  warn "Usage: ruby scripts/init/prefill_from_upstream.rb [--step-id init-06] <design_seed|bootstrap_plan> <source.yml> <target.yml>"
  exit 1
end

unless %w[design_seed bootstrap_plan].include?(artifact)
  warn "Unsupported target artifact: #{artifact}"
  exit 1
end

unless File.exist?(source)
  warn "Source file not found: #{source}"
  exit 1
end

source_data = InitFlow::ArtifactUtils.load_yaml(source)

def load_template(name)
  InitFlow::ArtifactUtils.load_yaml(File.join(TEMPLATE_DIR, "#{name}.template.yaml"))
end

def infer_step_id(artifact, explicit)
  return explicit if explicit && !explicit.empty?
  artifact == "design_seed" ? "init-06" : "init-07"
end

def load_referenced_artifact(path, expected_type = nil)
  return nil if path.to_s.strip.empty?
  return nil unless File.exist?(path)

  data = InitFlow::ArtifactUtils.load_yaml(path)
  return data if expected_type.nil? || data["artifact_type"] == expected_type

  nil
end

def bool_text_from_i18n(value)
  value.to_s.include?("不做") ? "否，默认不启用" : "是，初始化阶段纳入"
end

def bool_text_from_theme(value)
  value.to_s.include?("浅") && !value.to_s.include?("双") ? "否，默认先不启用" : "是，支持切换或局部兼容"
end

def infer_style_recipe(baseline)
  ui = baseline.fetch("ui_foundation", {})
  return ui["style_recipe"] if ui["style_recipe"].to_s.strip != ""

  visual = ui["visual_direction"].to_s
  market = baseline.dig("project_summary", "target_market").to_s
  business_mode = baseline.dig("project_summary", "business_mode").to_s

  if visual.include?("专业后台") || business_mode.include?("SaaS") || market.include?("商家")
    "Flat Design + Minimalism + AI-Native UI"
  else
    "Minimalism & Swiss Style + Flat Design"
  end
end

def infer_spacing_tokens(density)
  compact = density.to_s.include?("中高") || density.to_s.include?("高")
  values = compact ? %w[4px 8px 12px 16px 24px 32px] : %w[4px 8px 16px 24px 32px 48px]
  values.each_with_index.map do |value, index|
    {
      "token" => "space-#{index + 1}",
      "value" => value,
      "note" => index < 2 ? "用于微间距和控件内边距" : "用于模块与区块层级间距",
    }
  end
end

def infer_radius_tokens(style_recipe)
  if style_recipe.include?("Glassmorphism")
    [
      { "token" => "radius-sm", "value" => "10px", "note" => "用于输入框与小型标签" },
      { "token" => "radius-md", "value" => "14px", "note" => "用于卡片与弹窗" },
      { "token" => "radius-lg", "value" => "18px", "note" => "用于大卡片与工作区容器" }
    ]
  else
    [
      { "token" => "radius-sm", "value" => "6px", "note" => "用于输入框与小型标签" },
      { "token" => "radius-md", "value" => "10px", "note" => "用于卡片与弹窗" },
      { "token" => "radius-lg", "value" => "14px", "note" => "用于工作区级容器" }
    ]
  end
end

def infer_shadow_tokens(style_recipe)
  if style_recipe.include?("Glassmorphism")
    [
      { "token" => "shadow-sm", "value" => "0 6px 18px rgba(15,23,42,0.08)", "note" => "用于悬浮卡片" },
      { "token" => "shadow-md", "value" => "0 12px 32px rgba(15,23,42,0.12)", "note" => "用于弹窗与重点工作区" }
    ]
  else
    [
      { "token" => "shadow-sm", "value" => "0 2px 8px rgba(15,23,42,0.06)", "note" => "用于普通卡片" },
      { "token" => "shadow-md", "value" => "0 8px 20px rgba(15,23,42,0.08)", "note" => "用于弹窗与浮层" }
    ]
  end
end

def infer_typography_tokens
  [
    { "token" => "text-xs", "value" => "12/18", "note" => "辅助说明与标签" },
    { "token" => "text-sm", "value" => "14/22", "note" => "表单、表格与正文辅助信息" },
    { "token" => "text-md", "value" => "16/24", "note" => "正文默认字号" },
    { "token" => "text-lg", "value" => "20/28", "note" => "区块标题" }
  ]
end

def infer_color_roles(theme_mode)
  dark = theme_mode.to_s.include?("深")
  if dark && !theme_mode.to_s.include?("浅")
    [
      { "role" => "surface", "value" => "#0F172A", "usage" => "页面背景与工作区底色" },
      { "role" => "surface-raised", "value" => "#111827", "usage" => "卡片与浮层" },
      { "role" => "text-primary", "value" => "#F8FAFC", "usage" => "主要文字" },
      { "role" => "text-secondary", "value" => "#CBD5E1", "usage" => "次级信息" },
      { "role" => "accent", "value" => "#2563EB", "usage" => "主操作与关键状态" }
    ]
  else
    [
      { "role" => "surface", "value" => "#F8FAFC", "usage" => "页面背景与工作区底色" },
      { "role" => "surface-raised", "value" => "#FFFFFF", "usage" => "卡片与浮层" },
      { "role" => "text-primary", "value" => "#0F172A", "usage" => "主要文字" },
      { "role" => "text-secondary", "value" => "#475569", "usage" => "次级信息" },
      { "role" => "accent", "value" => "#2563EB", "usage" => "主操作与关键状态" }
    ]
  end
end

def compact_lines(*values)
  values.flatten.map { |value| value.to_s.strip }.reject(&:empty?)
end

def build_feature_focus(profile)
  summary = profile.dig("project_profile", "project_summary").to_s
  return "AI 视频生成、合规自检、素材参考与账户计费管理" if summary.empty?
  return "AI 视频生成、合规自检、素材参考与账户计费管理" if summary.include?("AI 视频生成") || summary.include?("AI视频生成")

  summary.split("。").first.to_s
end

def login_summary_text(login_methods)
  items = Array(login_methods).map { |item| item.to_s.strip }.reject(&:empty?)
  return "已确认登录方案" if items.empty?
  return items.first if items.length == 1

  items.join(" / ")
end

def generalize_project_positioning(text)
  value = text.to_s.strip
  return value if value.empty?

  value = value.sub(/，一期仅覆盖.*\z/, "")
  value = value.sub(/，默认围绕.*\z/, "")
  value = value.sub(/，首版优先适配.*\z/, "")
  value
end

def format_platform_capabilities(platform_defaults)
  items = []
  items << "上传" if capability_enabled?(platform_defaults["upload"])
  items << "导出" if capability_enabled?(platform_defaults["export"])
  items << "通知" if capability_enabled?(platform_defaults["notifications"])
  items << "关键操作审计" if capability_enabled?(platform_defaults["audit_log"])
  items << "i18n 扩展位" if platform_defaults["i18n"].to_s.include?("后续") || platform_defaults["i18n"].to_s.include?("扩展")
  items << "单语言中文基线" unless capability_enabled?(platform_defaults["i18n"])
  items
end

def capability_enabled?(text)
  value = text.to_s
  return false if value.empty?
  return false if value.include?("默认不启用") || value.include?("不接入") || value.include?("不启用")

  true
end

def platform_component_scope_lines(platform_capabilities)
  items = Array(platform_capabilities)
  lines = []
  if items.include?("上传")
    lines << "上传类通用组件应提供统一触发入口、文件选择/拖拽、上传中、成功、失败和禁用态，不带入任何业务对象。"
  end
  if items.include?("通知")
    lines << "通知类通用组件应提供统一 toast、站内提醒入口、已读/未读表现和基础交互，不带入业务消息流。"
  end
  if items.include?("导出")
    lines << "导出类通用能力应提供统一触发入口、处理中、完成反馈和失败反馈。"
  end
  if items.include?("关键操作审计")
    lines << "审计类通用能力应提供统一记录入口、记录时机和基础展示边界，不展开业务审计规则。"
  end
  compact_lines(lines)
end

def build_design_seed(source_data, target_step_id, source_path)
  baseline = source_data
  title = baseline.dig("meta", "title").to_s
  style_recipe = infer_style_recipe(baseline)
  density = baseline.dig("ui_foundation", "density").to_s
  theme_mode = baseline.dig("ui_foundation", "theme_mode").to_s
  navigation_style = baseline.dig("ui_foundation", "navigation_style").to_s
  template = load_template("design_seed")

  template["meta"]["title"] = "#{title} - 设计约束基线"
  template["meta"]["flow_id"] = "init"
  template["meta"]["step_id"] = target_step_id
  template["meta"]["artifact_id"] = "#{target_step_id}.design_seed"
  template["meta"]["source_paths"] = [File.expand_path(source_path)]
  template["meta"]["updated_at"] = Time.now.utc.iso8601

  template["design_context"] = {
    "current_baseline" => title,
    "selected_style_recipe" => style_recipe,
    "source_style_reference" => STYLE_REFERENCE_PATH,
    "generation_policy" => "先由脚本按 baseline 预填确定性字段，再由 AI 基于风格参考补全和收敛。"
  }
  template["theme_strategy"] = {
    "default_mode" => theme_mode.empty? ? "浅色主题为默认" : theme_mode,
    "supports_dark_mode" => bool_text_from_theme(theme_mode),
    "density_strategy" => density.empty? ? "中高信息密度" : density,
    "navigation_principle" => navigation_style.empty? ? "左侧主导航 + 顶部上下文" : navigation_style
  }
  template["token_baseline"] = {
    "spacing_scale" => infer_spacing_tokens(density),
    "radius_scale" => infer_radius_tokens(style_recipe),
    "shadow_scale" => infer_shadow_tokens(style_recipe),
    "typography_scale" => infer_typography_tokens,
    "color_roles" => infer_color_roles(theme_mode)
  }
  template["layout_principles"] = {
    "app_shell" => "#{navigation_style.empty? ? '左侧主导航 + 顶部上下文' : navigation_style}，默认采用后台工作台骨架，列表页、表单页和详情页共享统一页头与内容容器。",
    "page_patterns" => [
      "首页优先采用概览工作台或指标卡片 + 列表混合布局。",
      "业务页默认采用筛选区 + 列表区 + 详情抽屉/详情页的后台模式。",
      "AI 结果页采用参数区、结果区、历史记录区的分栏或分层结构。"
    ],
    "component_principles" => [
      "优先复用统一 Card、PageSection、FieldGroup、DataTable 等基础容器。",
      "按钮、标签、提示和状态色统一走语义角色，不在页面局部重新发明风格。",
      "局部需要强化现代感时，可在概览卡或弹窗中有限使用毛玻璃或层叠阴影。"
    ],
    "prohibited_patterns" => [
      "页面内直接拍脑袋定义裸 padding、margin、颜色或阴影值。",
      "同一系统里同时混用多套风格语言导致界面漂移。",
      "把营销站式强装饰视觉大面积带入工具型后台主工作区。"
    ]
  }
  template["decision"] = {
    "seed_ready" => true,
    "reason" => "baseline 已确认，可先生成一份设计约束初稿，供后续 AI 继续收敛。"
  }
  template["status"]["ready_for_next"] = true
  template
end

def build_bootstrap_plan(source_data, target_step_id, source_path)
  seed = source_data
  title = seed.dig("meta", "title").to_s
  template = load_template("bootstrap_plan")
  baseline_path = Array(seed.dig("meta", "source_paths")).find do |path|
    artifact = load_referenced_artifact(path)
    artifact && artifact["artifact_type"] == "baseline"
  end
  baseline = load_referenced_artifact(baseline_path, "baseline") || {}
  profile_path = Array(baseline.dig("meta", "source_paths")).find do |path|
    artifact = load_referenced_artifact(path)
    artifact && artifact["artifact_type"] == "project_profile"
  end
  profile = load_referenced_artifact(profile_path, "project_profile") || {}

  project_title = baseline.dig("meta", "title").to_s.sub(/初始化基线\z/, "")
  project_title = project_title.sub(/\s*-\s*experience_platform\z/, "")
  project_title = title.sub(/\s*-\s*设计约束基线\z/, "") if project_title.empty?
  project_label = project_title.empty? ? "当前项目" : project_title
  feature_focus = build_feature_focus(profile)
  theme_mode = seed.dig("theme_strategy", "default_mode").to_s
  density_strategy = seed.dig("theme_strategy", "density_strategy").to_s
  navigation_principle = seed.dig("theme_strategy", "navigation_principle").to_s
  style_recipe = seed.dig("design_context", "selected_style_recipe").to_s
  page_patterns = Array(seed.dig("layout_principles", "page_patterns"))
  component_principles = Array(seed.dig("layout_principles", "component_principles"))
  color_roles = Array(seed.dig("token_baseline", "color_roles")).map { |item| item["role"] }.compact
  platform_defaults = baseline.fetch("platform_defaults", {})
  identity_access = baseline.fetch("identity_access", {})
  ui_foundation = baseline.fetch("ui_foundation", {})
  project_summary = baseline.fetch("project_summary", {})
  target_users = Array(profile.dig("project_profile", "target_users"))
  platform_capabilities = format_platform_capabilities(platform_defaults)
  login_methods = Array(identity_access["login_methods"]).reject(&:empty?)
  login_summary = login_summary_text(login_methods)
  tenant_model = identity_access["tenant_model"].to_s
  permission_model = identity_access["permission_model"].to_s
  account_identifier = identity_access["account_identifier"].to_s
  account_model = identity_access["account_model"].to_s
  request_stack = baseline.dig("engineering_stack", "frontend_stack").to_s
  project_type = project_summary["product_type"].to_s
  business_mode = project_summary["business_mode"].to_s
  target_market = project_summary["target_market"].to_s
  default_region = project_summary["default_region"].to_s
  default_language = project_summary["default_language"].to_s
  generalized_project_type = generalize_project_positioning(project_type)
  generalized_business_mode = generalize_project_positioning(business_mode)
  generalized_target_market = generalize_project_positioning(target_market)
  i18n_enabled = capability_enabled?(platform_defaults["i18n"])
  upload_enabled = capability_enabled?(platform_defaults["upload"])
  export_enabled = capability_enabled?(platform_defaults["export"])
  notifications_enabled = capability_enabled?(platform_defaults["notifications"])
  audit_enabled = capability_enabled?(platform_defaults["audit_log"])
  frontend_label = request_stack.empty? ? "refine + shadcn 前端基座" : request_stack
  preset_packs = [
    {
      "pack_id" => "core_refine_shadcn",
      "name" => "Refine + shadcn 基座包",
      "enabled_when" => "默认启用；当前初始化方案固定采用 refine + shadcn",
      "preset_actions" => [
        "初始化 refine 基础工程",
        "接入 shadcn/ui 基础组件集与 Tailwind 基础样式",
        "预置项目级 provider、样式入口和基础目录骨架"
      ],
      "install_commands" => [
        "pnpm create refine@latest <app-name> --template refine-vite",
        "pnpm add @refinedev/core @refinedev/react-router @refinedev/kbar",
        "pnpm dlx shadcn@latest init",
        "pnpm dlx shadcn@latest add button input card table form label textarea select badge dialog sheet dropdown-menu skeleton tabs toast"
      ],
      "generated_files" => [
        "src/app/providers/*",
        "src/components/ui/*",
        "src/styles/globals.css",
        "src/routes/*"
      ],
      "ai_followups" => [
        "AI 需根据当前项目的 design token 补强 shadcn 变量和全局样式",
        "AI 需校对 refine 入口、provider 组合和项目目录是否符合当前项目边界"
      ]
    },
    {
      "pack_id" => "theme_token_foundation",
      "name" => "Theme Token 落地包",
      "enabled_when" => "默认启用；所有项目都要把 design_seed token 落到代码层",
      "preset_actions" => [
        "生成 token 文件、主题映射文件和 CSS 变量桥接文件",
        "预置浅色主题基线，并为后续扩展保留结构"
      ],
      "install_commands" => [
        "pnpm add class-variance-authority clsx tailwind-merge",
        "pnpm add -D tailwindcss-animate"
      ],
      "generated_files" => [
        "src/theme/tokens.ts",
        "src/theme/semantic-colors.ts",
        "src/theme/index.ts",
        "src/styles/theme.css"
      ],
      "ai_followups" => [
        "AI 需把 design_seed 中的 spacing、radius、shadow、typography、color roles 逐条映射到代码文件",
        "AI 需校验 shadcn 组件变量是否与项目规则文件一致"
      ]
    }
  ]
  if i18n_enabled
    preset_packs << {
      "pack_id" => "i18n_pack",
      "name" => "i18n 基础包",
      "enabled_when" => "仅当 init 已确认需要 i18n 时启用",
      "preset_actions" => [
        "安装 i18n 运行时与 provider",
        "生成语言资源目录和默认 locale 配置"
      ],
      "install_commands" => [
        "pnpm add i18next react-i18next i18next-browser-languagedetector"
      ],
      "generated_files" => [
        "src/i18n/index.ts",
        "src/i18n/locales/zh-CN.ts"
      ],
      "ai_followups" => [
        "AI 需根据项目范围补齐默认语言资源结构"
      ]
    }
  end
  if upload_enabled || export_enabled || notifications_enabled || audit_enabled
    capability_actions = []
    capability_actions << "接入上传能力占位与基础组件" if upload_enabled
    capability_actions << "接入导出能力入口与工具函数" if export_enabled
    capability_actions << "接入通知能力 provider 与 toast/notice 桥接" if notifications_enabled
    capability_actions << "接入轻量审计记录 hook 与事件封装占位" if audit_enabled
    capability_files = []
    capability_files << "src/features/upload/*" if upload_enabled
    capability_files << "src/features/export/*" if export_enabled
    capability_files << "src/features/notifications/*" if notifications_enabled
    capability_files << "src/features/audit/*" if audit_enabled
    preset_packs << {
      "pack_id" => "platform_capabilities",
      "name" => "平台能力占位包",
      "enabled_when" => "按 baseline 已确认的平台默认能力启用对应子能力",
      "preset_actions" => capability_actions,
      "install_commands" => [
        ("pnpm add sonner" if notifications_enabled),
        ("pnpm add react-dropzone" if upload_enabled),
        ("pnpm add file-saver" if export_enabled)
      ].compact,
      "generated_files" => capability_files,
      "ai_followups" => [
        "AI 需根据当前项目范围把能力占位控制在工程入口层，不写业务接口和业务流程"
      ]
    }
  end

  template["meta"]["title"] = "#{project_label} - 初始化底座计划"
  template["meta"]["flow_id"] = "init"
  template["meta"]["step_id"] = target_step_id
  template["meta"]["artifact_id"] = "#{target_step_id}.bootstrap_plan"
  template["meta"]["source_paths"] = compact_lines(File.expand_path(source_path), baseline_path && File.expand_path(baseline_path))
  template["meta"]["updated_at"] = Time.now.utc.iso8601

  template["init_execution_scope"] = {
    "output_artifacts" => {
      "template_path" => File.expand_path("docs/init/templates/init-execution-scope.template.md", ROOT),
      "target_path" => "rendered/init-08.init-execution-scope.md"
    },
    "conditional_parameters" => [
      {
        "parameter_id" => "i18n",
        "source_field" => "baseline.platform_defaults.i18n",
        "current_value" => i18n_enabled ? "enabled" : "disabled",
        "effect_on_scope" => [
          i18n_enabled ? "启用 i18n_pack，并安装 i18next 相关依赖" : "不生成 i18n_pack，只保留单语言中文基线和未来扩展位",
          i18n_enabled ? "生成 src/i18n/* 目录与默认 locale 文件" : "不生成 src/i18n/*"
        ]
      },
      {
        "parameter_id" => "upload",
        "source_field" => "baseline.platform_defaults.upload",
        "current_value" => upload_enabled ? "enabled" : "disabled",
        "effect_on_scope" => [
          upload_enabled ? "启用上传能力占位，并生成 src/features/upload/*" : "不生成上传能力占位",
          upload_enabled ? "安装 react-dropzone 作为上传基础能力依赖" : "不安装上传相关依赖"
        ]
      },
      {
        "parameter_id" => "export",
        "source_field" => "baseline.platform_defaults.export",
        "current_value" => export_enabled ? "enabled" : "disabled",
        "effect_on_scope" => [
          export_enabled ? "启用导出能力占位，并生成 src/features/export/*" : "不生成导出能力占位",
          export_enabled ? "安装 file-saver 作为导出基础能力依赖" : "不安装导出相关依赖"
        ]
      },
      {
        "parameter_id" => "notifications",
        "source_field" => "baseline.platform_defaults.notifications",
        "current_value" => notifications_enabled ? "enabled" : "disabled",
        "effect_on_scope" => [
          notifications_enabled ? "启用通知能力占位，并生成 src/features/notifications/*" : "不生成通知能力占位",
          notifications_enabled ? "安装 sonner 作为通知基础能力依赖" : "不安装通知相关依赖"
        ]
      },
      {
        "parameter_id" => "audit_log",
        "source_field" => "baseline.platform_defaults.audit_log",
        "current_value" => audit_enabled ? "enabled" : "disabled",
        "effect_on_scope" => [
          audit_enabled ? "启用轻量审计占位，并生成 src/features/audit/*" : "不生成轻量审计占位",
          audit_enabled ? "保留审计事件封装与 hook 占位" : "不生成审计事件入口"
        ]
      }
    ],
    "preset_capability_packs" => preset_packs,
    "command_blueprints" => [
      "在目标项目目录执行 refine 官方脚手架，生成当前项目的基础工程，不混入业务模块模板",
      "执行 shadcn 官方初始化命令，完成 components.json、样式入口和基础组件接入",
      "安装基础 UI 依赖，包括 shadcn 组件扩展、样式工具、token 工具和基础动画依赖",
      "生成 run 内执行范围文档 rendered/init-08.init-execution-scope.md，并写入固定项目规则文件 docs/project/project-conventions.md",
      "生成主题代码骨架，包括 src/theme/tokens.ts、src/theme/semantic-colors.ts、src/theme/index.ts、src/styles/theme.css",
      "生成 provider 骨架，预置 src/app/providers 下的主题、通知、平台能力入口",
      ("如果 i18n=enabled，则安装 i18next 相关依赖并生成 src/i18n/*" if i18n_enabled),
      ("如果 upload=enabled，则安装 react-dropzone 并生成 src/features/upload/*" if upload_enabled),
      ("如果 export=enabled，则安装 file-saver 并生成 src/features/export/*" if export_enabled),
      ("如果 notifications=enabled，则安装 sonner 并生成 src/features/notifications/*" if notifications_enabled),
      ("如果 audit_log=enabled，则生成 src/features/audit/* 与事件封装入口" if audit_enabled),
      "执行 AI 补强，要求 AI 按当前项目实际安装的 refine、shadcn、tailwind 等版本调整代码，不得沿用过时方案",
      "执行 reviewer 校验，检查预制结果和 AI 补强结果是否仍停留在工程基座层"
    ].compact,
    "code_artifacts" => [
      "rendered/init-08.init-execution-scope.md",
      "docs/project/project-conventions.md",
      "src/theme/tokens.ts",
      "src/theme/index.ts",
      "src/styles/theme.css",
      "src/app/providers/*"
    ] + [
      ("src/i18n/*" if i18n_enabled),
      ("src/features/upload/*" if upload_enabled),
      ("src/features/export/*" if export_enabled),
      ("src/features/notifications/*" if notifications_enabled),
      ("src/features/audit/*" if audit_enabled)
    ].compact,
    "ai_followups" => [
      "AI 需根据当前项目 design_seed 把 token、全局主题变量和基础样式真正落到代码文件",
      "AI 需审核预制命令产出的目录和 provider 组合，删除与当前项目无关的默认模板内容",
      "AI 需确保所有预制能力都停留在工程基座层，不越界实现业务模块"
    ],
    "allowed_work" => [
      "#{project_label} 的 #{request_stack.empty? ? '前端工程' : request_stack} 初始化、依赖安装与目录基座约定",
      "design_seed 已确认的 theme/token、样式组织方式和组件封装约束落入工程骨架",
      "#{platform_capabilities.join('、')} 等平台默认能力的工程扩展位与文档落位，但不写具体业务接口",
      "#{platform_defaults['i18n'].to_s.include?('不') ? '简体中文默认文案基线与未来 i18n 扩展位' : 'i18n 机制与扩展位'}"
    ],
    "excluded_work" => [
      "任何需要具体业务 contract、接口字段、后端联调细节后才能成立的实现内容",
      "任何真实业务模块页面、业务流程页面或业务交互细节的落地实现",
      "任何业务对象规则、状态流转、字段校验、业务权限细节和模块行为编排",
      "任何依赖真实业务对象、真实后端接口或演示性假数据流程的页面与代码"
    ],
    "deliverables" => [
      "初始化后的工程目录、基础依赖和可持续扩展的项目骨架",
      "与“#{theme_mode} / #{density_strategy} / #{style_recipe}”一致的 token 与样式基线文件",
      "固定路径的项目规则文件与本次 init 流程内的第8步执行范围文件",
      "可直接进入下一轮 PRD 的基础上下文材料"
    ],
    "completion_criteria" => [
      "第8步完成后，项目已具备继续 vibecoding 的工程底座，但仍未引入任何具体业务模块实现",
      "design_seed 的关键设计约束已落到项目内固定规则文档，而不是只停留在 run 产物里",
      "init_execution_scope 保持为本次 init 流程的执行依据，而不是项目长期规则文件",
      "登录注册、租户、权限等平台能力仍保留给后续 PRD 与 contract 阶段推进"
    ],
    "reviewer_focus" => [
      "是否混入任何具体业务接口、业务 contract 或真实业务页面实现",
      "是否把纯工程初始化范围写得足够具体，能直接指导第8步代码执行",
      "是否明确区分项目长期规则文件和仅用于本次 init 流程的执行依据",
      "是否遗漏 design_seed 已确认但应在工程层落位的主题与 token 基线"
    ]
  }

  template["project_conventions"] = {
    "output_artifacts" => {
      "template_path" => File.expand_path("docs/init/templates/project-conventions.template.md", ROOT),
      "target_path" => "docs/project/project-conventions.md"
    },
    "generation_workflow" => [
      "脚本先按固定模板和 design_seed 结构化字段生成规则文件骨架",
      "AI 必须基于当前项目的 design_seed 逐条补强细节，不能把脚本初稿直接当最终规则文件",
      "reviewer 必须检查规则文件是否已经覆盖当前项目的主题、token、页面模式、组件风格和禁止事项"
    ],
    "source_of_truth" => {
      "primary_inputs" => compact_lines(
        "以 init-06 design_seed 作为长期规则主来源",
        "必要时吸收 baseline 中已确认的工程边界与平台默认能力"
      ),
      "design_seed_highlights" => compact_lines(
        "风格方案：#{style_recipe}",
        "主题模式：#{theme_mode}",
        "信息密度：#{density_strategy}",
        ("导航原则：#{navigation_principle}" unless navigation_principle.empty?),
        ("页面模式：#{page_patterns.first(3).join('、')}" unless page_patterns.empty?),
        ("组件原则：#{component_principles.first(3).join('、')}" unless component_principles.empty?)
      )
    },
    "sections_to_fill" => compact_lines(
      "文档定位：说明该文件是项目内长期规则来源，后续 PRD / 开发 / reviewer 默认先读取",
      "设计风格总则：展开 #{style_recipe}、#{theme_mode}、暗色扩展策略与 #{density_strategy}",
      "导航与应用骨架规则：展开 app shell 与 #{navigation_principle}",
      ("Theme / Token 规则：逐条展开 spacing、radius、shadow、typography、#{color_roles.first(5).join('、')} 等语义色角色" unless color_roles.empty?),
      ("页面模式规则：逐条展开 #{page_patterns.first(3).join('、')} 等页面模式" unless page_patterns.empty?),
      "组件风格与封装规则：逐条展开基础容器、媒体预览、状态反馈、表单分区等原则",
      "禁止事项：逐条展开 design_seed 中不允许出现的视觉与交互偏离方式",
      "使用方式：说明 PRD、开发、reviewer 如何持续读取这份规则文档"
    ),
    "reviewer_focus" => [
      "是否把 init-01 到 init-04 的一次性确认误写成长期固定规则",
      "是否已经写成清单式、可检查的规则，而不是长段说明文",
      "是否已经把 design_seed 的 token、页面模式、组件原则和禁止项真正展开进规则文件",
      "是否明确写出项目内固定落位和后续 PRD 的读取方式"
    ],
    "notes" => [
      "项目固定规则文件路径统一为 docs/project/project-conventions.md；后续所有 PRD 都应直接读取这个相对路径。",
      "这份文件是项目级规则文件，不承载 harness 级的通用开发流程规则。"
    ]
  }

  template["prd_bootstrap_context"] = {
    "output_artifacts" => {
      "template_path" => File.expand_path("docs/init/templates/prd-bootstrap-context.template.md", ROOT),
      "target_path" => "rendered/init-07.prd-bootstrap-context.md"
    },
    "generation_workflow" => [
      "脚本先按固定模板和已确认 baseline / design_seed 字段生成基础 PRD 初稿骨架",
      "AI 必须基于当前项目已确认的基础前提补强模块目标、组件边界、状态与变体细节，不能直接把脚本初稿当最终文档",
      "reviewer 必须检查该文档是否仍然停留在基础 PRD 范围，没有混入任何具体业务功能前提或流程规则"
    ],
    "document_goal" => [
      "把 init-01 到 init-04 已确认的项目基础结论整理成下一轮 PRD 的基础输入。",
      "让下一轮 PRD 先围绕登录、账号、租户、权限这类基础模块展开，而不是提前进入具体业务功能。",
      "把这份文档写成“基础 PRD 初稿”，供后续 PRD 继续拆解和实现。"
    ],
    "project_overview" => compact_lines(
      "项目定位：#{generalized_project_type.empty? ? project_type : generalized_project_type}",
      ("业务模式：#{generalized_business_mode.empty? ? business_mode : generalized_business_mode}" unless business_mode.empty?),
      ("目标市场：#{generalized_target_market.empty? ? target_market : generalized_target_market}" unless target_market.empty?),
      ("默认地区：#{default_region}" unless default_region.empty?),
      ("默认语言：#{default_language}" unless default_language.empty?),
      "当前 init 已经确认的是系统基础方向和基础治理方式，不包含任何具体业务模块前提。"
    ),
    "confirmed_foundation" => compact_lines(
      ("登录方式：#{login_summary}" unless login_summary.empty?),
      ("账号标识：#{account_identifier}" unless account_identifier.empty?),
      ("账号模型：#{account_model}" unless account_model.empty?),
      ("租户模型：#{tenant_model}" unless tenant_model.empty?),
      ("权限模型：#{permission_model}" unless permission_model.empty?),
      "平台层与租户侧边界已确认：平台侧全局规则和租户开通在独立项目实现，当前项目只承载租户侧后台使用。"
    ),
    "priority_modules" => [
      {
        "module_id" => "auth_login",
        "name" => "登录与认证基础",
        "objective" => "先把商家端后台的登录入口、认证状态和会话基础定义清楚。",
        "requirements" => compact_lines(
          ("系统默认登录方式采用：#{login_summary}" unless login_summary.empty?),
          "系统提供统一登录页、登录成功后的进入路径、失败反馈和异常提示。",
          "系统提供统一会话维持、退出登录、未登录拦截和基础安全边界。",
          "本模块不引入任何具体业务流程或业务对象。"
        )
      },
      {
        "module_id" => "account_member",
        "name" => "账号与成员基础",
        "objective" => "把租户内账号、成员和身份关系整理成后续系统默认继承的基础模型。",
        "requirements" => compact_lines(
          ("账号标识采用：#{account_identifier}" unless account_identifier.empty?),
          ("账号模型采用：#{account_model}" unless account_model.empty?),
          "系统支持主账号、成员账号、基础资料和账号状态的统一模型。",
          "本模块不展开跨租户账号、复杂组织树和具体业务角色流程。"
        )
      },
      {
        "module_id" => "framework_shell_components",
        "name" => "框架型组件基础",
        "objective" => "把初始化阶段会复用的框架型组件和页面骨架先整理成一组基础模块需求。",
        "requirements" => compact_lines(
          "系统提供统一的 layout、app shell、导航容器、PageHeader、PageSection、详情抽屉、空状态、加载状态、错误状态等框架型组件。",
          "这些组件按应用壳层、页面骨架、页面内通用容器三层组织。",
          "项目级基础组件与模块内组合组件边界保持固定，不在后续模块中重复发明基础壳层。",
          "这些组件直接继承 design_seed 与 project-conventions，不允许脱离项目规则单独定义一套样式。",
          "框架型组件默认覆盖空状态、加载状态、错误状态、页头模式和抽屉展示等基础变体。",
          "本模块不带入任何具体业务页面、业务表单或业务对象。"
        )
      },
      {
        "module_id" => "platform_capability_components",
        "name" => "平台通用能力组件基础",
        "objective" => "把上传、通知、导出、审计这类平台通用能力先整理成可复用组件或接入层的基础需求。",
        "requirements" => compact_lines(
          "平台通用能力组件只提供组件层和接线层，必要时提供最小可用的交互壳。",
          "这些能力组件与页面组件、容器组件、provider 层之间的边界保持固定。",
          "这些能力组件统一覆盖成功、失败、处理中、空结果和禁用态。",
          *platform_component_scope_lines(platform_capabilities),
          "本模块不绑定任何具体业务模块、业务数据结构或业务审批流程。"
        )
      },
      {
        "module_id" => "tenant_context",
        "name" => "租户上下文基础",
        "objective" => "把当前系统中的租户侧工作区和租户上下文边界先定义清楚。",
        "requirements" => compact_lines(
          ("租户模型采用：#{tenant_model}" unless tenant_model.empty?),
          "租户内后台提供统一工作区上下文、租户信息承载方式和页面切换边界。",
          "租户侧后台与平台侧独立项目的能力边界保持固定。",
          "本模块不带入任何具体业务页面、业务表单或业务对象。"
        )
      },
      {
        "module_id" => "permission_access",
        "name" => "权限与访问控制基础",
        "objective" => "把后台访问控制和角色边界先收敛成一套基础权限方案。",
        "requirements" => compact_lines(
          ("权限模型采用：#{permission_model}" unless permission_model.empty?),
          "后台页面访问、关键操作控制和角色分配遵循统一基础原则。",
          "租户管理员与普通成员的权限边界保持固定。",
          "本模块不提前进入资源级细粒度授权和具体业务动作权限设计。"
        )
      }
    ],
    "prd_focus" => [
      "下一轮 PRD 重点应放在基础模块的页面范围、状态流转、数据对象和接口边界。",
      "下一轮 PRD 应分别补一轮框架型组件和平台通用能力组件的需求梳理，因为 init-08 更偏工程落位与占位，不等于这些组件的 PRD 已经完成。",
      "下一轮 PRD 可以继承项目级视觉与页面实现规则，但不需要重新总结 init 流程。",
      "下一轮 PRD 不应自行补入任何具体业务功能前提。"
    ],
    "reviewer_focus" => [
      "是否仍然是基础 PRD 初稿，而不是流程说明或业务 PRD",
      "是否已经把认证、账号、租户、权限、框架型组件、平台通用能力组件的边界写清楚",
      "是否遗漏空状态、加载态、错误态、详情抽屉、通知反馈、上传状态等通用状态与组件边界",
      "是否混入任何具体业务对象、业务页面、业务消息流或业务审批流程"
    ],
    "notes" => [
      "prd_bootstrap_context 是本次 init 流程交给下一轮 PRD 的执行依据，不是项目内长期规则文件。",
      "项目内长期保留并被全局复用的规则文件仍然只有 docs/project/project-conventions.md。",
      "如后续发现 init 问卷里确认的项目级前提需要整体改动，应进入独立的初始化变更流程。",
      "如后续业务方向发生变化，不应回填进这份基础 PRD，而应在后续业务 PRD 中重新建立业务上下文。"
    ]
  }

  template["decision"] = {
    "plan_confirmed" => false,
    "reason" => "已根据 design_seed 与 baseline 预填新的 bootstrap_plan 结构，待人工确认第8步执行范围、项目长期规则与下一轮 PRD 交接方式。"
  }
  template["status"]["ready_for_next"] = false
  template
end

result =
  case artifact
  when "design_seed"
    unless source_data["artifact_type"] == "baseline"
      warn "design_seed must be prefilled from a baseline artifact"
      exit 1
    end
    build_design_seed(source_data, infer_step_id(artifact, step_id), source)
  when "bootstrap_plan"
    unless source_data["artifact_type"] == "design_seed"
      warn "bootstrap_plan must be prefilled from a design_seed artifact"
      exit 1
    end
    build_bootstrap_plan(source_data, infer_step_id(artifact, step_id), source)
  end

errors = InitFlow::ArtifactUtils.validate_artifact(artifact, result)
unless errors.empty?
  warn "Prefilled artifact is invalid:"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

FileUtils.mkdir_p(File.dirname(target))
File.write(target, YAML.dump(result))
puts "Prefilled #{artifact} artifact at #{target}"
