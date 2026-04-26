require_relative "artifact_utils"
module ContractFlow
  module WorkflowManifest
    STEP_ORDER = [
      {
        "step_id" => "contract-01",
        "artifact" => "scope_intake",
        "review_step" => nil,
        "filename" => "contract-01.scope_intake.yaml",
        "rendered_filename" => "contract-01.scope_intake.md",
        "top_rendered_filename" => "contract-01.scope_intake.md",
      },
      {
        "step_id" => "contract-02",
        "artifact" => "domain_mapping",
        "review_step" => nil,
        "filename" => "contract-02.domain_mapping.yaml",
        "rendered_filename" => "contract-02.domain_mapping.md",
        "top_rendered_filename" => "contract-02.domain_mapping.md",
      },
      {
        "step_id" => "contract-03",
        "artifact" => "contract_spec",
        "review_step" => "contract_spec_ready",
        "filename" => "contract-03.contract_spec.yaml",
        "rendered_filename" => "contract-03.contract_spec.md",
        "top_rendered_filename" => "contract-03.contract_spec.md",
      },
      {
        "step_id" => "contract-04",
        "artifact" => "review",
        "review_step" => "contract_spec_ready",
        "filename" => "contract-04.review.yaml",
        "rendered_filename" => "contract-04.review.md",
        "top_rendered_filename" => "contract-04.review.md",
      },
    ].freeze

    ARTIFACT_TYPES = %w[
      scope_intake
      domain_mapping
      contract_spec
      review
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

    def step_for_artifact(artifact)
      STEP_ORDER.find { |step| step.fetch("artifact") == artifact }
    end

    def step_for_review_step(review_step)
      STEP_ORDER.find { |step| step.fetch("review_step") == review_step }
    end

    def next_step_id(step_id)
      index = STEP_ORDER.index { |step| step.fetch("step_id") == step_id }
      return nil unless index

      STEP_ORDER[index + 1]&.fetch("step_id", nil)
    end

    def artifact_types
      ARTIFACT_TYPES
    end

    def first_step_id
      first_step.fetch("step_id")
    end

    def first_artifact
      first_step.fetch("artifact")
    end

    def first_artifact_relative_path(_flow_id = nil)
      artifact_relative_path(first_step_id)
    end

    def first_render_relative_path(_flow_id = nil)
      render_relative_path(first_step_id)
    end

    def run_id(flow_id)
      "#{Time.now.strftime('%Y-%m-%d')}-contract-#{flow_id}"
    end

    def runs_root(root)
      override = ENV["CONTRACT_RUNS_ROOT"].to_s.strip
      return File.expand_path(override) unless override.empty?

      File.join(root, "runs")
    end

    def run_root(root, flow_id, mode: :create)
      # Try to find existing dated run directory first (highest priority)
      pattern = "*-contract-#{flow_id}"
      existing = Dir.glob(File.join(runs_root(root), pattern)).first
      return existing if existing && Dir.exist?(existing)

      if mode == :read
        # Legacy fallback (only if dated run doesn't exist and legacy DOES exist)
        legacy = File.join(runs_root(root), "contract-#{flow_id}")
        return legacy if Dir.exist?(legacy)
      end

      # Default to new style for creating new runs (or fallback if read found nothing)
      File.join(runs_root(root), run_id(flow_id))
    end

    def run_manifest_relative_path
      "run.yaml"
    end

    def run_manifest_path(run_root)
      File.join(run_root, run_manifest_relative_path)
    end

    def manifest_flow_id(run_root)
      path = run_manifest_path(run_root)
      return nil unless File.exist?(path)

      data = Contract::ArtifactUtils.load_yaml(path)
      data["flow_id"]
    rescue StandardError
      nil
    end

    def intake_dir_relative_path
      "intake"
    end

    def intake_dir_path(run_root)
      File.join(run_root, intake_dir_relative_path)
    end

    def handoff_snapshot_yaml_relative_path
      File.join(intake_dir_relative_path, "contract-handoff.snapshot.yaml")
    end

    def handoff_snapshot_yaml_path(run_root)
      File.join(run_root, handoff_snapshot_yaml_relative_path)
    end

    def handoff_snapshot_markdown_relative_path
      File.join(intake_dir_relative_path, "contract-handoff.snapshot.md")
    end

    def handoff_snapshot_markdown_path(run_root)
      File.join(run_root, handoff_snapshot_markdown_relative_path)
    end

    def working_dir_relative_path
      File.join("contract", "working")
    end

    def working_dir_path(run_root)
      File.join(run_root, working_dir_relative_path)
    end

    def rendered_dir_relative_path
      "rendered"
    end

    def rendered_dir_path(run_root)
      File.join(run_root, rendered_dir_relative_path)
    end

    def state_dir_relative_path
      File.join(working_dir_relative_path, "state")
    end

    def state_dir_path(run_root)
      File.join(run_root, state_dir_relative_path)
    end

    def release_dir_relative_path
      File.join("contract", "release")
    end

    def release_dir_path(run_root)
      File.join(run_root, release_dir_relative_path)
    end

    def progress_relative_path
      File.join("progress", "workflow-progress.md")
    end

    def progress_path(run_root)
      File.join(run_root, progress_relative_path)
    end

    def execution_summary_relative_path
      File.join("contract", "contract-execution-summary.md")
    end

    def execution_summary_path(run_root)
      File.join(run_root, execution_summary_relative_path)
    end

    def artifact_relative_path(step_id)
      step = step_for(step_id)
      return nil unless step

      File.join(working_dir_relative_path, step.fetch("filename"))
    end

    def render_relative_path(step_id)
      step = step_for(step_id)
      return nil unless step

      File.join(rendered_dir_relative_path, step.fetch("rendered_filename"))
    end

    def artifact_path(step_id, run_root)
      path = artifact_relative_path(step_id)
      path ? File.join(run_root, path) : nil
    end

    def render_path(step_id, run_root)
      path = render_relative_path(step_id)
      path ? File.join(run_root, path) : nil
    end

    def review_relative_path
      artifact_relative_path("contract-04")
    end

    def review_path(run_root)
      File.join(run_root, review_relative_path)
    end

    def review_materials_relative_path
      File.join(working_dir_relative_path, "contract-04.review.materials.yml")
    end

    def review_materials_path(run_root)
      File.join(run_root, review_materials_relative_path)
    end

    def review_result_relative_path
      File.join(state_dir_relative_path, "contract-04.review-result.yaml")
    end

    def review_result_path(run_root)
      File.join(run_root, review_result_relative_path)
    end

    def template_path(root, artifact)
      File.join(root, "docs/contract/templates/structured/#{artifact}.template.yaml")
    end

    def openapi_relative_path
      File.join(release_dir_relative_path, "openapi.yaml")
    end

    def openapi_path(run_root)
      File.join(run_root, openapi_relative_path)
    end

    def openapi_summary_relative_path
      File.join(release_dir_relative_path, "openapi.summary.md")
    end

    def openapi_summary_path(run_root)
      File.join(run_root, openapi_summary_relative_path)
    end

    def develop_handoff_relative_path
      File.join(release_dir_relative_path, "develop-handoff.md")
    end

    def develop_handoff_path(run_root)
      File.join(run_root, develop_handoff_relative_path)
    end

    def contract_yaml_relative_path
      File.join(release_dir_relative_path, "contract.yaml")
    end

    def contract_yaml_path(run_root)
      File.join(run_root, contract_yaml_relative_path)
    end

    def contract_summary_relative_path
      File.join(release_dir_relative_path, "contract.summary.md")
    end

    def contract_summary_path(run_root)
      File.join(run_root, contract_summary_relative_path)
    end

    def release_files_relative_paths
      [
        contract_yaml_relative_path,
        contract_summary_relative_path,
        openapi_relative_path,
        openapi_summary_relative_path,
        develop_handoff_relative_path,
      ]
    end

    def release_files_paths(run_root)
      [
        contract_yaml_path(run_root),
        contract_summary_path(run_root),
        openapi_path(run_root),
        openapi_summary_path(run_root),
        develop_handoff_path(run_root),
      ]
    end

    def commands_for(step_id, run_root:, flow_id:, mode:, force:, reviewer: nil)
      step = step_for(step_id)
      return nil unless step

      run_id = File.basename(run_root)

      case mode
      when "artifact"
        command = ["ruby", "scripts/contract/init_artifact.rb"]
        command << "--force" if force
        command.concat([
          "--step-id", step.fetch("step_id"),
          "--contract-id", flow_id,
          "--batch-id", flow_id,
          "--run-id", run_id,
          step.fetch("artifact"),
          artifact_path(step_id, run_root),
        ])
        [command]
      when "review"
        return nil unless step.fetch("review_step")
        return nil if reviewer.to_s.strip.empty?

        command = ["ruby", "scripts/contract/init_review_context.rb"]
        command << "--force" if force
        command.concat([
          "--step", step.fetch("review_step"),
          "--step-id", "contract-04",
          "--contract-id", flow_id,
          "--batch-id", flow_id,
          "--subject", artifact_path(step_id, run_root),
          "--reviewer", reviewer,
          review_path(run_root),
        ])
        [command]
      when "render"
        [[
          "ruby",
          "scripts/contract/render_artifact.rb",
          step.fetch("artifact"),
          artifact_path(step_id, run_root),
          render_path(step_id, run_root),
        ]]
      else
        nil
      end
    end
  end
end
