require "pathname"

require_relative "workflow_manifest"

module ContractFlow
  module ExecutionSummary
    module_function

    def write_review_complete_summary(run_root:, flow_id:, review_passed:, review_path:, state_path:, return_step:)
      lines = [
        "# Contract Execution Summary",
        "",
        "## Current Status",
        "",
        "1. Current flow: `#{flow_id}`.",
        "2. Review file: `#{relative_to_run(run_root, review_path)}`.",
        "3. Review state snapshot: `#{relative_to_run(run_root, state_path)}`.",
        "",
        "## Next Action",
        "",
      ]

      if review_passed
        lines.concat([
          "1. Review passed and formal release package has been generated under `#{ContractFlow::WorkflowManifest.release_dir_relative_path}`.",
          "2. Downstream should consume `openapi.yaml`, `openapi.summary.md`, and `develop-handoff.md` from release.",
          "3. `contract/working/` remains draft-only and is not the default downstream input.",
        ])
      else
        fallback_step = return_step.to_s.strip.empty? ? "contract_spec" : return_step
        lines.concat([
          "1. Review did not pass; do not write or consume release outputs.",
          "2. Return to `#{fallback_step}` and update the working artifacts under `contract/working/`.",
          "3. Re-run independent review after the issues are fixed.",
        ])
      end

      write(run_root, lines.join("\n") + "\n")
    end

    def summary_path(run_root)
      ContractFlow::WorkflowManifest.execution_summary_path(run_root)
    end

    def write(run_root, content)
      path = summary_path(run_root)
      File.write(path, content)
      path
    end

    def relative_to_run(run_root, path)
      Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(File.expand_path(run_root))).to_s
    rescue ArgumentError
      File.expand_path(path)
    end
  end
end
