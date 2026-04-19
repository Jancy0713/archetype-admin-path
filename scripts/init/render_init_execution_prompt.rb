#!/usr/bin/env ruby
require "fileutils"
require "pathname"
require "shellwords"

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
      if options[:bootstrap_plan].nil?
        options[:bootstrap_plan] = key
      elsif options[:target].nil?
        options[:target] = key
      end
    end
  end

  options
end

def usage
  warn "Usage: ruby scripts/init/render_init_execution_prompt.rb <bootstrap_plan.yml> <target.md> [--project-root PATH] [--project-name NAME] [--keep-git] [--remote-url URL] [--owner NAME] [--prd-run-id RUN_ID]"
  exit 1
end

def infer_run_root(bootstrap_plan_path)
  candidate = File.expand_path("..", File.dirname(bootstrap_plan_path))
  return candidate if File.basename(candidate) == "init"

  candidate = File.expand_path("..", candidate)
  return candidate if Dir.exist?(File.join(candidate, "rendered"))

  File.expand_path("..", File.dirname(bootstrap_plan_path))
end

def relative_to(path, base)
  Pathname.new(path).relative_path_from(Pathname.new(base)).to_s
end

def project_title_from_context(data)
  context = data["prd_bootstrap_context"] || {}
  project_overview = Array(context["project_overview"])
  line = project_overview.find { |item| item.start_with?("项目定位：") }.to_s
  title = line.sub("项目定位：", "").strip
  title.empty? ? "project" : title
end

def build_post_command(bootstrap_plan_path, options)
  command = [
    "ruby", File.join(ROOT, "scripts/init/post_init_to_prd.rb"),
    bootstrap_plan_path,
    "--project-root", File.expand_path(options[:project_root], Dir.pwd),
    "--project-name", options[:project_name],
    "--owner", options[:owner]
  ]
  command << "--keep-git" unless options[:delete_git]
  command += ["--remote-url", options[:remote_url]] if options[:remote_url].to_s.strip != ""
  command += ["--prd-run-id", options[:prd_run_id]] if options[:prd_run_id].to_s.strip != ""
  command
end

def numbered_lines(items)
  Array(items).each_with_index.map { |item, index| "#{index + 1}. #{item}" }.join("\n")
end

options = parse_args(ARGV)
usage if options[:bootstrap_plan].to_s.strip.empty? || options[:target].to_s.strip.empty?

bootstrap_plan_path = File.expand_path(options[:bootstrap_plan], Dir.pwd)
target = File.expand_path(options[:target], Dir.pwd)
usage unless File.exist?(bootstrap_plan_path)

data = InitFlow::ArtifactUtils.load_yaml(bootstrap_plan_path)
errors = InitFlow::ArtifactUtils.validate_artifact("bootstrap_plan", data, artifact_path: bootstrap_plan_path)
unless errors.empty?
  warn "Cannot render init execution prompt from invalid bootstrap_plan: #{bootstrap_plan_path}"
  errors.each { |error| warn "- #{error}" }
  exit 2
end

run_root = infer_run_root(bootstrap_plan_path)
run_root = File.expand_path("..", run_root) if File.basename(run_root) == "init"
scope_path = File.join(run_root, "rendered/init-08.init-execution-scope.md")
design_seed_path = File.join(run_root, "rendered/init-06.design_seed.md")
bootstrap_render_path = File.join(run_root, "rendered/init-07.bootstrap_plan.md")
project_root = File.expand_path(options[:project_root], Dir.pwd)
project_conventions_path = File.join(project_root, "docs/project/project-conventions.md")
project_name = options[:project_name].to_s.strip
project_name = project_title_from_context(data) if project_name.empty?
owner = options[:owner].to_s.strip
owner = ENV["USER"].to_s.strip if owner.empty?
owner = "unknown" if owner.empty?
options[:project_name] = project_name
options[:owner] = owner
post_command = Shellwords.join(build_post_command(bootstrap_plan_path, options))
scope = data["init_execution_scope"] || {}

content = <<~MD
  # Init-08 Execution Prompt

  你现在负责执行 `init-08 execution`，目标是把当前项目的工程初始化落地到代码层，然后在完成后自动把流程切到新的 PRD run。

  ## 读取输入

  你开始前必须先完整阅读以下文件：

  - `#{relative_to(design_seed_path, ROOT)}`
  - `#{relative_to(bootstrap_render_path, ROOT)}`
  - `#{relative_to(scope_path, ROOT)}`
  - `#{project_conventions_path}`

  ## 固定执行参数

  - 项目名称：`#{project_name}`
  - 初始化目录：`#{project_root}`
  - git 处理：#{options[:delete_git] ? "已按默认策略删除现有 .git" : "保留现有 .git"}
  - remote-url：#{options[:remote_url].to_s.strip.empty? ? "未指定" : options[:remote_url]}
  - owner：`#{owner}`
  - prd-run-id：#{options[:prd_run_id].to_s.strip.empty? ? "未指定，按 create_run 默认生成" : options[:prd_run_id]}

  ## 本轮允许做的事

  #{numbered_lines(scope["allowed_work"])}

  ## 本轮明确不做

  #{numbered_lines(scope["excluded_work"])}

  ## 你必须完成的动作

  1. 严格按 `Init Execution Scope` 执行工程初始化，优先使用官方脚手架和当前版本推荐命令完成 refine、shadcn、tailwind 等基础接入。
  2. 所有命令、依赖和目录结构都必须以当前实际版本为准，不得照抄过时模板。
  3. 生成或修正 scope 中要求的主题、provider、平台默认能力占位和文档落位。
  4. 清理与当前项目无关的默认模板、示例页面和演示数据，避免把无关业务壳子带进仓库。
  5. AI 补强只允许停留在工程基座层，不实现真实业务页面、业务接口、业务状态流转和业务权限细节。
  6. 如 scope 中某项依赖真实业务 contract 才能继续，你必须停止在占位层，并在汇报里明确标记为留待后续 PRD。
  7. 完成初始化后，你必须先向用户汇报：
     - 实际执行了哪些命令
     - 生成/修改了哪些关键文件
     - 哪些能力包已落地，哪些只保留占位
     - 是否还有需要后续 PRD 再补的边界

  ## 完成后必须执行

  当且仅当工程初始化已经完成，再执行下面这条命令，自动创建新的 PRD run 并注入上下文：

  ```bash
  #{post_command}
  ```

  执行完上面的命令后，你还必须补充汇报：

  - 新创建的 PRD run 路径
  - 已写入的 `raw/request.md`
  - 已注入的 `raw/attachments/init-prd-context.md`
  - 新的 `prompts/run-agent-prompt.md` 已可直接用于后续 PRD

  ## 最终完成标准

  #{numbered_lines(scope["completion_criteria"])}
MD

FileUtils.mkdir_p(File.dirname(target))
File.write(target, content)
puts "Rendered init execution prompt to #{target}"
