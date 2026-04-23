#!/usr/bin/env ruby
require "fileutils"
require "pathname"
require "time"
require "date"
require_relative "init/workflow_manifest"
require_relative "prd/artifact_utils"
require_relative "prd/workflow_manifest"
require_relative "progress_board"

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

def write_yaml_file(path, data)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, YAML.dump(data))
end

def normalize_progress_template(progress_path, flow)
  lines = File.readlines(progress_path, chomp: true)
  section_headers = [
    "## Meta",
    "## Current Focus",
    "## Inputs",
    "## Init Progress",
    "## PRD Progress",
    "## Decisions",
    "## Handoff Notes",
    "## Status Legend",
    "## Update Rules"
  ]

  current_section = nil
  filtered = lines.select do |line|
    current_section = line if section_headers.include?(line)

    case current_section
    when "## Init Progress"
      flow == "init"
    when "## PRD Progress"
      flow == "prd"
    else
      true
    end
  end

  File.write(progress_path, filtered.join("\n") + "\n")
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

    ## One-line Requirement

    - 必填：一句话描述你的需求

    ## Details

    - 可选：详细说明；如果已经在附件里放了 PRD / 原型，这里可以跳过

    ## Notes

    - 选填：补充背景、限制、偏好、测试重点

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

    建议填写方式：

    - `request.md > One-line Requirement`：必填，一句话描述你的需求
    - `request.md > Details`：可选，详细说明；如果附件里已有 PRD，可留空
    - `request.md > Notes`：选填，补充限制、偏好、测试重点
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

    - reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行，主 agent 不得自己兼任 reviewer。
    - `init-07` 用户确认通过后，不要继续复用 `init-01` 到 `init-07` 的长对话直接跑 `init-08`。
    - 应先生成 `prompts/init-08-execution-prompt.md`，再新开一个干净上下文，把整段 prompt 交给新的执行代理。
  MD
end

def build_prd_materials_readme
  <<~MD
    # PRD Materials Snapshot

    这里是当前 run 固定下来的 PRD 材料快照。

    使用方式：

    1. 主产物前，先读 `artifacts/<artifact>.yml`
    2. reviewer 前，先读 `reviews/<review_step>.yml`
    3. 如果全局文档后续继续演进，这里的快照仍可作为当前 run 的稳定入口

    当前目录：

    - `artifacts/analysis.yml`
    - `artifacts/clarification.yml`
    - `artifacts/execution_plan.yml`
    - `artifacts/final_prd.yml`
    - `reviews/prd_analysis.yml`
    - `reviews/prd_clarification.yml`
    - `reviews/prd_execution_plan.yml`
    - `reviews/final_prd_ready.yml`
  MD
end

def write_prd_material_snapshots(run_root)
  base = File.join(run_root, "prompts", "materials")
  write_file(File.join(base, "README.md"), build_prd_materials_readme)

  %w[analysis clarification execution_plan final_prd].each do |artifact|
    payload = Prd::ArtifactUtils.artifact_materials(artifact)
    write_yaml_file(File.join(base, "artifacts", "#{artifact}.yml"), payload)
  end

  Prd::ArtifactUtils::REVIEWABLE_STEPS.each do |review_step|
    payload = Prd::ArtifactUtils.review_materials(review_step)
    write_yaml_file(File.join(base, "reviews", "#{review_step}.yml"), payload)
  end
end

def build_init_prompt(run_root, title)
  build_autonomous_prompt(
    flow: "init",
    template_path: File.join(ROOT, "docs/templates/autonomous-run-prompt.template.md"),
    run_root: run_root,
    first_step_id: InitFlow::WorkflowManifest.first_step_id,
    first_artifact: InitFlow::WorkflowManifest.first_artifact_relative_path,
    first_review: InitFlow::WorkflowManifest.first_review_relative_path,
    validate_command: InitFlow::WorkflowManifest.first_validate_command(run_root),
    render_command: InitFlow::WorkflowManifest.first_render_command(run_root)
  )
end

def build_prd_prompt(run_root, title)
  build_autonomous_prompt(
    flow: "prd",
    template_path: File.join(ROOT, "docs/templates/autonomous-run-prompt.prd.template.md"),
    run_root: run_root,
    first_step_id: PrdFlow::WorkflowManifest.first_step_id,
    first_artifact: PrdFlow::WorkflowManifest.first_artifact_relative_path,
    first_review: PrdFlow::WorkflowManifest.first_review_relative_path,
    validate_command: PrdFlow::WorkflowManifest.validate_command(PrdFlow::WorkflowManifest.first_step_id, run_root),
    render_command: PrdFlow::WorkflowManifest.render_command(PrdFlow::WorkflowManifest.first_step_id, run_root)
  )
end

