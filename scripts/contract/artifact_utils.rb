require "yaml"

module Contract
  module ArtifactUtils
    module_function

    ROOT = File.expand_path("../..", __dir__)

    ARTIFACT_TYPES = %w[scope_intake domain_mapping contract_spec review].freeze
    REVIEWABLE_STEPS = %w[contract_spec_ready].freeze
    ARTIFACT_VERSIONS = %w[1.0.0].freeze
    ARTIFACT_STEP_IDS = {
      "scope_intake" => "contract-01",
      "domain_mapping" => "contract-02",
      "contract_spec" => "contract-03",
      "review" => "contract-04",
    }.freeze
    STEP_PROMPT_PATHS = {
      "scope_intake" => "docs/contract/prompts/scope_intake/STEP_PROMPT.md",
      "domain_mapping" => "docs/contract/prompts/domain_mapping/STEP_PROMPT.md",
      "contract_spec" => "docs/contract/prompts/contract_spec/STEP_PROMPT.md",
      "review" => "docs/contract/prompts/review/STEP_PROMPT.md",
    }.freeze
    RULE_PATHS = {
      "scope_intake" => "docs/contract/rules/CONTRACT_SCOPE_INTAKE_RULE.md",
      "domain_mapping" => "docs/contract/rules/CONTRACT_DOMAIN_MAPPING_RULE.md",
      "contract_spec" => "docs/contract/rules/CONTRACT_SPEC_RULE.md",
      "review" => "docs/contract/reviewer/common/REVIEWER_WORKFLOW.md",
      "reference" => "docs/contract/rules/CONTRACT_REFERENCE_RULE.md",
    }.freeze
    TEMPLATE_PATHS = {
      "scope_intake" => "docs/contract/templates/structured/scope_intake.template.yaml",
      "domain_mapping" => "docs/contract/templates/structured/domain_mapping.template.yaml",
      "contract_spec" => "docs/contract/templates/structured/contract_spec.template.yaml",
      "review" => "docs/contract/templates/structured/review.template.yaml",
    }.freeze
    REVIEWER_CHECKLIST_PATHS = {
      "contract_spec_ready" => "docs/contract/reviewer/checklists/contract_spec_ready.md",
    }.freeze

    def load_yaml(path)
      YAML.safe_load(File.read(path), permitted_classes: [Time], aliases: true)
    rescue Psych::Exception => e
      raise ArgumentError, "YAML parse error in #{path}: #{e.message}"
    end

    def artifact_materials(artifact)
      return nil unless ARTIFACT_TYPES.include?(artifact)

      {
        "artifact" => artifact,
        "step_prompt" => absolute_path(STEP_PROMPT_PATHS[artifact]),
        "rule" => absolute_path(RULE_PATHS[artifact == "review" ? "review" : artifact]),
        "reference_rule" => absolute_path(RULE_PATHS["reference"]),
        "template" => absolute_path(TEMPLATE_PATHS[artifact]),
      }.compact
    end

    def review_materials(review_step)
      return nil unless REVIEWABLE_STEPS.include?(review_step)

      {
        "review_step" => review_step,
        "reviewer_prompt" => absolute_path("docs/contract/prompts/REVIEWER_PROMPT.md"),
        "reviewer_workflow" => absolute_path("docs/contract/reviewer/common/REVIEWER_WORKFLOW.md"),
        "reviewer_checklist" => absolute_path(REVIEWER_CHECKLIST_PATHS[review_step]),
        "review_template" => absolute_path(TEMPLATE_PATHS["review"]),
      }
    end

    # Current hardening scope intentionally focuses on the minimum invariants that
    # keep contract runs trustworthy: step identity, contract_id=batch_id in MVP,
    # reviewer subject consistency, and handoff-snapshot-based single-flow inputs.
    def validate_artifact(artifact, data, artifact_path: nil)
      errors = []
      validate_common(artifact, data, errors, artifact_path: artifact_path)

      case artifact
      when "scope_intake"
        validate_scope_intake(data, errors, artifact_path: artifact_path)
      when "domain_mapping"
        validate_domain_mapping(data, errors, artifact_path: artifact_path)
      when "contract_spec"
        validate_contract_spec(data, errors, artifact_path: artifact_path)
      when "review"
        validate_review(data, errors, artifact_path: artifact_path)
      end

      errors.uniq
    end

    def absolute_path(path)
      return nil if blank?(path)

      File.expand_path(path, ROOT)
    end

    def expanded_path(path, artifact_path = nil)
      return nil if blank?(path)

      base = artifact_path ? File.dirname(File.expand_path(artifact_path, ROOT)) : ROOT
      File.expand_path(path, base)
    end

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end

    def present_collection?(value)
      case value
      when Array, Hash
        !value.empty?
      else
        !blank?(value)
      end
    end

    def artifact_type_at(path)
      return nil unless File.exist?(path)

      load_yaml(path)["artifact_type"]
    rescue ArgumentError
      nil
    end

    def validate_common(artifact, data, errors, artifact_path:)
      unless data.is_a?(Hash)
        errors << "artifact must be a mapping"
        return
      end

      errors << "artifact_type must be #{artifact}" unless data["artifact_type"] == artifact
      errors << "version must be one of: #{ARTIFACT_VERSIONS.join(', ')}" unless ARTIFACT_VERSIONS.include?(data["version"])

      meta = data["meta"]
      status = data["status"]
      errors << "meta must be a mapping" unless meta.is_a?(Hash)
      errors << "status must be a mapping" unless status.is_a?(Hash)
      return unless meta.is_a?(Hash) && status.is_a?(Hash)

      %w[flow_id step_id artifact_id contract_id batch_id].each do |key|
        errors << "meta.#{key} is required" if blank?(meta[key])
      end
      errors << "meta.flow_id must be contract" unless meta["flow_id"] == "contract"

      expected_step_id = ARTIFACT_STEP_IDS.fetch(artifact)
      errors << "meta.step_id must be #{expected_step_id}" unless meta["step_id"] == expected_step_id
      errors << "meta.contract_id must equal meta.batch_id in current MVP" if present_collection?(meta["contract_id"]) && present_collection?(meta["batch_id"]) && meta["contract_id"] != meta["batch_id"]
      validate_run_binding(meta, artifact_path, errors)

      case artifact
      when "scope_intake", "domain_mapping", "contract_spec"
        validate_step_status(status, artifact, errors)
      when "review"
        validate_review_status(status, errors)
      end
    end

    def validate_step_status(status, step_name, errors)
      errors << "status.step must be #{step_name}" unless status["step"] == step_name
      validate_attempt_status(status, errors)
      validate_boolean(status["ready_for_next"], "status.ready_for_next", errors)
    end

    def validate_review_status(status, errors)
      errors << "status.step must be contract_spec_ready" unless status["step"] == "contract_spec_ready"
      validate_attempt_status(status, errors)
    end

    def validate_attempt_status(status, errors)
      attempt = status["attempt"]
      max_retry = status["max_retry"]
      errors << "status.attempt must be an integer >= 1" unless attempt.is_a?(Integer) && attempt >= 1
      errors << "status.max_retry must be 2" unless max_retry == 2
      if attempt.is_a?(Integer) && max_retry.is_a?(Integer) && attempt > max_retry + 1
        errors << "status.attempt must not exceed status.max_retry + 1"
      end
    end

    def validate_boolean(value, path, errors)
      errors << "#{path} must be boolean" unless value == true || value == false
    end

    def validate_array_of_strings(value, path, errors, allow_empty: true)
      unless value.is_a?(Array)
        errors << "#{path} must be an array"
        return
      end

      errors << "#{path} must not be empty" if !allow_empty && value.empty?
      value.each_with_index do |entry, index|
        errors << "#{path}[#{index}] must be a non-empty string" if blank?(entry)
      end
    end

    def validate_existing_path(path, field, errors, artifact_path: nil, expected_type: nil, required: true)
      if blank?(path)
        errors << "#{field} is required" if required
        return nil
      end

      expanded = expanded_path(path, artifact_path)
      unless File.exist?(expanded)
        errors << "#{field} must point to an existing file"
        return expanded
      end

      if expected_type
        actual_type = artifact_type_at(expanded)
        errors << "#{field} must point to a #{expected_type} artifact" unless actual_type == expected_type
      end
      expanded
    end

    def validate_scope_intake(data, errors, artifact_path:)
      intake_basis = data["intake_basis"]
      batch_scope = data["batch_scope"]
      dependencies = data["dependencies"]
      blocking_items = data["blocking_items"]
      decision = data["decision"]

      errors << "intake_basis must be a mapping" unless intake_basis.is_a?(Hash)
      errors << "batch_scope must be a mapping" unless batch_scope.is_a?(Hash)
      errors << "dependencies must be a mapping" unless dependencies.is_a?(Hash)
      errors << "blocking_items must be a mapping" unless blocking_items.is_a?(Hash)
      errors << "decision must be a mapping" unless decision.is_a?(Hash)
      return unless intake_basis.is_a?(Hash) && batch_scope.is_a?(Hash) && dependencies.is_a?(Hash) && blocking_items.is_a?(Hash) && decision.is_a?(Hash)

      validate_existing_path(intake_basis["handoff_snapshot_path"], "intake_basis.handoff_snapshot_path", errors, artifact_path: artifact_path)
      validate_existing_path(intake_basis["handoff_summary_path"], "intake_basis.handoff_summary_path", errors, artifact_path: artifact_path)
      validate_existing_path(intake_basis["source_final_prd_path"], "intake_basis.source_final_prd_path", errors, artifact_path: artifact_path)
      errors << "batch_scope.goal is required" if blank?(batch_scope["goal"])

      scope_lists = %w[in_scope_modules in_scope_pages in_scope_resources in_scope_actions out_of_scope]
      scope_lists.each { |key| validate_array_of_strings(batch_scope[key], "batch_scope.#{key}", errors) }
      if %w[in_scope_modules in_scope_pages in_scope_resources in_scope_actions].all? { |key| Array(batch_scope[key]).empty? }
        errors << "batch_scope must define at least one in-scope module/page/resource/action"
      end

      %w[prerequisite_flows referenced_release_contracts unresolved_dependencies].each do |key|
        validate_array_of_strings(dependencies[key], "dependencies.#{key}", errors)
      end
      validate_array_of_strings(data["do_not_assume"], "do_not_assume", errors, allow_empty: false)
      validate_array_of_strings(blocking_items["p0"], "blocking_items.p0", errors)
      validate_array_of_strings(blocking_items["followups"], "blocking_items.followups", errors)
      validate_boolean(decision["allow_domain_mapping"], "decision.allow_domain_mapping", errors)
      errors << "decision.reason is required" if blank?(decision["reason"])

      if decision["allow_domain_mapping"] == true
        errors << "blocking_items.p0 must be empty when decision.allow_domain_mapping=true" unless Array(blocking_items["p0"]).empty?
        errors << "dependencies.unresolved_dependencies must be empty when decision.allow_domain_mapping=true" unless Array(dependencies["unresolved_dependencies"]).empty?
      end
    end

    def validate_domain_mapping(data, errors, artifact_path:)
      mapping_basis = data["mapping_basis"]
      resource_map = data["resource_map"]
      action_map = data["action_map"]
      consumer_view_map = data["consumer_view_map"]
      reference_plan = data["reference_plan"]
      decision = data["decision"]

      errors << "mapping_basis must be a mapping" unless mapping_basis.is_a?(Hash)
      errors << "resource_map must be a mapping" unless resource_map.is_a?(Hash)
      errors << "action_map must be a mapping" unless action_map.is_a?(Hash)
      errors << "consumer_view_map must be a mapping" unless consumer_view_map.is_a?(Hash)
      errors << "reference_plan must be a mapping" unless reference_plan.is_a?(Hash)
      errors << "decision must be a mapping" unless decision.is_a?(Hash)
      return unless mapping_basis.is_a?(Hash) && resource_map.is_a?(Hash) && action_map.is_a?(Hash) && consumer_view_map.is_a?(Hash) && reference_plan.is_a?(Hash) && decision.is_a?(Hash)

      validate_existing_path(mapping_basis["scope_intake_path"], "mapping_basis.scope_intake_path", errors, artifact_path: artifact_path, expected_type: "scope_intake")
      validate_existing_path(mapping_basis["handoff_snapshot_path"], "mapping_basis.handoff_snapshot_path", errors, artifact_path: artifact_path)
      validate_existing_path(mapping_basis["source_final_prd_path"], "mapping_basis.source_final_prd_path", errors, artifact_path: artifact_path)
      validate_array_of_strings(mapping_basis["referenced_release_contracts"], "mapping_basis.referenced_release_contracts", errors)
      validate_array_of_strings(mapping_basis["referenced_artifacts"], "mapping_basis.referenced_artifacts", errors)

      resources = Array(resource_map["resources"])
      actions = Array(action_map["actions"])
      views = Array(consumer_view_map["views"])
      errors << "resource_map.resources must not be empty" if resources.empty?
      errors << "action_map.actions must not be empty" if actions.empty?
      errors << "consumer_view_map.views must not be empty" if views.empty?
      validate_array_of_strings(reference_plan["depends_on_modules"], "reference_plan.depends_on_modules", errors)
      validate_array_of_strings(reference_plan["symbol_references"], "reference_plan.symbol_references", errors)
      validate_array_of_strings(reference_plan["definitions_to_finalize_in_spec"], "reference_plan.definitions_to_finalize_in_spec", errors, allow_empty: false)
      validate_boolean(decision["allow_contract_spec"], "decision.allow_contract_spec", errors)
      errors << "decision.reason is required" if blank?(decision["reason"])
    end

    def validate_contract_spec(data, errors, artifact_path:)
      spec_scope = data["spec_scope"]
      resource_contracts = data["resource_contracts"]
      consumer_views = data["consumer_views"]
      query_and_command_semantics = data["query_and_command_semantics"]
      access_rules = data["access_and_tenant_rules"]
      validation_semantics = data["validation_and_error_semantics"]
      decision = data["decision"]

      errors << "spec_scope must be a mapping" unless spec_scope.is_a?(Hash)
      errors << "resource_contracts must be a mapping" unless resource_contracts.is_a?(Hash)
      errors << "consumer_views must be a mapping" unless consumer_views.is_a?(Hash)
      errors << "query_and_command_semantics must be a mapping" unless query_and_command_semantics.is_a?(Hash)
      errors << "access_and_tenant_rules must be a mapping" unless access_rules.is_a?(Hash)
      errors << "validation_and_error_semantics must be a mapping" unless validation_semantics.is_a?(Hash)
      errors << "decision must be a mapping" unless decision.is_a?(Hash)
      return unless spec_scope.is_a?(Hash) && resource_contracts.is_a?(Hash) && consumer_views.is_a?(Hash) && query_and_command_semantics.is_a?(Hash) && access_rules.is_a?(Hash) && validation_semantics.is_a?(Hash) && decision.is_a?(Hash)

      errors << "spec_scope.summary is required" if blank?(spec_scope["summary"])
      %w[modules_in_scope pages_in_scope resources_in_scope actions_in_scope out_of_scope].each do |key|
        validate_array_of_strings(spec_scope[key], "spec_scope.#{key}", errors)
      end

      errors << "resource_contracts.resources must not be empty" if Array(resource_contracts["resources"]).empty?
      errors << "consumer_views.views must not be empty" if Array(consumer_views["views"]).empty?
      queries = Array(query_and_command_semantics["queries"])
      commands = Array(query_and_command_semantics["commands"])
      errors << "query_and_command_semantics must define at least one query or command" if queries.empty? && commands.empty?
      validate_array_of_strings(access_rules["roles"], "access_and_tenant_rules.roles", errors, allow_empty: false)
      validate_array_of_strings(access_rules["tenant_rules"], "access_and_tenant_rules.tenant_rules", errors)
      validate_array_of_strings(access_rules["view_access_rules"], "access_and_tenant_rules.view_access_rules", errors)
      validate_array_of_strings(validation_semantics["validations"], "validation_and_error_semantics.validations", errors, allow_empty: false)
      validate_array_of_strings(validation_semantics["error_cases"], "validation_and_error_semantics.error_cases", errors, allow_empty: false)
      validate_array_of_strings(validation_semantics["empty_and_failure_states"], "validation_and_error_semantics.empty_and_failure_states", errors)
      validate_boolean(decision["allow_review"], "decision.allow_review", errors)
      errors << "decision.reason is required" if blank?(decision["reason"])

      if decision["allow_review"] == true
        validate_contract_spec_api_surface(data["api_surface"], errors)
      end
    end

    def validate_contract_spec_api_surface(api_surface, errors)
      unless api_surface.is_a?(Hash)
        errors << "api_surface must be a mapping"
        return
      end

      endpoints = Array(api_surface["endpoints"])
      if endpoints.empty?
        errors << "api_surface.endpoints must not be empty when decision.allow_review=true"
        return
      end

      endpoints.each_with_index do |ep, index|
        path = "api_surface.endpoints[#{index}]"
        errors << "#{path}.operation_id is required" if blank?(ep["operation_id"])
        errors << "#{path}.method is required" if blank?(ep["method"])
        errors << "#{path}.path is required" if blank?(ep["path"])
        errors << "#{path}.summary is required" if blank?(ep["summary"])

        method = ep["method"].to_s.upcase
        unless %w[GET POST PUT DELETE PATCH].include?(method)
          errors << "#{path}.method must be one of GET, POST, PUT, DELETE, PATCH"
        end

        req = ep["request"]
        if req.is_a?(Hash)
          validate_array_of_hashes(req["query"], "#{path}.request.query", %w[name schema], errors) if req["query"]
        end

        res = ep["response"]
        if res.is_a?(Hash)
          errors << "#{path}.response.status is required" if blank?(res["status"])
          errors << "#{path}.response.schema is required" if blank?(res["schema"])
        else
          errors << "#{path}.response is required"
        end
      end
    end

    def validate_array_of_hashes(list, path, required_keys, errors)
      unless list.is_a?(Array)
        errors << "#{path} must be an array"
        return
      end
      list.each_with_index do |item, index|
        unless item.is_a?(Hash)
          errors << "#{path}[#{index}] must be a mapping"
          next
        end
        required_keys.each do |key|
          errors << "#{path}[#{index}].#{key} is required" if blank?(item[key])
        end
      end
    end

    def validate_review(data, errors, artifact_path:)
      meta = data["meta"]
      review_scope = data["review_scope"]
      findings = data["findings"]
      decision = data["decision"]

      errors << "meta.subject_type must be contract_spec" unless meta["subject_type"] == "contract_spec"
      errors << "review_scope must be a mapping" unless review_scope.is_a?(Hash)
      errors << "findings must be a mapping" unless findings.is_a?(Hash)
      errors << "decision must be a mapping" unless decision.is_a?(Hash)
      return unless review_scope.is_a?(Hash) && findings.is_a?(Hash) && decision.is_a?(Hash)

      subject_path = validate_existing_path(meta["subject_path"], "meta.subject_path", errors, artifact_path: artifact_path, expected_type: "contract_spec")
      subject_data = subject_path && File.exist?(subject_path) ? load_yaml(subject_path) : nil
      if subject_data.is_a?(Hash)
        errors << "meta.contract_id must match subject meta.contract_id" unless subject_data.dig("meta", "contract_id") == meta["contract_id"]
        errors << "meta.batch_id must match subject meta.batch_id" unless subject_data.dig("meta", "batch_id") == meta["batch_id"]
      end

      validate_existing_path(review_scope["scope_intake_path"], "review_scope.scope_intake_path", errors, artifact_path: artifact_path, expected_type: "scope_intake")
      validate_existing_path(review_scope["domain_mapping_path"], "review_scope.domain_mapping_path", errors, artifact_path: artifact_path, expected_type: "domain_mapping")
      validate_existing_path(review_scope["checklist_path"], "review_scope.checklist_path", errors, artifact_path: artifact_path)
      validate_existing_path(review_scope["handoff_snapshot_path"], "review_scope.handoff_snapshot_path", errors, artifact_path: artifact_path)
      validate_review_scope_binding(review_scope, meta, artifact_path, errors)
      validate_array_of_strings(findings["issues"], "findings.issues", errors)
      validate_array_of_strings(findings["missing_info"], "findings.missing_info", errors)
      validate_array_of_strings(findings["p0"], "findings.p0", errors)
      validate_boolean(decision["has_blocking_issue"], "decision.has_blocking_issue", errors)
      validate_boolean(decision["allow_release"], "decision.allow_release", errors)
      validate_boolean(decision["need_human_escalation"], "decision.need_human_escalation", errors)
      errors << "decision.reason is required" if blank?(decision["reason"])

      if decision["allow_release"] == true
        errors << "findings.p0 must be empty when decision.allow_release=true" unless Array(findings["p0"]).empty?
        errors << "decision.has_blocking_issue must be false when decision.allow_release=true" unless decision["has_blocking_issue"] == false
      end
      if decision["has_blocking_issue"] == true
        allowed_steps = %w[scope_intake domain_mapping contract_spec]
        unless allowed_steps.include?(decision["suggested_return_step"])
          errors << "decision.suggested_return_step must be one of: #{allowed_steps.join(', ')} when decision.has_blocking_issue=true"
        end
      end
    end

    def validate_review_scope_binding(review_scope, meta, artifact_path, errors)
      return if artifact_path.nil?

      run_root = run_root_for_artifact_path(artifact_path)
      return if run_root.nil?

      expected_paths = {
        "meta.subject_path" => File.join(run_root, "contract", "working", "contract-03.contract_spec.yaml"),
        "review_scope.scope_intake_path" => File.join(run_root, "contract", "working", "contract-01.scope_intake.yaml"),
        "review_scope.domain_mapping_path" => File.join(run_root, "contract", "working", "contract-02.domain_mapping.yaml"),
        "review_scope.handoff_snapshot_path" => File.join(run_root, "intake", "contract-handoff.snapshot.yaml"),
      }

      expected_paths.each do |field, expected_path|
        source =
          if field.start_with?("meta.")
            meta[field.split(".").last]
          else
            review_scope[field.split(".").last]
          end
        actual = expanded_path(source, artifact_path)
        next unless actual

        errors << "#{field} must point to the current flow run" unless File.expand_path(actual) == expected_path
      end
    end

    def run_root_for_artifact_path(artifact_path)
      current = File.dirname(File.expand_path(artifact_path, ROOT))

      loop do
        run_manifest_path = File.join(current, "run.yaml")
        handoff_snapshot_path = File.join(current, "intake", "contract-handoff.snapshot.yaml")
        return current if File.exist?(run_manifest_path) && File.exist?(handoff_snapshot_path)

        parent = File.dirname(current)
        return nil if parent == current

        current = parent
      end
    end

    def current_run_flow_id(artifact_path)
      run_root = run_root_for_artifact_path(artifact_path)
      return nil if run_root.nil?

      run_manifest = load_yaml(File.join(run_root, "run.yaml"))
      handoff_snapshot = load_yaml(File.join(run_root, "intake", "contract-handoff.snapshot.yaml"))
      run_flow_id = run_manifest["flow_id"].to_s
      handoff_flow_id = handoff_snapshot["flow_id"].to_s
      return nil if blank?(run_flow_id) || blank?(handoff_flow_id) || run_flow_id != handoff_flow_id

      run_flow_id
    rescue ArgumentError
      nil
    end

    def validate_run_binding(meta, artifact_path, errors)
      return if artifact_path.nil? || !meta.is_a?(Hash)

      expected_flow_id = current_run_flow_id(artifact_path)
      return if blank?(expected_flow_id)

      errors << "meta.batch_id must match the current flow run" unless meta["batch_id"] == expected_flow_id
      errors << "meta.contract_id must match the current flow run" unless meta["contract_id"] == expected_flow_id
    end

    def decision_gate_for(artifact)
      {
        "scope_intake" => "allow_domain_mapping",
        "domain_mapping" => "allow_contract_spec",
        "contract_spec" => "allow_review",
      }[artifact]
    end

    def decision_allows_next_step?(artifact, data)
      gate_key = decision_gate_for(artifact)
      return true unless gate_key

      data.is_a?(Hash) && data.fetch("decision", {}).is_a?(Hash) && data["decision"][gate_key] == true
    end
  end
end
