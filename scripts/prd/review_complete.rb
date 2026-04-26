#!/usr/bin/env ruby
require "pathname"

require_relative "../progress_board"
require_relative "artifact_utils"
require_relative "workflow_manifest"
require_relative "../contract/handoff_generation"
require_relative "../contract/workflow_manifest"
require_relative "../contract/execution_summary"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/prd/review_complete.rb <run_dir> <review.yml>"
  exit 1
end

def progress_path_for(run_root)
  File.join(run_root, "progress/workflow-progress.md")
end

def validate_yaml_artifact(type, path)
  data = Prd::ArtifactUtils.load_yaml(path)
  errors = Prd::ArtifactUtils.validate_artifact(type, data, artifact_path: path)
  unless errors.empty?
    warn "Validation failed for #{path}"
    errors.each { |error| warn "- #{error}" }
    exit 2
  end
  data
end

def relative_to_run(run_root, path)
  Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(File.expand_path(run_root))).to_s
end

def update_progress(run_root, step_id, review_data, subject_data, contract_handoff_result: nil, contract_run_root: nil)
  progress_path = progress_path_for(run_root)
  return unless File.exist?(progress_path)

  board = WorkflowProgressBoard::Board.new(progress_path)
  step = PrdFlow::WorkflowManifest.step_for(step_id)
  next_step =
    if step&.fetch("artifact") == "final_prd"
      "contract_handoff"
    else
      PrdFlow::WorkflowManifest.next_step_id(step_id) || "contract"
    end

  has_blocking = review_data.dig("decision", "has_blocking_issue") == true
  allow_next = review_data.dig("decision", "allow_next_step") == true
  escalate = review_data.dig("decision", "need_human_escalation") == true
  artifact = step&.fetch("artifact")

  if allow_next
    if artifact == "clarification"
      board.update_row(step_id, status: "review", output: PrdFlow::WorkflowManifest.artifact_relative_path(step_id), reviewer: PrdFlow::WorkflowManifest.review_relative_path(step_id), human_confirmation: "required", next_step: next_step)
      board.set_meta("current_step_id", "#{step_id}.human_confirmation")
      board.set_meta("overall_status", "blocked")
      board.set_meta("current_goal", "Complete Human Confirmation Gate for #{step_id} before #{next_step}")
      board.set_meta("current_blocker", "Awaiting human confirmation")
      board.set_meta("next_agent_input", PrdFlow::WorkflowManifest.render_relative_path(step_id))
      board.set_meta("next_expected_output", PrdFlow::WorkflowManifest.artifact_relative_path(step_id))
    else
      row_status = PrdFlow::WorkflowManifest.completion_status_for(step_id, subject_data)
      board.update_row(step_id, status: row_status, output: PrdFlow::WorkflowManifest.artifact_relative_path(step_id), reviewer: PrdFlow::WorkflowManifest.review_relative_path(step_id), next_step: next_step)
      board.set_meta("current_step_id", next_step)
      board.set_meta("overall_status", "doing")
      if next_step == "contract_handoff" && contract_handoff_result
        board.set_meta("current_goal", "Contract handoff is ready; continue from the single-flow contract run intake snapshot")
        if contract_run_root
          prompt_path = File.join(contract_run_root, "prompts/run-agent-prompt.md")
          board.set_meta("next_agent_input", relative_to_run(run_root, prompt_path))
          board.set_meta("next_expected_output", relative_to_run(run_root, ContractFlow::WorkflowManifest.artifact_path(ContractFlow::WorkflowManifest.first_step_id, contract_run_root)))
        else
          # Fail-safe if run_root could not be determined
          board.set_meta("next_agent_input", relative_to_run(run_root, contract_handoff_result.fetch(:current_flow_handoff_yaml_path)))
          board.set_meta("next_expected_output", relative_to_run(run_root, ContractFlow::WorkflowManifest.run_root(ROOT, contract_handoff_result.fetch(:current_flow_id))))
        end
      else
        board.set_meta("current_goal", next_step == "contract_handoff" ? "Generate contract handoff from final_prd" : "Proceed to #{next_step}")
        case next_step
        when "contract_handoff"
          # If we are handing off to contract, next input is the start-up prompt
          if contract_run_root
            prompt_path = File.join(contract_run_root, "prompts/run-agent-prompt.md")
            board.set_meta("next_agent_input", relative_to_run(run_root, prompt_path))
          else
            # Fail-safe to index if run_root calculation failed for some reason
            board.set_meta("next_agent_input", "contract_handoff/contract-handoff.index.yaml")
          end
        when "prd-02"
          board.set_meta("next_agent_input", PrdFlow::WorkflowManifest.artifact_relative_path(step.fetch("step_id")))
        else
          board.set_meta("next_agent_input", PrdFlow::WorkflowManifest.artifact_relative_path(next_step))
        end
        board.set_meta("next_expected_output", next_step == "contract_handoff" ? "contract_handoff/" : PrdFlow::WorkflowManifest.artifact_relative_path(next_step))
      end
      board.set_meta("current_blocker", "")
    end
  else
    board.update_row(step_id, status: "blocked", output: PrdFlow::WorkflowManifest.artifact_relative_path(step_id), reviewer: PrdFlow::WorkflowManifest.review_relative_path(step_id))
    board.set_meta("current_step_id", "#{step_id}.blocked")
    board.set_meta("overall_status", "blocked")
    board.set_meta("current_goal", "Resolve reviewer findings for #{step_id}")
    blocker =
      if escalate
        "Reviewer requested human escalation"
      elsif has_blocking
        "Reviewer found blocking issues"
      else
        "Reviewer did not allow the next step"
      end
    board.set_meta("current_blocker", blocker)
    board.set_meta("next_agent_input", PrdFlow::WorkflowManifest.review_relative_path(step_id))
    board.set_meta("next_expected_output", PrdFlow::WorkflowManifest.artifact_relative_path(step_id))
  end

  board.save
