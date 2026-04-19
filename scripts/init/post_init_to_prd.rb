#!/usr/bin/env ruby
require "fileutils"
require "pathname"
require "tempfile"
require "yaml"

ROOT = File.expand_path("../..", __dir__)

require_relative "artifact_utils"

def parse_args(argv)
  options = {
    delete_git: true,
  }
  args = argv.dup

  while args.any?
    key = args.shift
    case key
    when "--project-root"
      options[:project_root] = args.shift
    when "--project-name"
      options[:project_name] = args.shift
    when "--prd-run-id"
      options[:prd_run_id] = args.shift
    when "--owner"
      options[:owner] = args.shift
    when "--keep-git"
      options[:delete_git] = false
    when "--remote-url"
      options[:remote_url] = args.shift
    else
      options[:bootstrap_plan] ||= key
    end
  end

  options
end

def usage
  warn "Usage: ruby scripts/init/post_init_to_prd.rb <bootstrap_plan.yml> [--project-root PATH] [--project-name NAME] [--prd-run-id RUN_ID] [--owner NAME] [--keep-git] [--remote-url URL]"
  exit 1
end

def run_command(*command)
  success = system(*command)
  return if success

  warn "Command failed: #{command.join(' ')}"
  exit 1
end

def write_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

def project_title_from_context(context)
  overview = Array(context["project_overview"])
  positioning = overview.find { |line| line.start_with?("项目定位：") }.to_s.sub("项目定位：", "").strip
  positioning.empty? ? "project" : positioning
end

def clean_project_conventions(markdown)
  lines = markdown.lines
  kept = []
  skipping_meta = true

  lines.each do |line|
    if skipping_meta
      next if line.start_with?("> ")
      skipping_meta = false unless line.strip.empty?
    end
    kept << line
  end

  kept.join.lstrip
end

def build_clean_prd_context(context)
  sections = []
  sections << "# Init Bootstrap Context\n"

  sections << "## 项目概况\n\n"
  sections << Array(context["project_overview"]).each_with_index.map { |item, index| "#{index + 1}. #{item}" }.join("\n")
  sections << "\n\n## 已确认基础前提\n\n"
  sections << Array(context["confirmed_foundation"]).each_with_index.map { |item, index| "#{index + 1}. #{item}" }.join("\n")

  sections << "\n\n## 基础模块需求\n\n"
  Array(context["priority_modules"]).each do |item|
    sections << "### #{item['name']}\n\n"
    sections << "- 模块目标：#{item['objective']}\n"
    sections << "- 需求清单：\n"
    sections << Array(item["requirements"]).each_with_index.map { |req, index| "  #{index + 1}. #{req}" }.join("\n")
    sections << "\n"
  end

  sections << "\n## 本轮 PRD 关注点\n\n"
  sections << Array(context["prd_focus"]).each_with_index.map { |item, index| "#{index + 1}. #{item}" }.join("\n")
  sections.join
end

def build_request_markdown(project_name, clean_context_path, clean_context_body)
  <<~MD
    # Request

    ## Flow

    - prd

    ## Title

    - #{project_name} 基础模块 PRD

    ## One-line Requirement

    - 基于已完成的 init 结果，继续完成当前项目的基础模块 PRD，先覆盖登录、账号、租户、权限、框架型组件和平台通用能力组件。

    ## Details

    - 本轮 PRD 直接继承 init 已确认的项目级前提。
    - 项目规则文档：`docs/project/project-conventions.md`
    - init 生成的基础 PRD 上下文：`#{clean_context_path}`

    #{clean_context_body}

    ## Notes

    - 这轮 PRD 不要自行补入任何具体业务功能前提。
    - 优先把基础模块的页面范围、状态流转、数据对象和接口边界拆清楚。
  MD
end

