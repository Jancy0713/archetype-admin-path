module PrdFlow
  module WorkflowManifest
    STEP_ORDER = [
      {
        "step_id" => "prd-01",
        "artifact" => "analysis",
        "review_step" => "prd_analysis",
        "artifact_relative_path" => "prd/prd-01.analysis.yaml",
        "review_relative_path" => "prd/prd-01.review.yaml",
        "render_relative_path" => "rendered/prd-01.analysis.md",
      },
      {
        "step_id" => "prd-02",
        "artifact" => "clarification",
        "review_step" => "prd_clarification",
        "artifact_relative_path" => "prd/prd-02.clarification.yaml",
        "review_relative_path" => "prd/prd-02.review.yaml",
        "render_relative_path" => "rendered/prd-02.clarification.md",
      },
      {
        "step_id" => "prd-03",
        "artifact" => "execution_plan",
        "review_step" => "prd_execution_plan",
        "artifact_relative_path" => "prd/prd-03.execution_plan.yaml",
        "review_relative_path" => "prd/prd-03.review.yaml",
        "render_relative_path" => "rendered/prd-03.execution_plan.md",
      },
      {
        "step_id" => "prd-04",
        "artifact" => "final_prd",
        "review_step" => "final_prd_ready",
        "artifact_relative_path" => "prd/prd-04.final_prd.yaml",
        "review_relative_path" => "prd/prd-04.review.yaml",
        "render_relative_path" => "rendered/prd-04.final_prd.md",
      },
    ].freeze

    HUMAN_GATE_RULES = [
      "`clarification` reviewer 通过后，默认必须停在 Human Confirmation Gate",
      "`final_prd` 只有在 ready batch 的 handoff 字段完整且无 blocking_questions.p0 时才允许进入 contract",
    ].freeze

    module_function

    def steps
      STEP_ORDER
    end

    def first_step
      STEP_ORDER.first
    end

    def step_ids
      STEP_ORDER.map { |step| step.fetch("step_id") }
    end

    def continue_usage
      step_ids.join("|")
    end

    def step_for(step_id)
      STEP_ORDER.find { |step| step.fetch("step_id") == step_id }
    end

    def step_for_review_step(review_step)
      STEP_ORDER.find { |step| step.fetch("review_step") == review_step }
    end

    def step_for_artifact(artifact)
      STEP_ORDER.find { |step| step.fetch("artifact") == artifact }
    end

    def first_step_id
      first_step.fetch("step_id")
    end

    def first_artifact
      first_step.fetch("artifact")
    end

    def first_review_step
      first_step.fetch("review_step")
    end

    def first_artifact_relative_path
      first_step.fetch("artifact_relative_path")
    end

    def first_review_relative_path
      first_step.fetch("review_relative_path")
    end

    def first_render_relative_path
      first_step.fetch("render_relative_path")
    end

    def first_artifact_path(run_root)
      File.join(run_root, first_artifact_relative_path)
    end

    def first_review_path(run_root)
      File.join(run_root, first_review_relative_path)
    end

    def first_render_path(run_root)
      File.join(run_root, first_render_relative_path)
    end

    def artifact_relative_path(step_id)
      step = step_for(step_id)
      step&.fetch("artifact_relative_path")
    end

    def review_relative_path(step_id)
      step = step_for(step_id)
      step&.fetch("review_relative_path")
    end

    def render_relative_path(step_id)
      step = step_for(step_id)
      step&.fetch("render_relative_path")
    end

    def artifact_path(step_id, run_root)
      path = artifact_relative_path(step_id)
      path ? File.join(run_root, path) : nil
    end

    def review_path(step_id, run_root)
      path = review_relative_path(step_id)
      path ? File.join(run_root, path) : nil
    end

    def render_path(step_id, run_root)
      path = render_relative_path(step_id)
      path ? File.join(run_root, path) : nil
    end

    def next_step_id(step_id)
      index = STEP_ORDER.index { |step| step.fetch("step_id") == step_id }
      return nil unless index

      STEP_ORDER[index + 1]&.fetch("step_id", nil)
    end

    def completion_status_for(step_id, subject_data)
      step = step_for(step_id)
      return nil unless step

      case step.fetch("artifact")
      when "clarification"
        subject_data.dig("human_confirmation", "confirmed") == true ? "confirmed" : "blocked"
      else
        "done"
      end
    end

    def validate_command(step_id, run_root)
      step = step_for(step_id)
      return nil unless step

      "ruby scripts/prd/validate_artifact.rb #{step.fetch('artifact')} #{File.join(run_root, step.fetch('artifact_relative_path'))}"
    end

    def render_command(step_id, run_root)
      step = step_for(step_id)
      return nil unless step

      "ruby scripts/prd/render_artifact.rb #{step.fetch('artifact')} #{File.join(run_root, step.fetch('artifact_relative_path'))} #{File.join(run_root, step.fetch('render_relative_path'))}"
    end

    def init_artifact_command(step_id, run_root)
      step = step_for(step_id)
      return nil unless step

      "ruby scripts/prd/init_artifact.rb --step-id #{step.fetch('step_id')} #{step.fetch('artifact')} #{File.join(run_root, step.fetch('artifact_relative_path'))}"
    end

    def init_review_command(step_id, run_root)
      step = step_for(step_id)
      return nil unless step

      "ruby scripts/prd/init_review_context.rb --step #{step.fetch('review_step')} --step-id #{step.fetch('step_id')} --subject #{File.join(run_root, step.fetch('artifact_relative_path'))} #{File.join(run_root, step.fetch('review_relative_path'))}"
    end

    def materials_command(step_id)
      step = step_for(step_id)
      return nil unless step

      "ruby scripts/prd/materials.rb --artifact #{step.fetch('artifact')}"
    end

    def review_materials_command(step_id)
      step = step_for(step_id)
      return nil unless step

      "ruby scripts/prd/materials.rb --review-step #{step.fetch('review_step')}"
    end

    def initial_progress_meta
      {
        "current_step_id" => first_step_id,
        "overall_status" => "doing",
        "current_goal" => "完成首个结构化 YAML",
        "current_blocker" => "",
        "next_agent_input" => "raw/request.md",
        "next_expected_output" => first_artifact_relative_path
      }
    end

    def commands_for(step_id, run_root:, mode:, force:)
      step = step_for(step_id)
      return nil unless step

      case mode
      when "artifact"
        command = ["ruby", "scripts/prd/init_artifact.rb"]
        command << "--force" if force
        command.concat(["--step-id", step.fetch("step_id"), step.fetch("artifact"), artifact_path(step_id, run_root)])
        [command]
      when "review"
        command = ["ruby", "scripts/prd/init_review_context.rb"]
        command << "--force" if force
        command.concat(["--step", step.fetch("review_step"), "--step-id", step.fetch("step_id"), "--subject", artifact_path(step_id, run_root), review_path(step_id, run_root)])
        [command]
      when "render"
        [["ruby", "scripts/prd/render_artifact.rb", step.fetch("artifact"), artifact_path(step_id, run_root), render_path(step_id, run_root)]]
      else
        nil
      end
    end

    def progress_updates_for(step_id, mode)
      step = step_for(step_id)
      return nil unless step

      next_step = next_step_id(step_id) || "contract"

      case mode
      when "artifact"
        {
          rows: {
            step_id => {
              status: "doing",
              output: step.fetch("artifact_relative_path"),
              reviewer: step.fetch("review_relative_path"),
              next_step: next_step
            }
          },
          meta: {
            "current_step_id" => step_id,
            "overall_status" => "doing",
            "current_goal" => "Complete #{step.fetch('artifact')} and prepare it for validation",
            "current_blocker" => "",
            "next_agent_input" => row_input_for(step_id),
            "next_expected_output" => step.fetch("artifact_relative_path")
          }
        }
      when "review"
        {
          rows: {
            step_id => {
              status: "review",
              output: step.fetch("artifact_relative_path"),
              reviewer: step.fetch("review_relative_path"),
              next_step: next_step
            }
          },
          meta: {
            "current_step_id" => "#{step_id}.review",
            "overall_status" => "review",
            "current_goal" => "Review #{step.fetch('artifact')} before #{next_step}",
            "current_blocker" => "Awaiting independent reviewer decision",
            "next_agent_input" => step.fetch("artifact_relative_path"),
            "next_expected_output" => step.fetch("review_relative_path")
          }
        }
      when "render"
        {
          rows: {
            step_id => {
              output: step.fetch("artifact_relative_path"),
              next_step: next_step
            }
          },
          meta: {
            "current_step_id" => "#{step_id}.rendered",
            "overall_status" => "doing",
            "current_goal" => "Review rendered #{step.fetch('artifact')} markdown and decide next action",
            "current_blocker" => "",
            "next_agent_input" => step.fetch("render_relative_path"),
            "next_expected_output" => step.fetch("render_relative_path")
          }
        }
      end
    end

    def completion_messages_for(step_id, mode, run_root)
      step = step_for(step_id)
      return [] unless step

      case mode
      when "artifact"
        [
          "Initialized #{step.fetch('artifact')} artifact at #{artifact_path(step_id, run_root)}.",
          "Next: fill it, validate it, then prepare reviewer context."
        ]
      when "review"
        [
          "Initialized reviewer context at #{review_path(step_id, run_root)}.",
          "Reviewer materials snapshot: #{review_path(step_id, run_root).sub(/\.ya?ml\z/, '.materials.yml')}"
        ]
      when "render"
        [
          "Rendered #{step.fetch('artifact')} markdown at #{render_path(step_id, run_root)}."
        ]
      else
        []
      end
    end

    def command_cheat_sheet(run_root)
      lines = []
      lines << "### PRD Step Map"
      lines << ""
      STEP_ORDER.each do |step|
        lines << "- `#{step.fetch('step_id')}` -> `#{step.fetch('artifact')}`"
      end
      lines << ""
      lines << "### PRD Commands"
      lines << ""

      STEP_ORDER.each do |step|
        lines.concat(command_block("查询 #{step.fetch('artifact')} 材料：", materials_command(step.fetch("step_id"))))
        lines << ""
        lines.concat(command_block("初始化 #{step.fetch('artifact')}：", init_artifact_command(step.fetch("step_id"), run_root)))
        lines << ""
        lines.concat(command_block("查询 #{step.fetch('artifact')} reviewer 材料：", review_materials_command(step.fetch("step_id"))))
        lines << ""
        lines.concat(command_block("初始化 #{step.fetch('artifact')} reviewer 上下文：", init_review_command(step.fetch("step_id"), run_root)))
        lines << ""
      end

      lines.concat(command_block("校验首个主产物：", validate_command(first_step_id, run_root)))
      lines << ""
      lines.concat(command_block("收口首个步骤：", "ruby scripts/prd/finalize_step.rb #{run_root} #{first_step_id}"))
      lines << ""
      lines.concat(command_block("确认 clarification human gate：", "ruby scripts/prd/confirm_clarification.rb #{run_root} #{File.join(run_root, 'prd/prd-02.clarification.yaml')} --summary \"<confirmed summary>\" --confirmed-by <name>"))
      lines << ""
      lines.concat(command_block("渲染首个主产物：", render_command(first_step_id, run_root)))
      lines << ""
      lines << "Human Gate:"
      lines << ""
      HUMAN_GATE_RULES.each do |rule|
        lines << "- #{rule}"
      end
      lines.join("\n")
    end

    def row_input_for(step_id)
      case step_id
      when "prd-01"
        "raw/request.md"
      when "prd-02"
        "prd/prd-01.analysis.yaml"
      when "prd-03"
        "prd/prd-02.clarification.yaml"
      when "prd-04"
        "prd/prd-03.execution_plan.yaml"
      end
    end
    private_class_method :row_input_for

    def command_block(title, command)
      [
        title,
        "",
        "```bash",
        command,
        "```"
      ]
    end
    private_class_method :command_block
  end
end