end

run_dir = ARGV[0]
review_path_arg = ARGV[1]
usage if run_dir.to_s.strip.empty? || review_path_arg.to_s.strip.empty?

run_root = File.expand_path(run_dir, ROOT)
unless Dir.exist?(run_root)
  warn "Run directory not found: #{run_root}"
  exit 1
end

review_path = File.expand_path(review_path_arg, ROOT)
unless File.exist?(review_path)
  warn "Review file not found: #{review_path}"
  exit 1
end

review_data = validate_yaml_artifact("review", review_path)
review_step = review_data.dig("status", "step")
step = PrdFlow::WorkflowManifest.step_for_review_step(review_step)
unless step
  warn "Unknown review step: #{review_step}"
  exit 1
end

subject_path = review_data.dig("meta", "subject_path")
subject_path = File.expand_path(subject_path, File.dirname(review_path))
unless File.exist?(subject_path)
  warn "Subject file not found: #{subject_path}"
  exit 1
end

subject_type = step.fetch("artifact")
expected_subject_path = PrdFlow::WorkflowManifest.artifact_path(step.fetch("step_id"), run_root)
if expected_subject_path && File.exist?(expected_subject_path) && File.expand_path(subject_path) != File.expand_path(expected_subject_path)
  warn "Review subject_path points outside the current run; using #{expected_subject_path} instead"
  subject_path = expected_subject_path
end

subject_data = validate_yaml_artifact(subject_type, subject_path)

contract_handoff_result = nil
contract_run_root = nil
if review_data.dig("decision", "allow_next_step") == true && step.fetch("artifact") == "final_prd"
  begin
    contract_handoff_result = ContractFlow::HandoffGeneration.generate!(
      run_root: run_root,
      final_prd_path: subject_path,
      allow_existing: true
    )

    # Initialize ALL flows from the index to ensure all prompt paths exist
    index_path = File.expand_path(contract_handoff_result.fetch(:index_path), ROOT)
    index_data = YAML.load_file(index_path)
    flows = Array(index_data["flows"])

    init_failures = []
    flows.each do |f|
      handoff_yaml_path = File.expand_path(f["handoff_yaml_path"], run_root)
      init_run_command = ["ruby", "scripts/contract/init_flow_run.rb", handoff_yaml_path]
      success = system(*init_run_command, chdir: ROOT, out: File::NULL)
      unless success
        warn "Failed to initialize flow run for #{f['flow_id']}"
        init_failures << f['flow_id']
      end
    end

    unless init_failures.empty?
      warn "Aborting prd-05 completion: failed to initialize contract flow runs for: #{init_failures.join(', ')}"
      exit 1
    end

    contract_run_root = ContractFlow::WorkflowManifest.run_root(ROOT, contract_handoff_result.fetch(:current_flow_id))
  rescue ArgumentError => e
    warn "Failed to prepare contract handoff from final_prd"
    warn "- #{e.message}"
    exit 2
  end
