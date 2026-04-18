#!/usr/bin/env ruby
require "fileutils"
require "pathname"
require "time"
require "date"

ROOT = File.expand_path("..", __dir__)

def prompt(label, default: nil, allow_empty: false)
  loop do
    print(default ? "#{label} [#{default}]: " : "#{label}: ")
    value = $stdin.gets
    exit 1 if value.nil?

    value = value.strip
    value = default if value.empty? && default
    return value if allow_empty || !value.to_s.strip.empty?
  end
end

def choose_flow(initial_flow = nil)
  return initial_flow if %w[init prd].include?(initial_flow)

  loop do
    puts "请选择本次流程："
    puts "1. init"
    puts "2. prd"
    print "> "
    input = $stdin.gets
    exit 1 if input.nil?

    case input.strip
    when "1", "init"
      return "init"
    when "2", "prd"
      return "prd"
    end
  end
end

def parse_args(argv)
  options = {}
  args = argv.dup
  while args.any?
    key = args.shift
    case key
    when "--flow"
      options[:flow] = args.shift
    when "--run-id"
      options[:run_id] = args.shift
    when "--title"
      options[:title] = args.shift
    when "--request-file"
      options[:request_file] = args.shift
    when "--owner"
      options[:owner] = args.shift
    else
      warn "Unknown option: #{key}"
      exit 1
    end
  end
  options
end

def write_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

def relative_to_root(path)
  Pathname.new(path).relative_path_from(Pathname.new(ROOT)).to_s
end

def copy_template(template_path, target_path)
  FileUtils.mkdir_p(File.dirname(target_path))
  FileUtils.cp(template_path, target_path)
end

def run_command(*command)
  success = system(*command)
  return if success

  warn "Command failed: #{command.join(' ')}"
  exit 1
end

def slugify(text)
  ascii = text.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
  ascii.empty? ? "run" : ascii
end

def default_run_id(title, flow)
  slug = slugify(title)
  slug = "#{flow}-run" if slug == "run"
  "#{Date.today.iso8601}-#{slug}"
end

def build_request_content(flow, title)
  <<~MD
    # Request

    ## Flow

    - #{flow}

    ## Title

    - #{title}

    ## Background

    - 

    ## Scope

    - 

    ## Attachments

    - 把原始 PRD、原型、截图放到 `raw/attachments/`
    - 如有 `pdf` / `docx` / `xlsx`，建议转一份 `md` 再一起放入
  MD
end

def build_raw_readme
  <<~MD
    # Raw Inputs

    这里放这轮流程的原始输入。

    使用规则：

    - 一句话需求或简短背景，写到 `request.md`
    - 完整 PRD、原型、截图、参考资料，放到 `attachments/`
    - 不要把结构化 YAML 放进 `raw/`

    推荐格式：

    1. `md`
    2. `html`
    3. `txt`
    4. `png` / `jpg` / `jpeg`

    不太推荐直接作为主输入的格式：

    - `pdf`
    - `doc`
    - `docx`
    - `xlsx`
    - `ppt`
    - `pptx`

    原因：

    - 版式噪音多
    - 提取后结构容易乱
    - 表格、批注、分页容易干扰理解

    建议：

    - `Word` / `PDF` 优先转成 `md`
    - 原件可以保留，同时再放一份转写后的 `md`
    - 表格类信息建议整理成 `md` 表格或清晰文本摘要

    建议放法：

    - `request.md`：一句话需求、背景、测试目标
    - `attachments/*.md`：结构化原始资料
    - `attachments/*.html`：原型导出或网页文档
    - `attachments/images/*`：截图和视觉参考

    推荐顺序：

    1. 先补 `request.md`
    2. 再把附件放进 `attachments/`
    3. 然后再把 `prompts/run-agent-prompt.md` 交给 AI
  MD
end

def build_decisions_content
  <<~MD
    # Decisions

    | date | flow | step_id | decision | by | impact |
    | --- | --- | --- | --- | --- | --- |
  MD
end

def build_handoff_content
  <<~MD
    # Handoff Notes

    - 
  MD
end

def build_init_prompt(run_root, title)
  build_autonomous_prompt(
    flow: "init",
    run_root: run_root,
    first_step_id: "init-01",
    first_artifact: "init/init-01.project_profile.yaml",
    first_review: "init/init-01.review.yaml",
    validate_command: "ruby scripts/init/validate_artifact.rb project_profile #{File.join(run_root, 'init/init-01.project_profile.yaml')}",
    render_command: "ruby scripts/init/render_artifact.rb project_profile #{File.join(run_root, 'init/init-01.project_profile.yaml')} #{File.join(run_root, 'rendered/init-01.project_profile.md')}"
  )
end