def build_autonomous_prompt(flow:, template_path:, run_root:, first_step_id:, first_artifact:, first_review:, validate_command:, render_command:)
  template = File.read(template_path)
  replacements = {
    "{{FLOW}}" => flow,
    "{{RUN_ROOT}}" => run_root,
    "{{FLOW_README}}" => "/Users/wangwenjie/project/archetype-admin-path/docs/#{flow}/README.md",
    "{{FLOW_WORKFLOW_GUIDE}}" => "/Users/wangwenjie/project/archetype-admin-path/docs/#{flow}/WORKFLOW_GUIDE.md",
    "{{FLOW_STEP_GUIDE}}" => "/Users/wangwenjie/project/archetype-admin-path/docs/#{flow}/STEP_NAMING_GUIDE.md",
    "{{FLOW_PROMPTS_INDEX}}" => flow == "init" ? "/Users/wangwenjie/project/archetype-admin-path/docs/init/prompts/README.md" : "/Users/wangwenjie/project/archetype-admin-path/docs/prd/prompts/README.md",
    "{{FLOW_REFACTOR_GUIDE}}" => flow == "init" ? "/Users/wangwenjie/project/archetype-admin-path/docs/init/WORKFLOW_REFACTOR_GUIDE.md" : "/Users/wangwenjie/project/archetype-admin-path/docs/prd/WORKFLOW_GUIDE.md",
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
    InitFlow::WorkflowManifest.command_cheat_sheet(run_root)
  when "prd"
    PrdFlow::WorkflowManifest.command_cheat_sheet(run_root)
  end
end

def update_progress_meta(progress_path, run_id:, owner:, flow:)
  lines = File.readlines(progress_path, chomp: true)
  initial_meta =
    if flow == "init"
      InitFlow::WorkflowManifest.initial_progress_meta
    else
      PrdFlow::WorkflowManifest.initial_progress_meta
    end
  replacements = {
    "- run_id:" => "- run_id: #{run_id}",
    "- owner:" => "- owner: #{owner}",
    "- started_at:" => "- started_at: #{Time.now.iso8601}",
    "- current_flow:" => "- current_flow: #{flow}",
    "- current_step_id:" => "- current_step_id: #{initial_meta.fetch('current_step_id')}",
    "- overall_status:" => "- overall_status: #{initial_meta.fetch('overall_status')}",
    "- current_goal:" => "- current_goal: #{initial_meta.fetch('current_goal')}",
    "- current_blocker:" => "- current_blocker: ",
    "- next_agent_input:" => "- next_agent_input: #{initial_meta.fetch('next_agent_input')}",
    "- next_expected_output:" => "- next_expected_output: #{initial_meta.fetch('next_expected_output')}",
    "- raw_request:" => "- raw_request: raw/request.md",
    "- attachments:" => "- attachments: raw/attachments/",
    "- baseline_if_any:" => "- baseline_if_any: "
  }

  updated = lines.map do |line|
    replacement = replacements.keys.find { |prefix| line.start_with?(prefix) }
    replacement ? replacements.fetch(replacement) : line
  end

  first_step_id = flow == "init" ? "`#{InitFlow::WorkflowManifest.first_step_id}`" : "`#{PrdFlow::WorkflowManifest.first_step_id}`"
  File.write(progress_path, updated.join("\n") + "\n")
  board = WorkflowProgressBoard::Board.new(progress_path)
  board.update_row(first_step_id.delete("`"), status: "doing")
  board.save
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
normalize_progress_template(File.join(run_root, "progress/workflow-progress.md"), flow)
update_progress_meta(File.join(run_root, "progress/workflow-progress.md"), run_id: run_id, owner: owner, flow: flow)
write_file(File.join(run_root, "progress/decisions.md"), build_decisions_content)
write_file(File.join(run_root, "progress/handoff-notes.md"), build_handoff_content)

case flow
when "init"
  artifact_path = File.join(run_root, InitFlow::WorkflowManifest.first_artifact_relative_path)
  run_command("ruby", File.join(ROOT, "scripts/init/profile/init_project_profile_step.rb"), run_root, InitFlow::WorkflowManifest.first_step_id)
  prompt_content = build_init_prompt(run_root, title)
when "prd"
  artifact_path = File.join(run_root, PrdFlow::WorkflowManifest.first_artifact_relative_path)
  run_command("ruby", File.join(ROOT, "scripts/prd/init_artifact.rb"), "--step-id", PrdFlow::WorkflowManifest.first_step_id, PrdFlow::WorkflowManifest.first_artifact, artifact_path)
  write_prd_material_snapshots(run_root)
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
if flow == "init"
  puts "5. 如果流程推进到 `init-07 -> init-08`，必须改为新开上下文执行 `prompts/init-08-execution-prompt.md`；不要继续复用前面 01-07 的长对话"
end
puts
puts "补充参考："
puts "- 原始输入说明：#{relative_to_root(File.join(run_root, 'raw/README.md'))}"
puts "- 进度板：#{relative_to_root(File.join(run_root, 'progress/workflow-progress.md'))}"
puts "- 交接说明：#{relative_to_root(File.join(run_root, 'progress/handoff-notes.md'))}"
puts "- PRD 材料快照：#{relative_to_root(File.join(run_root, 'prompts/materials/README.md'))}" if flow == "prd"
puts "- 首个正式产物会写到：#{relative_to_root(artifact_path)}"