end

update_progress(run_root, step.fetch("step_id"), review_data, subject_data, contract_handoff_result: contract_handoff_result, contract_run_root: contract_run_root)

if review_data.dig("decision", "allow_next_step") == true
  next_step = step.fetch("artifact") == "final_prd" ? "contract_handoff" : (PrdFlow::WorkflowManifest.next_step_id(step.fetch("step_id")) || "contract")
  puts "Review passed for #{step.fetch('step_id')}."
  if step.fetch("artifact") == "clarification"
    puts "Next step: Human Confirmation Gate before #{next_step}"
  elsif next_step == "contract_handoff" && contract_handoff_result
    index_path = File.expand_path(contract_handoff_result.fetch(:index_path), ROOT)
    index_data = YAML.load_file(index_path)
    flows = Array(index_data["flows"])
    first_flow = flows.first

    puts "# prd-05 已完成：合同交接已生成"
    puts
    puts "## 下一步建议"
    puts
    puts "如果没有异议，建议直接进入第 1 批：#{first_flow['title']}。"
    puts
    puts "- 当前上下文继续执行：直接说“执行第 1 批”"

    first_flow_id = first_flow["flow_id"]
    first_run_root = ContractFlow::WorkflowManifest.run_root(ROOT, first_flow_id)
    prompt_path = relative_to_run(run_root, File.join(first_run_root, "prompts/run-agent-prompt.md"))

    puts "- 新开上下文执行：把启动提示词 `#{prompt_path}` 交给 AI"
    puts "- 如果批次名称、顺序或依赖关系不对，我们先修改 `contract_handoff`，不要进入 contract"
    puts
    puts "## 本次拆出的功能批次"
    puts

    flows.each_with_index do |f, i|
      flow_id = f["flow_id"]
      flow_run_root = ContractFlow::WorkflowManifest.run_root(ROOT, flow_id)
      status_text = f["status"] == "ready" ? "可开始" : "等待前置批次"

      # Try to read the flow handoff to get the goal
      handoff_path = File.expand_path(f["handoff_yaml_path"], ROOT)
      goal = "设计并产出 #{f['title']} 的 API 合同"
      if File.exist?(handoff_path)
        h_data = YAML.load_file(handoff_path)
        goal = h_data["functional_goal"] if h_data["functional_goal"]
      end

      puts "#{i + 1}. #{f['title']}"
      puts "   工作区：`#{relative_to_run(run_root, flow_run_root)}/`"
      puts "   状态：#{status_text}"
      puts "   本批目标：#{goal}"
      puts "   启动提示词：`#{relative_to_run(run_root, File.join(flow_run_root, 'prompts/run-agent-prompt.md'))}`"
      puts
    end

    puts "## 已生成的关键材料"
    puts
    puts "- 总索引：`#{relative_to_run(run_root, contract_handoff_result.fetch(:index_path))}`"
    puts "- 人类总览：`#{relative_to_run(run_root, contract_handoff_result.fetch(:overview_doc_path))}`"
    puts "- 各批次目录：`runs/YYYY-MM-DD-contract-<flow-id>/`"
    puts "- 各批次启动提示词：`runs/YYYY-MM-DD-contract-<flow-id>/prompts/run-agent-prompt.md`"
    puts
    puts "## 异常或偏差"
    puts
    puts "无。"
  else
    puts "Next step: #{next_step}"
  end
else
  puts "Review blocked #{step.fetch('step_id')}."
  puts "Check #{review_path} and update #{subject_path} before retrying."
end