def build_prd_prompt(run_root, title)
  build_autonomous_prompt(
    flow: "prd",
    run_root: run_root,
    first_step_id: "prd-01",
    first_artifact: "prd/prd-01.clarification.yaml",
    first_review: "prd/prd-01.review.yaml",
    validate_command: "ruby scripts/prd/validate_artifact.rb clarification #{File.join(run_root, 'prd/prd-01.clarification.yaml')}",
    render_command: "ruby scripts/prd/render_artifact.rb clarification #{File.join(run_root, 'prd/prd-01.clarification.yaml')} #{File.join(run_root, 'rendered/prd-01.clarification.md')}"
  )
end

def build_autonomous_prompt(flow:, run_root:, first_step_id:, first_artifact:, first_review:, validate_command:, render_command:)
  template = File.read(File.join(ROOT, "docs/templates/autonomous-run-prompt.template.md"))
  replacements = {
    "{{FLOW}}" => flow,
    "{{RUN_ROOT}}" => run_root,
    "{{FLOW_README}}" => "/Users/wangwenjie/project/archetype-admin-path/docs/#{flow}/README.md",
    "{{FLOW_WORKFLOW_GUIDE}}" => "/Users/wangwenjie/project/archetype-admin-path/docs/#{flow}/WORKFLOW_GUIDE.md",
    "{{FLOW_STEP_GUIDE}}" => "/Users/wangwenjie/project/archetype-admin-path/docs/#{flow}/STEP_NAMING_GUIDE.md",
    "{{FIRST_STEP_ID}}" => first_step_id,
    "{{FIRST_ARTIFACT}}" => first_artifact,
    "{{FIRST_REVIEW}}" => first_review,
    "{{VALIDATE_COMMAND}}" => validate_command,
    "{{RENDER_COMMAND}}" => render_command,
    "{{FLOW_COMMANDS}}" => flow_command_cheat_sheet(flow, run_root)
  }

  replacements.reduce(template) { |content, (key, value)| content.gsub(key, value) }
end

def flow_command_cheat_sheet(flow, run_root)
  case flow
  when "init"
    <<~MD
      ### Init Step Map

      - `init-01` -> `foundation_context`
      - `init-02` -> `tenant_governance`
      - `init-03` -> `identity_access`
      - `init-04` -> `experience_platform`
      - `init-05` -> `baseline`

      ### Init Commands

      初始化阶段画像：

      ```bash
      ruby scripts/init/init_artifact.rb --step-id init-02 project_profile #{File.join(run_root, "init/init-02.project_profile.yaml")}
      ```

      初始化 reviewer：

      ```bash
      ruby scripts/init/init_artifact.rb --step project_initialization --step-id init-01 review #{File.join(run_root, "init/init-01.review.yaml")}
      ```

      校验主产物：

      ```bash
      ruby scripts/init/validate_artifact.rb project_profile #{File.join(run_root, "init/init-01.project_profile.yaml")}
      ```

      渲染主产物：

      ```bash
      ruby scripts/init/render_artifact.rb project_profile #{File.join(run_root, "init/init-01.project_profile.yaml")} #{File.join(run_root, "rendered/init-01.project_profile.md")}
      ```

      初始化 baseline：

      ```bash
      ruby scripts/init/init_artifact.rb --step-id init-05 baseline #{File.join(run_root, "init/init-05.baseline.yaml")}
      ```

      Human Gate:

      - 每个 reviewer 通过后的阶段确认都必须停
      - `baseline` 通过后也必须停
    MD
  when "prd"
    <<~MD
      ### PRD Step Map

      - `prd-01` -> `clarification`
      - `prd-02` -> `brief`
      - `prd-03` -> `decomposition`

      ### PRD Commands

      初始化 clarification：

      ```bash
      ruby scripts/prd/init_artifact.rb --step-id prd-01 clarification #{File.join(run_root, "prd/prd-01.clarification.yaml")}
      ```

      初始化 clarification reviewer：

      ```bash
      ruby scripts/prd/init_artifact.rb --step requirement_clarification --step-id prd-01 review #{File.join(run_root, "prd/prd-01.review.yaml")}
      ```

      初始化 brief：

      ```bash
      ruby scripts/prd/init_artifact.rb --step-id prd-02 brief #{File.join(run_root, "prd/prd-02.brief.yaml")}
      ```

      初始化 decomposition：

      ```bash
      ruby scripts/prd/init_artifact.rb --step-id prd-03 decomposition #{File.join(run_root, "prd/prd-03.decomposition.yaml")}
      ```

      初始化 decomposition reviewer：

      ```bash
      ruby scripts/prd/init_artifact.rb --step prd_decomposition --step-id prd-03 review #{File.join(run_root, "prd/prd-03.review.yaml")}
      ```

      校验主产物：

      ```bash
      ruby scripts/prd/validate_artifact.rb clarification #{File.join(run_root, "prd/prd-01.clarification.yaml")}
      ```

      渲染主产物：

      ```bash
      ruby scripts/prd/render_artifact.rb clarification #{File.join(run_root, "prd/prd-01.clarification.yaml")} #{File.join(run_root, "rendered/prd-01.clarification.md")}
      ```

      Human Gate:

      - 默认只在 blocker、关键决策缺失或最终需要人工确认时停
    MD
  end
