module InitFlow
  module WorkflowManifest
    STEP_ORDER = [
      ["init-01", "foundation_context"],
      ["init-02", "tenant_governance"],
      ["init-03", "identity_access"],
      ["init-04", "experience_platform"],
      ["init-05", "baseline"],
      ["init-06", "design_seed"],
      ["init-07", "bootstrap_plan"],
      ["init-08", "execution"]
    ].freeze

    STEP_GROUPS = {
      "profile" => %w[init-01 init-02 init-03 init-04],
      "foundation" => %w[init-05 init-06],
      "bootstrap" => %w[init-07],
      "execution" => %w[init-08]
    }.freeze

    CONTINUE_STEP_IDS = %w[init-05 init-06 init-07 init-08].freeze

    HUMAN_GATE_RULES = [
      "每个 reviewer 通过后的阶段确认都必须停",
      "`baseline` 通过后必须停给人确认",
      "`design_seed` 需要 reviewer，但不单独停给人，会在 `init-07` 一并确认",
      "`bootstrap_plan` 需要 reviewer，review 通过后必须停给人确认"
    ].freeze

    module_function

    def step_map
      STEP_ORDER.to_h
    end

    def step_groups
      STEP_GROUPS
    end

    def group_for(step_id)
      STEP_GROUPS.find { |_group, step_ids| step_ids.include?(step_id) }&.first
    end

    def continue_step_ids
      CONTINUE_STEP_IDS
    end

    def continue_usage
      CONTINUE_STEP_IDS.join("|")
    end

    def first_step_id
      STEP_ORDER.first.fetch(0)
    end

    def first_artifact_relative_path
      "init/init-01.project_profile.yaml"
    end

    def first_review_relative_path
      "init/init-01.review.yaml"
    end

    def first_render_relative_path
      "rendered/init-01.project_profile.md"
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

    def first_validate_command(run_root)
      "ruby scripts/init/validate_artifact.rb project_profile #{first_artifact_path(run_root)}"
    end

    def first_render_command(run_root)
      "ruby scripts/init/profile/render_project_profile_step.rb #{run_root} #{first_step_id}"
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

    def command_cheat_sheet(run_root)
      lines = []
      lines << "### Init Step Map"
      lines << ""
      STEP_ORDER.reject { |step_id, _| step_id == "init-08" }.each do |step_id, stage|
        lines << "- `#{step_id}` -> `#{stage}`"
      end
      lines << ""
      lines << "### Init Commands"
      lines << ""
      lines.concat(command_block("初始化阶段画像：", "ruby scripts/init/profile/init_project_profile_step.rb #{run_root} #{first_step_id}"))
      lines << ""
      lines.concat(command_block("初始化 reviewer：", "ruby scripts/init/profile/init_project_profile_review.rb #{run_root} #{first_step_id}"))
      lines << ""
      lines.concat(command_block("校验主产物：", first_validate_command(run_root)))
      lines << ""
      lines.concat(command_block("渲染主产物：", first_render_command(run_root)))
      lines << ""
      lines.concat(command_block("准备 baseline：", "ruby scripts/init/foundation/prepare_baseline.rb #{run_root}"))
      lines << ""
      lines.concat(command_block("准备 design_seed：", "ruby scripts/init/foundation/prepare_design_seed.rb #{run_root}"))
      lines << ""
      lines.concat(command_block("准备 bootstrap_plan：", "ruby scripts/init/bootstrap/prepare_bootstrap_plan.rb #{run_root}"))
      lines << ""
      lines.concat(command_block("准备 init-08 execution：", "ruby scripts/init/execution/prepare_execution.rb #{run_root} --project-name <name> --project-dir-name <slug>  # <slug> 本身就是项目根目录名"))
      lines << ""
      lines << "Human Gate:"
      lines << ""
      HUMAN_GATE_RULES.each do |rule|
        lines << "- #{rule}"
      end
      lines.join("\n")
    end

    def commands_for(step_id, run_root:, force:, execution_args: [])
      case step_id
      when "init-05"
        [["ruby", "scripts/init/foundation/prepare_baseline.rb", run_root, *(force ? ["--force"] : [])]]
      when "init-06"
        [["ruby", "scripts/init/foundation/prepare_design_seed.rb", run_root, *(force ? ["--force"] : [])]]
      when "init-07"
        [["ruby", "scripts/init/bootstrap/prepare_bootstrap_plan.rb", run_root, *(force ? ["--force"] : [])]]
      when "init-08"
        [["ruby", "scripts/init/execution/prepare_execution.rb", run_root, *execution_args]]
      else
        nil
      end
    end

    def progress_updates_for(step_id)
      case step_id
      when "init-05"
        {
          rows: {
            "init-04" => { status: "confirmed", human_confirmation: "confirmed" },
            "init-05" => { status: "doing", output: "init/init-05.baseline.yaml", next_step: "init-06" }
          },
          meta: {
            "current_step_id" => "init-05",
            "overall_status" => "doing",
            "current_goal" => "Complete baseline and decide whether it can become the default init input",
            "current_blocker" => "Awaiting baseline completion and human confirmation",
            "next_agent_input" => "Fill init/init-05.baseline.yaml, then validate and render it",
            "next_expected_output" => "rendered/init-05.baseline.md"
          }
        }
      when "init-06"
        {
          rows: {
            "init-05" => { status: "confirmed", human_confirmation: "confirmed" },
            "init-06" => { status: "review", output: "init/init-06.design_seed.yaml", reviewer: "init/init-06.review.yaml", human_confirmation: "batched_with_init-07", next_step: "init-07" }
          },
          meta: {
            "current_step_id" => "init-06.review",
            "overall_status" => "review",
            "current_goal" => "Review design_seed and decide whether init-07 can start",
            "current_blocker" => "Awaiting reviewer decision on design constraints completeness and scope",
            "next_agent_input" => "Review init/init-06.design_seed.yaml and write init/init-06.review.yaml",
            "next_expected_output" => "init/init-06.review.yaml"
          }
        }
      when "init-07"
        {
          rows: {
            "init-06" => { status: "done", output: "init/init-06.design_seed.yaml", reviewer: "init/init-06.review.yaml", human_confirmation: "batched_with_init-07", next_step: "init-07" },
            "init-07" => { status: "review", output: "init/init-07.bootstrap_plan.yaml", reviewer: "init/init-07.review.yaml", human_confirmation: "pending", next_step: "init-08" }
          },
          meta: {
            "current_step_id" => "init-07.review",
            "overall_status" => "review",
            "current_goal" => "Review bootstrap_plan before the final init human gate",
            "current_blocker" => "Awaiting reviewer decision on execution scope and bootstrap boundaries",
            "next_agent_input" => "Review init/init-07.bootstrap_plan.yaml and write init/init-07.review.yaml",
            "next_expected_output" => "init/init-07.review.yaml"
          }
        }
      when "init-08"
        {
          rows: {
            "init-06" => { status: "confirmed", output: "init/init-06.design_seed.yaml", reviewer: "init/init-06.review.yaml", human_confirmation: "confirmed", next_step: "init-07" },
            "init-07" => { status: "confirmed", output: "init/init-07.bootstrap_plan.yaml", reviewer: "init/init-07.review.yaml", human_confirmation: "confirmed", next_step: "init-08" },
            "init-08" => { status: "doing", output: "project-root", human_confirmation: "not_needed", next_step: "prd-01" }
          },
          meta: {
            "current_step_id" => "init-08",
            "overall_status" => "doing",
            "current_goal" => "Generate fresh init-08 execution/reviewer prompts and hand them off to a new execution agent",
            "current_blocker" => "Awaiting a fresh execution agent to run the generated init-08 prompt, pass reviewer, and then execute post_init_to_prd.rb",
            "next_agent_input" => "prompts/init-08-execution-prompt.md",
            "next_expected_output" => "rendered/init-08.execution-summary.md"
          }
        }
      end
    end

    def completion_messages_for(step_id, run_root)
      case step_id
      when "init-05"
        [
          "Initialized baseline from existing init-04 output at #{run_root}.",
          "Next: fill #{File.join(run_root, 'init/init-05.baseline.yaml')}, validate it, then rerun this script for init-06."
        ]
      when "init-06"
        [
          "Rendered design_seed for review at #{File.join(run_root, 'rendered/init-06.design_seed.md')}.",
          "Initialized reviewer skeleton at #{File.join(run_root, 'init/init-06.review.yaml')}.",
          "Next: complete init-06 reviewer, then use init-06 outputs as upstream input for init-07."
        ]
      when "init-07"
        [
          "Rendered bootstrap_plan for review at #{File.join(run_root, 'rendered/init-07.bootstrap_plan.md')}.",
          "Rendered project conventions preview at #{File.join(run_root, 'rendered/init-07.project-conventions.md')}.",
          "Rendered prd bootstrap context sample at #{File.join(run_root, 'rendered/init-07.prd-bootstrap-context.md')}.",
          "Rendered init execution scope preview at #{File.join(run_root, 'rendered/init-07.init-execution-scope.md')}.",
          "Initialized reviewer skeleton at #{File.join(run_root, 'init/init-07.review.yaml')}.",
          "At the human gate, review rendered/init-06.design_seed.md, rendered/init-07.bootstrap_plan.md, rendered/init-07.project-conventions.md, rendered/init-07.prd-bootstrap-context.md, and rendered/init-07.init-execution-scope.md together."
        ]
      when "init-08"
        [
          "Executed init-08 from #{File.join(run_root, 'init/init-07.bootstrap_plan.yaml')}.",
          "Review the execution summary at #{File.join(run_root, 'rendered/init-08.execution-summary.md')}.",
          "Start a fresh context, then hand #{File.join(run_root, 'prompts/init-08-execution-prompt.md')} to the execution agent; after initialization completes, it must pass #{File.join(run_root, 'prompts/init-08-reviewer-prompt.md')} to an independent reviewer before running post_init_to_prd.rb."
        ]
      else
        []
      end
    end

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
