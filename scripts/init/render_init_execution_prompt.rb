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
    when "--project-dir-name"
      options[:project_dir_name] = args.shift
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
  warn "Usage: ruby scripts/init/render_init_execution_prompt.rb <bootstrap_plan.yml> <target.md> [--project-root PATH] [--project-dir-name NAME] [--project-name NAME] [--keep-git] [--remote-url URL] [--owner NAME] [--prd-run-id RUN_ID]"
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

def slugify(text)
  ascii = text.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-+|-+\z/, "")
  ascii.empty? ? nil : ascii
end

def default_project_dir_name(project_name, data)
  candidates = [
    project_name,
    project_title_from_context(data),
    data.dig("meta", "title")
  ]

  candidates.each do |candidate|
    slug = slugify(candidate)
    return slug unless slug.nil? || slug == "project"
  end

  "project-app"
end

def resolve_project_location(options, data, project_name)
  base_root = File.expand_path(options[:project_root], Dir.pwd)
  dir_name = options[:project_dir_name].to_s.strip
  if dir_name.empty?
    basename = File.basename(base_root)
    return [base_root, basename] unless basename.nil? || basename.empty? || basename == "."

    dir_name = default_project_dir_name(project_name, data)
    return [File.expand_path(dir_name, base_root), dir_name]
  end

  return [base_root, dir_name] if File.basename(base_root) == dir_name

  [File.expand_path(dir_name, base_root), dir_name]
end

