#!/usr/bin/env ruby
# settle_baseline.rb
# 用途：将单个 contract flow 从 contract/release/ 迁移至 baselines/<flow-id>/current/，作为已验证的稳定基线沉淀。

require 'fileutils'
require 'time'
require_relative 'workflow_manifest'

ROOT = File.expand_path("../..", __dir__)

if ARGV.length != 1
  puts "Usage: #{$0} <flow-id>"
  puts "Example: #{$0} user-registration"
  exit 1
end

flow_id = ARGV[0]
run_root = ContractFlow::WorkflowManifest.run_root(ROOT, flow_id, mode: :read)
release_dir = ContractFlow::WorkflowManifest.release_dir_path(run_root)

if !Dir.exist?(release_dir)
  puts "Error: Release directory not found at #{release_dir}"
  exit 1
end

develop_dir = File.join(run_root, "develop")
verification_artifact = File.join(develop_dir, "verification.md")

if !File.exist?(verification_artifact)
  puts "Error: Missing develop verification artifact at #{verification_artifact}"
  puts "Baseline settlement blocked: Expected realization proof before settling the baseline."
  exit 1
end

def baselines_root(root)
  override = ENV["CONTRACT_BASELINES_ROOT"].to_s.strip
  return File.expand_path(override) unless override.empty?

  File.join(root, "baselines")
end

baseline_dir = File.join(baselines_root(ROOT), flow_id)
current_baseline_dir = File.join(baseline_dir, "current")

puts "==> Settling baseline for flow: #{flow_id}..."

# 创建基线目录
FileUtils.mkdir_p(current_baseline_dir)

# 同步文件并验证是否包含必需的发布件
expected_files = ['contract.yaml', 'contract.summary.md', 'openapi.yaml', 'openapi.summary.md', 'develop-handoff.md']
files_copied = []

expected_files.each do |file|
  src = File.join(release_dir, file)
  if File.exist?(src)
    dest_name = (file == 'develop-handoff.md') ? 'develop-verified-handoff.md' : file
    dest = File.join(current_baseline_dir, dest_name)
    FileUtils.cp(src, dest)
    files_copied << file
    puts "  [Copied] #{file} -> #{dest}"
  else
    puts "  [Warning] Missing #{file} in release directory."
  end
end

if files_copied.length != expected_files.length
  puts "Error: Missing required files for settlement. Are all contract artifacts rendered?"
  exit 1
end

# 新增 implementation-settlement.md 的写入
settlement_path = File.join(current_baseline_dir, "implementation-settlement.md")
current_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S%z")

settlement_content = <<~EOF
# Implementation Settlement

**Flow ID:** #{flow_id}
**Settled At:** #{current_time}

## Baseline Status
该版本已通过 `develop` 阶段的实现验证。本文档及其所在的 `current/` 目录构成当前该 flow 的正式、稳定基线 (Source of Truth)。
它是开发人员、QA 测试、且最终实现完成后的基准协议包。

## 变更溯源 (Next Steps)
如果后续对该业务域产生增量变更需求：
1. **优先入口**：如只涉及字段增补、协议状态机内变动，默认应当基于此 Baseline `current/` 为源点进行增量修改并重新拉起独立流程。
2. **更高层级变更**：若需打散 Flow 或影响整体产品依赖，依旧要求退回更上游的 `contract_handoff/` 或 `final_prd/` 处理并重新规划 flow 序列。

---
*Auto-generated via settle_baseline.rb*
EOF

File.write(settlement_path, settlement_content)
puts "  [Generated] #{settlement_path}"
puts "==> Settlement complete! Baseline stored at: #{current_baseline_dir}"