def augment_prd_prompt(prompt_path, project_conventions_path, clean_context_path)
  content = File.read(prompt_path)
  injected_reads = <<~MD
    - #{project_conventions_path}
    - #{clean_context_path}
  MD

  content = content.sub(
    "- `{{RUN_ROOT}}/raw/attachments/`\n",
    "- `{{RUN_ROOT}}/raw/attachments/`\n#{injected_reads}"
  )

  extra_note = <<~MD

    ## 项目内固定规则

    - 你必须始终把 `#{project_conventions_path}` 作为当前项目的长期规则来源。
    - 你必须把 `#{clean_context_path}` 作为本轮 PRD 的 init 继承上下文输入。
    - 如果两者存在冲突，优先保持 `project-conventions` 为项目级长期规则，`init bootstrap context` 只承担本轮 PRD 启动输入。
  MD

  File.write(prompt_path, content + extra_note)
end

options = parse_args(ARGV)
usage if options[:bootstrap_plan].to_s.strip.empty?

bootstrap_plan_path = File.expand_path(options[:bootstrap_plan], Dir.pwd)
usage unless File.exist?(bootstrap_plan_path)

data = InitFlow::ArtifactUtils.load_yaml(bootstrap_plan_path)
errors = InitFlow::ArtifactUtils.validate_artifact("bootstrap_plan", data, artifact_path: bootstrap_plan_path)
unless errors.empty?
  warn "Invalid bootstrap_plan:"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

project_root = File.expand_path(options[:project_root] || Dir.pwd, Dir.pwd)
project_name = options[:project_name].to_s.strip
project_name = project_title_from_context(data["prd_bootstrap_context"] || {}) if project_name.empty?
owner = options[:owner].to_s.strip
owner = ENV["USER"].to_s.strip if owner.empty?
owner = "unknown" if owner.empty?

if options[:delete_git]
  git_dir = File.join(project_root, ".git")
  FileUtils.rm_rf(git_dir) if File.exist?(git_dir)
elsif options[:remote_url].to_s.strip != ""
  git_dir = File.join(project_root, ".git")
  if Dir.exist?(git_dir)
    if system("git", "-C", project_root, "remote", "get-url", "origin", out: File::NULL, err: File::NULL)
      run_command("git", "-C", project_root, "remote", "set-url", "origin", options[:remote_url])
    else
      run_command("git", "-C", project_root, "remote", "add", "origin", options[:remote_url])
    end
  end
end

Tempfile.create(["project-conventions", ".md"]) do |tmp|
  tmp.close
  run_command("ruby", File.join(ROOT, "scripts/init/render_project_conventions.rb"), bootstrap_plan_path, tmp.path)
  clean_conventions = clean_project_conventions(File.read(tmp.path))
  write_file(File.join(project_root, "docs/project/project-conventions.md"), clean_conventions)
end

context = data["prd_bootstrap_context"] || {}
clean_context_body = build_clean_prd_context(context)

Tempfile.create(["prd-request", ".md"]) do |tmp|
  tmp.write(build_request_markdown(project_name, "raw/attachments/init-prd-context.md", clean_context_body))
  tmp.close

  prd_run_id = options[:prd_run_id].to_s.strip
  command = [
    "ruby", File.join(ROOT, "scripts/create_run.rb"),
    "--flow", "prd",
    "--title", "#{project_name} 基础模块 PRD",
    "--request-file", tmp.path,
    "--owner", owner
  ]
  command += ["--run-id", prd_run_id] unless prd_run_id.empty?
  run_command(*command)
end

runs_root = File.join(ROOT, "runs")
created_run = Dir.children(runs_root)
  .map { |entry| File.join(runs_root, entry) }
  .select { |path| File.directory?(path) }
  .max_by { |path| File.mtime(path) }

unless created_run
  warn "Failed to locate newly created prd run"
  exit 3
end

clean_context_target = File.join(created_run, "raw/attachments/init-prd-context.md")
write_file(clean_context_target, clean_context_body)
write_file(File.join(created_run, "raw/request.md"), build_request_markdown(project_name, "raw/attachments/init-prd-context.md", clean_context_body))
augment_prd_prompt(File.join(created_run, "prompts/run-agent-prompt.md"), "docs/project/project-conventions.md", "raw/attachments/init-prd-context.md")

puts "Project conventions written to #{File.join(project_root, 'docs/project/project-conventions.md')}"
puts "Created prd run at #{created_run}"
puts "Injected clean init bootstrap context into #{File.join(created_run, 'raw/attachments/init-prd-context.md')}"
puts "Updated raw/request.md and prompts/run-agent-prompt.md for the new PRD run"