def build_post_command(bootstrap_plan_path, options)
  project_root, = resolve_project_location(options, options[:data], options[:project_name])

  command = [
    "ruby", File.join(ROOT, "scripts/init/post_init_to_prd.rb"),
    bootstrap_plan_path,
    "--project-root", project_root,
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
scope_path = File.join(run_root, "rendered/init-07.init-execution-scope.md")
design_seed_path = File.join(run_root, "rendered/init-06.design_seed.md")
bootstrap_render_path = File.join(run_root, "rendered/init-07.bootstrap_plan.md")
prepared_conventions_path = File.join(run_root, "rendered/init-08.project-conventions.md")
project_name = options[:project_name].to_s.strip
project_name = project_title_from_context(data) if project_name.empty?
project_root, project_dir_name = resolve_project_location(options, data, project_name)
project_conventions_path = File.join(project_root, "docs/project/project-conventions.md")
owner = options[:owner].to_s.strip
owner = ENV["USER"].to_s.strip if owner.empty?
owner = "unknown" if owner.empty?
options[:project_name] = project_name
options[:owner] = owner
options[:data] = data
post_command = Shellwords.join(build_post_command(bootstrap_plan_path, options))
reviewer_prompt_path = File.join(File.dirname(target), "init-08-reviewer-prompt.md")
scope = data["init_execution_scope"] || {}

content = <<~MD
  # Init-08 Execution Prompt

  你现在负责执行 `init-08 execution`，目标是把当前项目的工程初始化落地到代码层，然后在完成后自动把流程切到新的 PRD run。

  这份 prompt 设计给新的执行上下文使用。不要假设你能访问 `init-01` 到 `init-07` 的历史聊天；你必须只依赖下面列出的输入文件和本 prompt 中的固定参数执行。

  你不是 `init` 主流程里的主 agent，而是专门负责 `init-08` 的执行代理。

  ## 读取输入

  你开始前必须先完整阅读以下文件：

  - `#{relative_to(design_seed_path, ROOT)}`
  - `#{relative_to(bootstrap_render_path, ROOT)}`
  - `#{relative_to(scope_path, ROOT)}`
  - `#{relative_to(prepared_conventions_path, ROOT)}`

  ## 固定执行参数

  - 项目名称：`#{project_name}`
  - 目录 slug：`#{project_dir_name}`
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
  3. 先基于 `#{relative_to(prepared_conventions_path, ROOT)}`，把项目长期规则文件写入实际代码目录 `#{project_conventions_path}`，再继续完成 scope 中要求的主题、provider、平台默认能力占位和文档落位。
  4. 清理与当前项目无关的默认模板、示例页面和演示数据，避免把无关业务壳子带进仓库。
  5. 不要在最终交付目录保留 `__seed`、`seed`、`template-copy` 等脚手架快照目录；如果生成过程里临时保留过，结束前必须删除。
  6. AI 补强只允许停留在工程基座层，不实现真实业务页面、业务接口、业务状态流转和业务权限细节。
  7. 如 scope 中某项依赖真实业务 contract 才能继续，你必须停止在占位层，并在汇报里明确标记为留待后续 PRD。
  8. 完成初始化后，你必须先向用户汇报：
     - 实际执行了哪些命令
     - 生成/修改了哪些关键文件
     - 哪些能力包已落地，哪些只保留占位
     - 是否还有需要后续 PRD 再补的边界
  9. 在工程初始化完成并完成首轮自查后，必须把 `#{relative_to(reviewer_prompt_path, ROOT)}` 整段交给独立 reviewer 子 agent 或独立新上下文执行审查；主执行 agent 不得自己兼任 reviewer。
  10. reviewer 只审查工程结果是否仍停留在工程基座层、规则文档是否落到了实际代码目录、以及是否混入真实业务实现；如果 reviewer 给出阻塞项，你必须先在当前 scope 内修正，再重新发起一次 reviewer 审查。
  11. 只有 reviewer 明确通过后，才能继续执行 `post_init_to_prd.rb`；不要回头重写 `init-07` 产物。如果发现输入缺失，只能在当前 scope 内做最小必要占位，并在汇报里标明留待后续 PRD 或人工决策。
  12. `post_init_to_prd.rb` 会自动创建新的 PRD run、初始化新的进度板和提示词。你不得手动把上一轮 `init` 的步骤状态、进度表内容或 reviewer 状态回填到新 PRD run 中。

  ## 完成后必须执行

  当且仅当工程初始化已经完成且 reviewer 已通过，再执行下面这条命令，自动创建新的 PRD run 并注入上下文：

  ```bash
  #{post_command}
  ```

  执行完上面的命令后，你还必须补充汇报：

  - 新创建的 PRD run 路径
  - 已写入的 `raw/request.md`
  - 已注入的 `raw/attachments/confirmed-foundation.md`
  - 已注入的 `raw/attachments/base-modules-prd.md`
  - 新的 `prompts/run-agent-prompt.md` 已可直接用于后续 PRD

  ## 最终完成标准

  #{numbered_lines(scope["completion_criteria"])}
MD

FileUtils.mkdir_p(File.dirname(target))
File.write(target, content)
puts "Rendered init execution prompt to #{target}"

reviewer_content = <<~MD
  # Init-08 Reviewer Prompt

  你现在负责执行 `init-08 execution` 完成后的 reviewer 审查。

  reviewer 必须由独立 reviewer 子 agent 或独立新上下文执行，不能让主执行 agent 自己兼任 reviewer。

  ## 读取输入

  你开始前必须先完整阅读以下文件，并检查实际项目目录：

  - `#{relative_to(design_seed_path, ROOT)}`
  - `#{relative_to(bootstrap_render_path, ROOT)}`
  - `#{relative_to(scope_path, ROOT)}`
  - `#{relative_to(prepared_conventions_path, ROOT)}`
  - `#{project_conventions_path}`
  - 实际项目目录：`#{project_root}`

  ## 审查目标

  1. 检查实际项目规则文件是否已经落位到 `#{project_conventions_path}`，且内容与 run 内准备稿一致，没有额外漂移到外层容器目录。
  2. 检查工程初始化结果是否仍停留在工程基座层，只包含主题 token、providers、平台能力占位、基础壳层和文档落位。
  3. 检查是否混入真实业务模块页面、真实业务接口、业务 contract、演示性假数据流程或权限/租户细节实现。
  4. 检查生成目录是否清晰：实际代码根目录应以 `#{project_root}` 为准，不应再额外保留一层重复的 `docs/project/project-conventions.md`。
  5. 检查初始化结果是否覆盖 `Init Execution Scope` 中要求的主题、provider、upload/export/notifications/audit 占位和后续 PRD 边界说明。
  6. 检查主执行代理的交接计划是否仍把新 PRD run 交给 `post_init_to_prd.rb` 自动初始化，而不是打算手工拷贝上一轮 `init` 的进度表或状态。

  ## 输出要求

  1. 只输出一段简洁审查结论，使用以下结构：
     - `结论：通过` 或 `结论：阻塞`
     - `检查项：`
     - `发现：`
     - `建议动作：`
  2. 如果存在阻塞项，必须明确指出阻塞文件或目录，并说明为什么它违反了工程基座范围。
  3. 如果未发现阻塞项，也要明确说明你已核对实际项目目录、规则文档路径和能力占位范围。
  4. reviewer 不直接改代码，不重写 prompt，不执行 `post_init_to_prd.rb`。
MD

File.write(reviewer_prompt_path, reviewer_content)
puts "Rendered init reviewer prompt to #{reviewer_prompt_path}"
