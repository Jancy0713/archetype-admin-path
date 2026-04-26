require "fileutils"
require "pathname"
require "yaml"

require_relative "artifact_utils"
require_relative "workflow_manifest"

module ContractFlow
  ROOT = File.expand_path("../..", __dir__)
  module HandoffGeneration
    LEGACY_INDEX_RELATIVE_PATH = File.join("contract", "contract-batch-index.yaml").freeze
    LEGACY_DOC_RELATIVE_PATH = File.join("contract", "contract-handoff.md").freeze
    LEGACY_HANDOFF_DIR_RELATIVE_PATH = File.join("contract", "handoffs").freeze
    LEGACY_PROGRESS_RELATIVE_PATH = File.join("contract", "contract-progress.md").freeze
    LEGACY_SUMMARY_RELATIVE_PATH = File.join("contract", "contract-execution-summary.md").freeze

    module_function

    def generate!(run_root:, final_prd_path:, force: false, allow_existing: false)
      run_root = File.expand_path(run_root)
      final_prd_path = File.expand_path(final_prd_path)

      raise ArgumentError, "Run directory not found: #{run_root}" unless Dir.exist?(run_root)
      raise ArgumentError, "final_prd file not found: #{final_prd_path}" unless File.exist?(final_prd_path)

      final_prd = Contract::ArtifactUtils.load_yaml(final_prd_path)
      unless final_prd["artifact_type"] == "final_prd"
        raise ArgumentError, "Expected final_prd artifact: #{final_prd_path}"
      end

      unless final_prd.dig("decision", "allow_contract_design") == true
        raise ArgumentError, "final_prd does not allow contract design: #{final_prd_path}"
      end

      if Array(final_prd.dig("blocking_questions", "p0")).any?
        raise ArgumentError, "final_prd still has blocking_questions.p0; cannot generate contract handoffs"
      end

      ordered_flow_ids, ordered_flows = resolve_flows(final_prd)

      index_path = contract_handoff_index_path(run_root)
      overview_doc_path = contract_handoff_doc_path(run_root)
      flows_dir = contract_handoff_flows_dir(run_root)

      if force
        clear_contract_handoff!(run_root)
      elsif existing_handoffs?(run_root)
        return reuse_existing!(run_root, final_prd_path, ordered_flow_ids) if allow_existing

        raise ArgumentError, "Contract handoff artifacts already exist in #{contract_handoff_dir(run_root)} (use --force to overwrite)"
      end

      cleanup_legacy_handoffs!(run_root)
      FileUtils.mkdir_p(flows_dir)

      # Status is determined by physical release presence.
      flow_statuses = build_flow_statuses(ordered_flows, released_flow_ids: find_released_flow_ids)
      current_flow_id = ordered_flow_ids.find { |flow_id| flow_statuses[flow_id] == "ready" }.to_s
      index_data = build_index(run_root, final_prd_path, ordered_flows, ordered_flow_ids, flow_statuses, current_flow_id)
      overview_doc = build_overview_doc(run_root, final_prd_path, ordered_flows, ordered_flow_ids, flow_statuses, current_flow_id)

      ordered_flows.each_with_index do |flow, index_position|
        order = index_position + 1
        yaml_path = contract_flow_handoff_yaml_path(run_root, order, flow.fetch("batch_id"))
        markdown_path = contract_flow_handoff_markdown_path(run_root, order, flow.fetch("batch_id"))
        File.write(yaml_path, YAML.dump(build_flow_handoff(run_root, final_prd, final_prd_path, flow, order, ordered_flows.length, flow_statuses, current_flow_id)))
        File.write(markdown_path, build_flow_handoff_doc(run_root, final_prd, final_prd_path, flow, order, ordered_flows.length, flow_statuses, current_flow_id))
      end

      File.write(index_path, YAML.dump(index_data))
      File.write(overview_doc_path, overview_doc)

      build_result(
        run_root: run_root,
        index_path: index_path,
        overview_doc_path: overview_doc_path,
        ordered_flow_ids: ordered_flow_ids,
        current_flow_id: current_flow_id,
        reused: false
      )
    end

    def advance_after_release!(prd_run_root:, released_flow_id:)
      # DEPRECATED/DISABLED for Step 7 to enforce Isolation.
      # Contract runs should NOT modify PRD runs.
      # Downstream flows check physical release files instead.
      warn "advance_after_release is deprecated and will not modify PRD run index to enforce isolation."
      {}
    end

    # Hardened dependency check: find flows that have a formal release package.
    def flow_ready?(flow, released_flow_ids: nil)
      dependencies = Array(flow["dependency_batches"]) || Array(flow["dependency_flows"])
      return true if dependencies.empty?

      released_flow_ids ||= find_released_flow_ids
      dependencies.all? { |dep_id| released_flow_ids.include?(dep_id) }
    end

    def find_released_flow_ids
      base_runs_dir = ContractFlow::WorkflowManifest.runs_root(ROOT)
      released_ids = []
      Dir.glob(File.join(base_runs_dir, "*")).each do |run_dir|
        next unless Dir.exist?(run_dir)

        run_manifest_path = File.join(run_dir, "run.yaml")
        next unless File.exist?(run_manifest_path)

        run_manifest = Contract::ArtifactUtils.load_yaml(run_manifest_path) rescue nil
        next unless run_manifest && run_manifest["flow"] == "contract"

        flow_id = run_manifest["flow_id"]

        # Check for physical release of openapi.yaml
        release_file = File.join(run_dir, ContractFlow::WorkflowManifest.release_dir_relative_path, "openapi.yaml")
        if File.exist?(release_file)
          released_ids << flow_id
        end
      end
      released_ids.uniq
    end

    def relative_to_run(run_root, path)
      Pathname.new(File.expand_path(path)).relative_path_from(Pathname.new(File.expand_path(run_root))).to_s
    end

    def contract_handoff_dir(run_root)
      File.join(run_root, "contract_handoff")
    end

    def contract_handoff_index_path(run_root)
      File.join(contract_handoff_dir(run_root), "contract-handoff.index.yaml")
    end

    def contract_handoff_doc_path(run_root)
      File.join(contract_handoff_dir(run_root), "contract-handoff.md")
    end

    def contract_handoff_flows_dir(run_root)
      File.join(contract_handoff_dir(run_root), "flows")
    end

    def contract_flow_handoff_yaml_path(run_root, order, flow_id)
      File.join(contract_handoff_flows_dir(run_root), format("%02d.%s.handoff.yaml", order, flow_id))
    end

    def contract_flow_handoff_markdown_path(run_root, order, flow_id)
      File.join(contract_handoff_flows_dir(run_root), format("%02d.%s.handoff.md", order, flow_id))
    end

    def existing_handoffs?(run_root)
      File.exist?(contract_handoff_index_path(run_root)) ||
        File.exist?(contract_handoff_doc_path(run_root)) ||
        Dir.exist?(contract_handoff_flows_dir(run_root))
    end

    def clear_contract_handoff!(run_root)
      FileUtils.rm_f(contract_handoff_index_path(run_root))
      FileUtils.rm_f(contract_handoff_doc_path(run_root))
      FileUtils.rm_rf(contract_handoff_flows_dir(run_root))
      FileUtils.rm_rf(contract_handoff_dir(run_root)) if Dir.exist?(contract_handoff_dir(run_root)) && Dir.empty?(contract_handoff_dir(run_root))
    end

    def cleanup_legacy_handoffs!(run_root)
      FileUtils.rm_f(File.join(run_root, LEGACY_INDEX_RELATIVE_PATH))
      FileUtils.rm_f(File.join(run_root, LEGACY_DOC_RELATIVE_PATH))
      FileUtils.rm_rf(File.join(run_root, LEGACY_HANDOFF_DIR_RELATIVE_PATH))
      FileUtils.rm_f(File.join(run_root, LEGACY_PROGRESS_RELATIVE_PATH))
      FileUtils.rm_f(File.join(run_root, LEGACY_SUMMARY_RELATIVE_PATH))
    end

    def reuse_existing!(run_root, final_prd_path, ordered_flow_ids)
      index_path = contract_handoff_index_path(run_root)
      overview_doc_path = contract_handoff_doc_path(run_root)
      raise ArgumentError, "Existing contract handoff index not found: #{index_path}" unless File.exist?(index_path)
      raise ArgumentError, "Existing contract handoff doc not found: #{overview_doc_path}" unless File.exist?(overview_doc_path)

      index = Contract::ArtifactUtils.load_yaml(index_path)
      source_final_prd = index["source_final_prd"].to_s
      if File.expand_path(source_final_prd) != final_prd_path
        raise ArgumentError, "Existing contract handoffs were generated from a different final_prd: #{source_final_prd}"
      end

      existing_flows = Array(index["recommended_flow_order"])
      if existing_flows != ordered_flow_ids
        raise ArgumentError, "Existing contract handoff order does not match current final_prd"
      end

      build_result(
        run_root: run_root,
        index_path: index_path,
        overview_doc_path: overview_doc_path,
        ordered_flow_ids: ordered_flow_ids,
        current_flow_id: index["current_recommended_flow"].to_s.empty? ? ordered_flow_ids.first : index["current_recommended_flow"],
        reused: true
      )
    end

    def resolve_flows(final_prd)
      raw_ready_batches = Array(final_prd["ready_batches"])
      ready_flow_ids =
        if raw_ready_batches.all? { |item| item.is_a?(String) }
          raw_ready_batches
        else
          Array(final_prd.dig("decision", "ready_batches"))
        end
      ready_flow_ids = Array(final_prd.dig("decision", "ready_batches")) if ready_flow_ids.empty?

      flow_sources = raw_ready_batches.any? { |item| item.is_a?(Hash) } ? raw_ready_batches : Array(final_prd["prd_batches"])
      flow_lookup = flow_sources.each_with_object({}) do |flow, acc|
        next unless flow.is_a?(Hash) && present?(flow["batch_id"])
        next if ready_flow_ids.any? && !ready_flow_ids.include?(flow["batch_id"])
        next unless flow.dig("decision", "allow_contract_design") == true || ready_flow_ids.include?(flow["batch_id"])

        acc[flow["batch_id"]] = flow
      end
      raise ArgumentError, "No contract-ready flows found in final_prd" if flow_lookup.empty?

      recommended_order = Array(final_prd.dig("contract_execution", "recommended_batch_order")).select { |flow_id| flow_lookup.key?(flow_id) }
      ordered_flow_ids = (recommended_order + flow_lookup.keys).uniq
      ordered_flows = ordered_flow_ids.map { |flow_id| flow_lookup.fetch(flow_id) }
      ordered_flows.each { |flow| validate_contract_handoff!(flow) }
      [ordered_flow_ids, ordered_flows]
    end

    def validate_contract_handoff!(flow)
      flow_id = flow.fetch("batch_id")
      handoff = flow["contract_handoff"]
      raise ArgumentError, "Ready flow #{flow_id} is missing contract_handoff" unless handoff.is_a?(Hash)

      {
        "contract_scope" => true,
        "required_contract_views" => true,
        "do_not_assume" => true,
      }.each do |key, non_empty|
        value = Array(handoff[key]).select { |item| present?(item) }
        if non_empty && value.empty?
          raise ArgumentError, "Ready flow #{flow_id} is missing contract_handoff.#{key}"
        end
      end
    end

    def build_index(run_root, final_prd_path, ordered_flows, ordered_flow_ids, flow_statuses, current_flow_id)
      {
        "artifact_type" => "contract_handoff_index",
        "run_id" => File.basename(run_root),
        "source_final_prd" => final_prd_path,
        "recommended_flow_order" => ordered_flow_ids,
        "recommended_entry_flow" => current_flow_id,
        "current_recommended_flow" => current_flow_id,
        "flows" => ordered_flows.each_with_index.map do |flow, index_position|
          flow_id = flow.fetch("batch_id")
          {
            "flow_id" => flow_id,
            "title" => flow["title"].to_s,
            "order" => index_position + 1,
            "depends_on_flows" => Array(flow["dependency_batches"]),
            "status" => flow_statuses.fetch(flow_id),
            "recommended_entry" => flow_id == current_flow_id,
            "handoff_yaml_path" => relative_to_run(run_root, contract_flow_handoff_yaml_path(run_root, index_position + 1, flow_id)),
            "handoff_markdown_path" => relative_to_run(run_root, contract_flow_handoff_markdown_path(run_root, index_position + 1, flow_id)),
          }
        end,
      }
    end

    def build_overview_doc(run_root, final_prd_path, ordered_flows, ordered_flow_ids, flow_statuses, current_flow_id)
      doc = +"# Contract Handoff\n\n"
      doc << "## Summary\n\n"
      doc << "- Source Final PRD: #{relative_to_run(run_root, final_prd_path)}\n"
      doc << "- Total Flows: #{ordered_flows.length}\n"
      doc << "- Recommended Entry Flow: #{current_flow_id}\n\n"
      doc << "## Guidance\n\n"
      doc << "- `final_prd` review 已正式收口为 `contract_handoff/`，后续 contract 默认从单个 flow handoff 进入。\n"
      doc << "- 如果需求边界仍需调整，先回到 `final_prd`，不要直接改 handoff 或下游 contract。\n"
      doc << "- 当前轮次只确定 handoff，不在这里提前展开 `contract/release/`、`openapi/swagger` 或 `develop`。\n\n"
      doc << "## Ordered Flows\n\n"

      ordered_flows.each_with_index do |flow, index_position|
        flow_id = flow.fetch("batch_id")
        doc << "### #{flow_id}\n\n"
        doc << "- Order: #{index_position + 1}/#{ordered_flows.length}\n"
        doc << "- Title: #{flow['title']}\n" if present?(flow["title"])
        doc << "- Summary:\n#{render_list(flow['summary'])}\n"
        doc << "- Depends On Flows:\n#{render_list(flow['dependency_batches'])}\n"
        doc << "- Status: #{flow_statuses.fetch(flow_id)}\n"
        doc << "- Recommended Entry: #{flow_id == current_flow_id ? 'yes' : 'no'}\n"
        doc << "- Structured Handoff: `#{relative_to_run(run_root, contract_flow_handoff_yaml_path(run_root, index_position + 1, flow_id))}`\n"
        doc << "- Readable Handoff: `#{relative_to_run(run_root, contract_flow_handoff_markdown_path(run_root, index_position + 1, flow_id))}`\n\n"
      end

      doc
    end

    def build_flow_handoff(run_root, final_prd, final_prd_path, flow, order, total_flows, flow_statuses, current_flow_id)
      flow_id = flow.fetch("batch_id")
      handoff = flow.fetch("contract_handoff")

      {
        "artifact_type" => "contract_flow_handoff",
        "run_id" => File.basename(run_root),
        "source_final_prd" => final_prd_path,
        "flow_id" => flow_id,
        "flow_title" => flow["title"].to_s,
        "order" => order,
        "total_flows" => total_flows,
        "status" => flow_statuses.fetch(flow_id),
        "scope_summary" => Array(flow["summary"]).select { |item| present?(item) },
        "upstream_sources" => upstream_sources(run_root, final_prd, final_prd_path),
        "dependency_flows" => Array(flow["dependency_batches"]),
        "current_scope" => Array(handoff["contract_scope"]).select { |item| present?(item) },
        "priority_modules" => Array(handoff["priority_modules"]).select { |item| present?(item) },
        "required_contract_views" => Array(handoff["required_contract_views"]).select { |item| present?(item) },
        "do_not_assume" => Array(handoff["do_not_assume"]).select { |item| present?(item) },
        "recommended_entry" => {
          "is_default" => flow_id == current_flow_id,
          "reason" => recommended_entry_reason(flow, flow_statuses.fetch(flow_id), flow_id == current_flow_id),
          "next_contract_input" => ContractFlow::WorkflowManifest.first_artifact_relative_path(flow_id),
        },
      }
    end

    def upstream_sources(run_root, final_prd, final_prd_path)
      sources = []
      sources << final_prd_path if present?(final_prd_path)
      sources.concat(Array(final_prd.dig("meta", "source_paths")).select { |item| present?(item) })
      sources.concat(resolved_external_dependency_paths(run_root, final_prd))
      sources.uniq
    end

    def resolved_external_dependency_paths(run_root, final_prd)
      Array(final_prd.dig("constraints", "external_dependencies")).filter_map do |reference|
        resolve_dependency_path(run_root, reference)
      end
    end

    def resolve_dependency_path(run_root, reference)
      raw = reference.to_s.strip
      raw = raw.sub(/\A项目级规则文档\s+/, "").strip
      return nil unless file_reference_like?(raw)

      candidates = []
      candidates << raw if Pathname.new(raw).absolute?
      candidates << File.join(ROOT, raw)
      candidates << File.join(run_root, raw)
      candidates << File.join(ROOT, "merchant-ai-video-admin", raw)

      if File.basename(raw) == "project-conventions.md"
        candidates.concat(Dir.glob(File.join(ROOT, "*", "docs", "project", "project-conventions.md")))
      end

      found = candidates.find { |candidate| File.exist?(candidate) }
      found ? File.expand_path(found) : raw
    end

    def file_reference_like?(value)
      return false unless present?(value)

      value.include?("/") || value.match?(/\.(md|ya?ml|json|txt)\z/i)
    end

    def build_flow_handoff_doc(run_root, final_prd, final_prd_path, flow, order, total_flows, flow_statuses, current_flow_id)
      flow_id = flow.fetch("batch_id")
      handoff = flow.fetch("contract_handoff")

      content = +"# Contract Flow Handoff: #{flow_id}\n\n"
      content << "## Flow Summary\n\n"
      content << "- Flow Id: `#{flow_id}`\n"
      content << "- Title: #{flow['title']}\n" if present?(flow["title"])
      content << "- Order: #{order}/#{total_flows}\n"
      content << "- Source Final PRD: `#{relative_to_run(run_root, final_prd_path)}`\n"
      content << "- Depends On Flows:\n#{render_list(flow['dependency_batches'])}\n"
      content << "- Status: `#{flow_statuses.fetch(flow_id)}`\n"
      content << "- Range Summary:\n#{render_list(flow['summary'])}\n\n"
      content << "## Upstream Sources\n\n"
      content << render_list(upstream_sources(run_root, final_prd, final_prd_path).map { |path| relative_to_run(run_root, path) })
      content << "\n\n## Current Scope\n\n"
      content << "- Contract Scope:\n#{render_list(handoff['contract_scope'])}\n"
      content << "- Priority Modules:\n#{render_list(handoff['priority_modules'])}\n"
      content << "- Required Contract Views:\n#{render_list(handoff['required_contract_views'])}\n\n"
      content << "## Do Not Assume\n\n"
      content << "#{render_list(handoff['do_not_assume'])}\n\n"
      content << "## Recommended Entry\n\n"
      content << "- #{recommended_entry_reason(flow, flow_statuses.fetch(flow_id), flow_id == current_flow_id)}\n"
      content << "- 后续 contract 默认从这个单个 flow handoff 进入，不直接把整份 `final_prd` 当作单一输入。\n"
      content
    end

    def recommended_entry_reason(flow, status, is_current)
      if is_current
        "当前推荐先进入这个 flow，因为它的依赖已经满足。"
      elsif status == "released"
        "当前不推荐先进入这个 flow，因为它已经完成 release。"
      elsif Array(flow["dependency_batches"]).empty?
        "当前不推荐先进入这个 flow，因为虽然它没有依赖，但当前推荐入口已经落在更靠前的 ready flow。"
      else
        "当前不推荐先进入这个 flow，因为它依赖前序 flows：#{Array(flow['dependency_batches']).join(', ')}。"
      end
    end

    def build_flow_statuses(ordered_flows, released_flow_ids:)
      ordered_flows.each_with_object({}) do |flow, acc|
        flow_id = flow.fetch("batch_id")
        acc[flow_id] = flow_ready?(flow, released_flow_ids: released_flow_ids) ? "ready" : "pending_dependencies"
      end
    end

    def build_result(run_root:, index_path:, overview_doc_path:, ordered_flow_ids:, current_flow_id:, reused:)
      current_flow_id = ordered_flow_ids.first if current_flow_id.to_s.empty?
      current_flow_order = ordered_flow_ids.index(current_flow_id).to_i + 1
      {
        index_path: index_path,
        overview_doc_path: overview_doc_path,
        ordered_flow_ids: ordered_flow_ids,
        current_flow_id: current_flow_id,
        current_flow_handoff_yaml_path: contract_flow_handoff_yaml_path(run_root, current_flow_order, current_flow_id),
        current_flow_handoff_markdown_path: contract_flow_handoff_markdown_path(run_root, current_flow_order, current_flow_id),
        reused: reused,
      }
    end

    def present?(value)
      case value
      when nil
        false
      when String
        !value.strip.empty?
      when Array, Hash
        !value.empty?
      else
        true
      end
    end

    def render_list(items)
      values = Array(items).select { |item| present?(item) }
      return "- None\n" if values.empty?

      values.map { |item| "- #{item}" }.join("\n") + "\n"
    end
  end
end
