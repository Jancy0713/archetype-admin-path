#!/usr/bin/env ruby
require "fileutils"
require "pathname"
require "shellwords"
require "tmpdir"
require "yaml"

ROOT = File.expand_path("../..", __dir__)

require_relative "artifact_utils"

def parse_args(argv)
  options = {
    delete_git: true,
    project_root: Dir.pwd,
  }
  args = argv.dup

  while args.any?
    key = args.shift
    case key
    when "--project-root"
      options[:project_root] = args.shift
    when "--project-name"
      options[:project_name] = args.shift
    when "--keep-git"
      options[:delete_git] = false
    when "--remote-url"
      options[:remote_url] = args.shift
    when "--owner"
      options[:owner] = args.shift
    when "--prd-run-id"
      options[:prd_run_id] = args.shift
    else
      options[:bootstrap_plan] ||= key
    end
  end

  options
end

def usage
  warn "Usage: ruby scripts/init/execute_init_scope.rb <bootstrap_plan.yml> [--project-root PATH] [--project-name NAME] [--keep-git] [--remote-url URL] [--owner NAME] [--prd-run-id RUN_ID]"
  exit 1
end

def run_command(*command)
  success = system(*command)
  return if success

  warn "Command failed: #{command.join(' ')}"
  exit 1
end

def relative_to(path, base)
  Pathname.new(path).relative_path_from(Pathname.new(base)).to_s
end

def write_file(path, content)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, content)
end

def clean_project_conventions(markdown)
  markdown.lines.reject { |line| line.start_with?("> ") }.join.lstrip
end

def infer_run_root(bootstrap_plan_path)
  candidate = File.expand_path("..", File.dirname(bootstrap_plan_path))
  return candidate if File.basename(candidate) == "init"

  candidate = File.expand_path("..", candidate)
  return candidate if Dir.exist?(File.join(candidate, "rendered"))

  File.expand_path("..", File.dirname(bootstrap_plan_path))
end

def project_title_from_context(data)
  context = data["prd_bootstrap_context"] || {}
  project_overview = Array(context["project_overview"])
  line = project_overview.find { |item| item.start_with?("项目定位：") }.to_s
  title = line.sub("项目定位：", "").strip
  title.empty? ? "project" : title
end

def build_post_command(bootstrap_plan_path, project_root:, project_name:, owner:, delete_git:, remote_url:, prd_run_id:)
  command = [
    "ruby", File.join(ROOT, "scripts/init/post_init_to_prd.rb"),
    bootstrap_plan_path,
    "--project-root", project_root,
    "--project-name", project_name,
    "--owner", owner
  ]
  command << "--keep-git" unless delete_git
  command += ["--remote-url", remote_url] if remote_url.to_s.strip != ""
  command += ["--prd-run-id", prd_run_id] if prd_run_id.to_s.strip != ""
  Shellwords.join(command)
end

def build_execution_summary(data:, project_root:, delete_git:, conventions_path:, scope_path:, prompt_path:, post_command:)
  scope = data["init_execution_scope"] || {}
  [
    "# Init Execution Preparation Summary",
    "",
    "## 准备结果",
    "",
    "1. 已按当前 bootstrap_plan 渲染 `Init Execution Scope`：`#{scope_path}`",
    "2. 已写入项目规则文件：`#{conventions_path}`",
    "3. 初始化目标目录：`#{project_root}`",
    "4. git 处理：#{delete_git ? '已按默认选项删除现有 .git' : '保留现有 .git'}",
    "5. 已生成执行代理专用 prompt：`#{prompt_path}`",
    "",
    "## 本轮已预备内容",
    "",
    Array(scope["deliverables"]).each_with_index.map { |item, index| "#{index + 1}. #{item}" }.join("\n"),
    "",
    "## 下一步标准动作",
    "",
    "1. 把 `#{prompt_path}` 整段交给执行代理，让其按 scope 完成工程初始化命令与 AI 补强。",
    "2. 执行代理完成初始化后，必须运行下面这条命令自动进入 PRD：",
    "",
    "```bash",
    post_command,
    "```",
    "",
    "3. `post_init_to_prd.rb` 完成后，会自动创建新的 PRD run、注入干净版上下文、预填 `raw/request.md`，并增强新的 `prompts/run-agent-prompt.md`。"
  ].join("\n")
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

project_root = File.expand_path(options[:project_root], Dir.pwd)
project_name = options[:project_name].to_s.strip
project_name = project_title_from_context(data) if project_name.empty?
owner = options[:owner].to_s.strip
owner = ENV["USER"].to_s.strip if owner.empty?
owner = "unknown" if owner.empty?
run_root = infer_run_root(bootstrap_plan_path)
run_root = File.expand_path("..", run_root) if File.basename(run_root) == "init"

execution_scope_render = File.join(run_root, "rendered/init-08.init-execution-scope.md")
run_command("ruby", File.join(ROOT, "scripts/init/render_init_execution_scope.rb"), bootstrap_plan_path, execution_scope_render)

project_conventions_tmp = File.join(Dir.tmpdir, "project-conventions-#{Process.pid}.md")
run_command("ruby", File.join(ROOT, "scripts/init/render_project_conventions.rb"), bootstrap_plan_path, project_conventions_tmp)
clean_conventions = clean_project_conventions(File.read(project_conventions_tmp))
project_conventions_path = File.join(project_root, "docs/project/project-conventions.md")
write_file(project_conventions_path, clean_conventions)
FileUtils.rm_f(project_conventions_tmp)

if options[:delete_git]
  git_dir = File.join(project_root, ".git")
  FileUtils.rm_rf(git_dir) if File.exist?(git_dir)
elsif options[:remote_url].to_s.strip != "" && Dir.exist?(File.join(project_root, ".git"))
  if system("git", "-C", project_root, "remote", "get-url", "origin", out: File::NULL, err: File::NULL)
    run_command("git", "-C", project_root, "remote", "set-url", "origin", options[:remote_url])
  else
    run_command("git", "-C", project_root, "remote", "add", "origin", options[:remote_url])
  end
end

execution_prompt_path = File.join(run_root, "prompts/init-08-execution-prompt.md")
run_command(
  "ruby", File.join(ROOT, "scripts/init/render_init_execution_prompt.rb"),
  bootstrap_plan_path,
  execution_prompt_path,
  "--project-root", project_root,
  "--project-name", project_name,
  "--owner", owner,
  *(options[:delete_git] ? [] : ["--keep-git"]),
  *(options[:remote_url].to_s.strip == "" ? [] : ["--remote-url", options[:remote_url]]),
  *(options[:prd_run_id].to_s.strip == "" ? [] : ["--prd-run-id", options[:prd_run_id]])
)

post_command = build_post_command(
  bootstrap_plan_path,
  project_root: project_root,
  project_name: project_name,
  owner: owner,
  delete_git: options[:delete_git],
  remote_url: options[:remote_url],
  prd_run_id: options[:prd_run_id]
)

summary_path = File.join(run_root, "rendered/init-08.execution-summary.md")
summary = build_execution_summary(
  data: data,
  project_root: project_root,
  delete_git: options[:delete_git],
  conventions_path: relative_to(project_conventions_path, project_root),
  scope_path: relative_to(execution_scope_render, ROOT),
  prompt_path: relative_to(execution_prompt_path, ROOT),
  post_command: post_command
)
write_file(summary_path, summary)

puts "Rendered init execution scope to #{execution_scope_render}"
puts "Wrote clean project conventions to #{project_conventions_path}"
puts "Rendered init execution prompt to #{execution_prompt_path}"
puts "Execution summary written to #{summary_path}"
