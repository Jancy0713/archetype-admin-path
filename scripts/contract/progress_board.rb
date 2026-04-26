require "pathname"

module ContractFlow
  module ProgressBoard
    META_PREFIX = "- ".freeze
    ROW_COLUMNS = {
      status: 1,
      artifact: 2,
      rendered: 3,
      notes: 4,
    }.freeze

    module_function

    def initialize!(run_root:, flow_id:, source_handoff_yaml_path:, source_handoff_markdown_path: nil)
      # No longer creates the file, as create_run.rb does it.
      # But we can update the meta fields.
      board_path = File.join(run_root, "progress/workflow-progress.md")
      return unless File.exist?(board_path)

      board = Board.new(board_path)
      board.set_meta("run_id", File.basename(run_root))
      board.set_meta("flow_id", flow_id)
      board.set_meta("handoff_snapshot_yaml", ContractFlow::WorkflowManifest.handoff_snapshot_yaml_relative_path)
      board.set_meta("handoff_snapshot_markdown", ContractFlow::WorkflowManifest.handoff_snapshot_markdown_relative_path)
      board.set_meta("source_handoff_yaml", relative_to_run(run_root, source_handoff_yaml_path))
      board.set_meta("source_handoff_markdown", source_handoff_markdown_path ? relative_to_run(run_root, source_handoff_markdown_path) : "")
      board.set_meta("current_step_id", "contract-01")
      board.set_meta("overall_status", "doing")
      board.set_meta("current_goal", "Start contract from intake handoff snapshot")
      board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.handoff_snapshot_yaml_relative_path)
      board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.artifact_relative_path("contract-01"))

      board.update_step("contract-01", status: "ready")
      board.save
      board_path
    end

    def update_for_continue(run_root:, flow_id:, step_id:, mode:)
      board_path = File.join(run_root, "progress/workflow-progress.md")
      return unless File.exist?(board_path)

      board = Board.new(board_path)
      step = ContractFlow::WorkflowManifest.step_for(step_id)
      return unless step

      row_updates = { status: "doing" }
      board.set_meta("current_step_id", step_id)
      board.set_meta("overall_status", mode == "review" ? "review" : "doing")
      board.set_meta("current_goal", current_goal_for(step, flow_id, mode))
      board.set_meta("current_blocker", mode == "review" ? "Awaiting independent reviewer decision" : "")

      case mode
      when "artifact"
        board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.artifact_relative_path(step_id))
        board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.artifact_relative_path(step_id))
      when "render"
        board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.render_relative_path(step_id))
        board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.render_relative_path(step_id))
      when "review"
        row_updates[:status] = "review"
        board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.render_relative_path(step_id))
        board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.review_relative_path)
      end

      board.update_step(step_id, row_updates)
      board.save
    end

    def update_for_finalize(run_root:, step_id:)
      board_path = File.join(run_root, "progress/workflow-progress.md")
      return unless File.exist?(board_path)

      board = Board.new(board_path)
      step = ContractFlow::WorkflowManifest.step_for(step_id)
      return unless step

      next_step_id = ContractFlow::WorkflowManifest.next_step_id(step_id)

      board.update_step(step_id, status: step.fetch("review_step") ? "review" : "done")
      if step.fetch("review_step")
        board.set_meta("current_step_id", "contract-04")
        board.set_meta("overall_status", "review")
        board.set_meta("current_goal", "Independent review for #{step.fetch('artifact')}")
        board.set_meta("current_blocker", "Awaiting independent reviewer decision")
        board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.render_relative_path(step_id))
        board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.review_relative_path)
      elsif next_step_id
        board.update_step(next_step_id, status: "ready")
        board.set_meta("current_step_id", next_step_id)
        board.set_meta("overall_status", "doing")
        board.set_meta("current_goal", "Proceed to #{next_step_id}")
        board.set_meta("current_blocker", "")
        board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.artifact_relative_path(next_step_id))
        board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.artifact_relative_path(next_step_id))
      else
        board.set_meta("current_step_id", "contract.release")
        board.set_meta("overall_status", "doing")
        board.set_meta("current_goal", "Prepare release package")
        board.set_meta("current_blocker", "")
        board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.review_relative_path)
        board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.openapi_relative_path)
      end
      board.save
    end

    def update_for_review_complete(run_root:, review_passed:, has_blocking:, need_human_escalation: false, return_step:, review_result_path:)
      board_path = File.join(run_root, "progress/workflow-progress.md")
      return unless File.exist?(board_path)

      board = Board.new(board_path)
      board.set_meta("review_result", relative_to_run(run_root, review_result_path))

      if review_passed
        board.update_step("contract-03", status: "done")
        board.update_step("contract-04", status: "done")
        board.set_meta("current_step_id", "contract.release")
        board.set_meta("overall_status", "doing")
        board.set_meta("current_goal", "Build formal release package")
        board.set_meta("current_blocker", "")
        board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.review_relative_path)
        board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.develop_handoff_relative_path)
      else
        board.update_step("contract-04", status: "blocked")
        if need_human_escalation
          board.set_meta("current_step_id", "review.human_escalation")
          board.set_meta("overall_status", "blocked")
          board.set_meta("current_goal", "Escalate review outcome to a human decision")
          board.set_meta("current_blocker", "Reviewer requested human escalation")
          board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.review_relative_path)
          board.set_meta("next_expected_output", "")
        else
          step_id = step_id_for_return_step(return_step)
          reset_review_gated_steps!(board, step_id)
          board.set_meta("current_step_id", step_id)
          board.set_meta("overall_status", "blocked")
          board.set_meta("current_goal", "Resolve reviewer findings")
          board.set_meta("current_blocker", has_blocking ? "Reviewer found blocking issues" : "Review did not pass")
          board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.artifact_relative_path(step_id))
          board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.artifact_relative_path(step_id))
        end
      end

      board.save
    end

    def mark_release_ready!(run_root)
      board_path = File.join(run_root, "progress/workflow-progress.md")
      return unless File.exist?(board_path)

      board = Board.new(board_path)
      board.set_meta("current_step_id", "contract.release")
      board.set_meta("overall_status", "released")
      board.set_meta("current_goal", "Formal release package generated")
      board.set_meta("current_blocker", "")
      board.set_meta("next_agent_input", ContractFlow::WorkflowManifest.openapi_relative_path)
      board.set_meta("next_expected_output", ContractFlow::WorkflowManifest.develop_handoff_relative_path)
      board.save
    end

    def relative_to_run(run_root, path)
      Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(File.expand_path(run_root))).to_s
    rescue ArgumentError
      File.expand_path(path)
    end

    def current_goal_for(step, flow_id, mode)
      case mode
      when "review"
        "Send #{flow_id} #{step.fetch('artifact')} to independent review"
      when "render"
        "Render #{step.fetch('artifact')} for #{flow_id}"
      else
        "Complete #{step.fetch('artifact')} for #{flow_id}"
      end
    end

    def next_input_for(step_id)
      next_step = ContractFlow::WorkflowManifest.next_step_id(step_id)
      return ContractFlow::WorkflowManifest.openapi_relative_path unless next_step

      ContractFlow::WorkflowManifest.artifact_relative_path(next_step)
    end

    def next_output_for(step_id)
      next_step = ContractFlow::WorkflowManifest.next_step_id(step_id)
      return ContractFlow::WorkflowManifest.openapi_relative_path unless next_step

      ContractFlow::WorkflowManifest.artifact_relative_path(next_step)
    end

    def step_id_for_return_step(return_step)
      case return_step.to_s
      when "scope_intake"
        "contract-01"
      when "domain_mapping"
        "contract-02"
      else
        "contract-03"
      end
    end

    def reset_review_gated_steps!(board, return_step_id)
      statuses = {
        "contract-01" => "done",
        "contract-02" => "done",
        "contract-03" => "done",
      }

      case return_step_id
      when "contract-01"
        statuses["contract-01"] = "blocked"
        statuses["contract-02"] = "todo"
        statuses["contract-03"] = "todo"
      when "contract-02"
        statuses["contract-02"] = "blocked"
        statuses["contract-03"] = "todo"
      else
        statuses["contract-03"] = "blocked"
      end

      statuses.each do |step_id, status|
        board.update_step(step_id, status: status)
      end
    end

    def format_row(step_id, updates)
      cells = Array.new(ROW_COLUMNS.length + 1, "")
      cells[0] = format_cell(step_id)
      updates.each do |key, value|
        next unless ROW_COLUMNS.key?(key)

        cells[ROW_COLUMNS.fetch(key)] = format_cell(value)
      end
      "| #{cells.join(' | ')} |"
    end

    def format_cell(value)
      "`#{value}`"
    end

    class Board
      def initialize(path)
        @path = path
        @lines = File.readlines(path, chomp: true)
      end

      def set_meta(field, value)
        prefix = "- #{field}:"
        replacement = value.to_s.strip.empty? ? prefix : "#{prefix} #{value}"
        replace_line(prefix, replacement)
      end

      def update_step(step_id, updates = {})
        index = @lines.index { |line| line.start_with?("| `#{step_id}` |") }
        return unless index

        cells = @lines[index].split("|", -1)[1..-2].map(&:strip)
        updates.each do |key, value|
          next unless ROW_COLUMNS.key?(key)

          cells[ROW_COLUMNS.fetch(key)] = "`#{value}`"
        end
        @lines[index] = "| #{cells.join(' | ')} |"
      end

      def save
        File.write(@path, @lines.join("\n") + "\n")
      end

      private

      def replace_line(prefix, replacement)
        index = @lines.index { |line| line.start_with?(prefix) }
        @lines[index] = replacement if index
      end
    end
  end
end