end

def update_progress_meta(progress_path, run_id:, owner:, flow:)
  lines = File.readlines(progress_path, chomp: true)
  replacements = {
    "- run_id:" => "- run_id: #{run_id}",
    "- owner:" => "- owner: #{owner}",
    "- started_at:" => "- started_at: #{Time.now.iso8601}",
    "- current_flow:" => "- current_flow: #{flow}",
    "- current_step_id:" => "- current_step_id: #{flow == 'init' ? 'init-01' : 'prd-01'}",
    "- overall_status:" => "- overall_status: doing",
    "- current_goal:" => "- current_goal: 完成首个结构化 YAML",
    "- current_blocker:" => "- current_blocker: ",
    "- next_agent_input:" => "- next_agent_input: raw/request.md",
    "- next_expected_output:" => "- next_expected_output: #{flow == 'init' ? 'init/init-01.project_profile.yaml' : 'prd/prd-01.clarification.yaml'}",
    "- raw_request:" => "- raw_request: raw/request.md",
    "- attachments:" => "- attachments: raw/attachments/",
    "- baseline_if_any:" => "- baseline_if_any: "
  }

  updated = lines.map do |line|
    replacement = replacements.keys.find { |prefix| line.start_with?(prefix) }
    replacement ? replacements.fetch(replacement) : line
  end

  first_step_id = flow == "init" ? "`init-01`" : "`prd-01`"
  updated = updated.map do |line|
    if line.start_with?("| #{first_step_id} |")
      line.sub("| `todo` |", "| `doing` |")
    else
      line
    end
  end

  File.write(progress_path, updated.join("\n") + "\n")
end

options = parse_args(ARGV)
flow = choose_flow(options[:flow])
title = options[:title] || prompt("本次要做什么", default: flow == "init" ? "project-initialization" : "feature-prd")
run_id = options[:run_id] || prompt("run id", default: default_run_id(title, flow))
owner = options[:owner] || prompt("owner", default: ENV["USER"].to_s.empty? ? "unknown" : ENV["USER"])

run_root = File.join(ROOT, "runs", run_id)
if File.exist?(run_root)
  warn "Run directory already exists: #{run_root}"
  exit 1
end

dirs = %w[raw raw/attachments init prd rendered progress prompts archive]
dirs.each { |dir| FileUtils.mkdir_p(File.join(run_root, dir)) }

request_target = File.join(run_root, "raw/request.md")
if options[:request_file]
  source = File.expand_path(options[:request_file], Dir.pwd)
  unless File.exist?(source)
    warn "Request file not found: #{source}"
    exit 1
  end
  FileUtils.cp(source, request_target)
else
write_file(request_target, build_request_content(flow, title))
end
write_file(File.join(run_root, "raw/README.md"), build_raw_readme)

copy_template(File.join(ROOT, "docs/templates/workflow-progress.template.md"), File.join(run_root, "progress/workflow-progress.md"))
update_progress_meta(File.join(run_root, "progress/workflow-progress.md"), run_id: run_id, owner: owner, flow: flow)
write_file(File.join(run_root, "progress/decisions.md"), build_decisions_content)
write_file(File.join(run_root, "progress/handoff-notes.md"), build_handoff_content)

case flow
when "init"
  artifact_path = File.join(run_root, "init/init-01.project_profile.yaml")
  run_command("ruby", File.join(ROOT, "scripts/init/init_artifact.rb"), "--step-id", "init-01", "project_profile", artifact_path)
  prompt_content = build_init_prompt(run_root, title)
when "prd"
  artifact_path = File.join(run_root, "prd/prd-01.clarification.yaml")
  run_command("ruby", File.join(ROOT, "scripts/prd/init_artifact.rb"), "--step-id", "prd-01", "clarification", artifact_path)
  prompt_content = build_prd_prompt(run_root, title)
end

write_file(File.join(run_root, "prompts/run-agent-prompt.md"), prompt_content)

puts "Created run workspace at #{run_root}"
puts
puts "接下来这样做："
puts
puts "1. 把一句话需求或项目背景写到：#{relative_to_root(File.join(run_root, 'raw/request.md'))}"
puts "2. 把 PRD、原型、截图等原始材料放到：#{relative_to_root(File.join(run_root, 'raw/attachments'))}"
puts "3. 如果原始材料是 PDF、Word、Excel，建议先转一份 Markdown 再一起放进去"
puts "4. 放好材料后，打开这个文件，把里面整段提示词交给 AI 开始本轮流程：#{relative_to_root(File.join(run_root, 'prompts/run-agent-prompt.md'))}"
puts
puts "补充参考："
puts "- 原始输入说明：#{relative_to_root(File.join(run_root, 'raw/README.md'))}"
puts "- 进度板：#{relative_to_root(File.join(run_root, 'progress/workflow-progress.md'))}"
puts "- 首个正式产物会写到：#{relative_to_root(artifact_path)}"
