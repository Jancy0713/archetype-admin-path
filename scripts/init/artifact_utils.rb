require "yaml"

module InitFlow
  module ArtifactUtils
    module_function

    ROOT = File.expand_path("../..", __dir__)

    ARTIFACT_TYPES = %w[project_profile review baseline change_request].freeze
    REVIEWABLE_STEPS = %w[project_initialization].freeze
    REVIEWABLE_SUBJECTS = {
      "project_initialization" => "project_profile",
    }.freeze
    PROJECT_PROFILE_STAGE_IDS = %w[
      foundation_context
      tenant_governance
      identity_access
      experience_platform
    ].freeze
    STAGE_REQUIRED_QUESTION_IDS = {
      "foundation_context" => %w[
        system_type
        audience_type
        default_region
        default_language
        primary_clients
        core_usage_scenario
      ],
      "tenant_governance" => %w[
        tenant_model
        tenant_subject
        platform_tenant_layers
        org_structure_needed
        org_structure_purpose
        governance_boundary
      ],
      "identity_access" => %w[
        login_method
        account_identifier
        account_system
        cross_tenant_account
        permission_model
        privileged_roles
        member_permission_basis
      ],
      "experience_platform" => %w[
        visual_direction
        theme_mode
        navigation_style
        information_density
        notifications_needed
        audit_log_needed
        export_needed
        upload_needed
        i18n_needed
      ],
    }.freeze
    BASELINE_TRACKED_FIELDS = {
      "project_summary" => %w[product_type business_mode target_market default_region default_language],
      "identity_access" => %w[login_methods account_identifier account_model permission_model tenant_model],
      "ui_foundation" => %w[visual_direction theme_mode density navigation_style],
      "platform_defaults" => %w[notifications audit_log upload export i18n],
    }.freeze
    REVIEW_STAGE_CHECKLIST_IDS = {
      "foundation_context" => %w[
        system_type_clarity
        audience_scope_clarity
        region_language_grounded
        primary_clients_grounded
        core_usage_scenario_grounded
        recommendations_not_blank_without_reason
        no_next_stage_prefill
      ],
      "tenant_governance" => %w[
        tenant_model_clarity
        tenant_subject_clarity
        platform_tenant_layers_clarity
        org_structure_need_clarity
        governance_boundary_clarity
        recommendations_not_blank_without_reason
        no_next_stage_prefill
      ],
      "identity_access" => %w[
        login_method_clarity
        account_identifier_clarity
        account_system_clarity
        cross_tenant_account_clarity
        permission_model_clarity
        privileged_roles_clarity
        recommendations_not_blank_without_reason
        no_next_stage_prefill
      ],
      "experience_platform" => %w[
        visual_direction_clarity
        theme_mode_clarity
        navigation_style_clarity
        information_density_clarity
        platform_capabilities_clarity
        recommendations_not_blank_without_reason
        no_next_stage_prefill
      ],
    }.freeze

    OPTION_SCHEMA = {
      type: :hash,
      keys: {
        "value" => { type: :string, non_empty: true },
        "label" => { type: :string, non_empty: true },
        "description" => { type: :string },
      },
    }.freeze

    DECISION_CANDIDATE_SCHEMA = {
      type: :hash,
      keys: {
        "topic" => { type: :string, non_empty: true },
        "question" => { type: :string, non_empty: true },
        "explanation" => { type: :string },
        "recommended" => { type: :string, non_empty: true },
        "options" => { type: :array, item_schema: OPTION_SCHEMA },
        "allow_multiple" => { type: :boolean },
        "default_if_no_answer" => { type: :string },
        "must_confirm" => { type: :boolean },
      },
    }.freeze

    DEFAULT_SCHEMA = {
      type: :hash,
      keys: {
        "topic" => { type: :string, non_empty: true },
        "explanation" => { type: :string, non_empty: true },
        "default_value" => { type: :string, non_empty: true },
        "rationale" => { type: :string, non_empty: true },
        "alternatives" => { type: :array, item_schema: { type: :string } },
        "must_confirm" => { type: :boolean },
        "upgrade_condition" => { type: :string },
      },
    }.freeze

    OPEN_QUESTIONS_SCHEMA = {
      type: :hash,
      keys: {
        "p0" => { type: :array, item_schema: { type: :string } },
        "p1" => { type: :array, item_schema: { type: :string } },
        "p2" => { type: :array, item_schema: { type: :string } },
      },
    }.freeze

    STAGE_CONFIRMATION_SCHEMA = {
      type: :hash,
      keys: {
        "required" => { type: :boolean },
        "confirmed" => { type: :boolean },
        "summary" => { type: :string },
        "confirmed_by" => { type: :string },
        "confirmed_at" => { type: :string },
      },
    }.freeze

    QUESTION_SUGGESTION_SCHEMA = {
      type: :hash,
      keys: {
        "question_id" => { type: :string, non_empty: true },
        "question" => { type: :string, non_empty: true },
        "recommended" => { type: :string },
        "options" => { type: :array, item_schema: OPTION_SCHEMA },
        "reason" => { type: :string, non_empty: true },
      },
    }.freeze

    FIELD_SOURCE_SCHEMA = {
      type: :hash,
      keys: {
        "stage_id" => { type: :string },
        "source_type" => { type: :string },
        "source_id" => { type: :string },
        "note" => { type: :string },
      },
    }.freeze

    BASELINE_FIELD_SOURCES_SCHEMA = {
      type: :hash,
      keys: BASELINE_TRACKED_FIELDS.transform_values do |fields|
        {
          type: :hash,
          keys: fields.each_with_object({}) do |field, memo|
            memo[field] = FIELD_SOURCE_SCHEMA
          end,
        }
      end,
    }.freeze

    REVIEW_CHECKLIST_ITEM_SCHEMA = {
      type: :hash,
      keys: {
        "item_id" => { type: :string, non_empty: true },
        "passed" => { type: :boolean },
        "note" => { type: :string, non_empty: true },
      },
    }.freeze

    CURRENT_STAGE_REVIEW_SCHEMA = {
      type: :hash,
      keys: {
        "stage_id" => { type: :string },
        "checklist" => { type: :array, item_schema: REVIEW_CHECKLIST_ITEM_SCHEMA },
      },
    }.freeze

    PROJECT_PROFILE_STAGE_SCHEMA = {
      type: :hash,
      keys: {
        "stage_id" => { type: :string, enum: PROJECT_PROFILE_STAGE_IDS },
        "stage_name" => { type: :string, non_empty: true },
        "priority" => { type: :string, enum: %w[p0 p1 p2] },
        "objective" => { type: :string, non_empty: true },
        "status" => { type: :string, enum: %w[pending in_progress confirmed] },
        "summary" => { type: :string },
        "confirmation" => STAGE_CONFIRMATION_SCHEMA,
        "required_questions" => { type: :array, item_schema: QUESTION_SUGGESTION_SCHEMA },
        "adaptive_questions" => { type: :array, item_schema: QUESTION_SUGGESTION_SCHEMA, max_items: 2 },
        "key_decisions" => { type: :array, item_schema: DECISION_CANDIDATE_SCHEMA },
        "recommended_defaults" => { type: :array, item_schema: DEFAULT_SCHEMA },
        "open_questions" => OPEN_QUESTIONS_SCHEMA,
      },
    }.freeze

    SCHEMAS = {
      "project_profile" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "project_profile" },
          "version" => { type: :string, equals: "1.0" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "project_initialization" },
              "attempt" => { type: :integer, min: 1 },
              "max_retry" => { type: :integer, equals: 2 },
              "ready_for_next" => { type: :boolean },
            },
          },
          "meta" => {
            type: :hash,
            keys: {
              "title" => { type: :string, non_empty: true },
              "flow_id" => { type: :string },
              "step_id" => { type: :string },
              "artifact_id" => { type: :string },
              "source_paths" => { type: :array, item_schema: { type: :string, non_empty: true } },
              "owner" => { type: :string },
              "updated_at" => { type: :string },
            },
          },
          "project_profile" => {
            type: :hash,
            keys: {
              "project_summary" => { type: :string, non_empty: true },
              "system_type" => { type: :string },
              "product_type" => { type: :string },
              "business_mode" => { type: :string },
              "target_users" => { type: :array, item_schema: { type: :string } },
              "primary_clients" => { type: :array, item_schema: { type: :string } },
              "target_market" => { type: :string },
            },
          },
          "stage_progress" => {
            type: :hash,
            keys: {
              "current_stage" => { type: :string, enum: PROJECT_PROFILE_STAGE_IDS },
              "last_confirmed_stage" => { type: :string },
              "completed_stages" => { type: :array, item_schema: { type: :string, enum: PROJECT_PROFILE_STAGE_IDS } },
              "remaining_stages" => { type: :array, item_schema: { type: :string, enum: PROJECT_PROFILE_STAGE_IDS } },
              "profile_ready" => { type: :boolean },
            },
          },
          "stages" => { type: :array, item_schema: PROJECT_PROFILE_STAGE_SCHEMA },
          "decision" => {
            type: :hash,
            keys: {
              "allow_baseline" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "review" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "review" },
          "version" => { type: :string, equals: "1.0" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, enum: REVIEWABLE_STEPS },
              "attempt" => { type: :integer, min: 1 },
              "max_retry" => { type: :integer, equals: 2 },
            },
          },
          "meta" => {
            type: :hash,
            keys: {
              "subject_type" => { type: :string, enum: REVIEWABLE_SUBJECTS.values },
              "flow_id" => { type: :string },
              "step_id" => { type: :string },
              "artifact_id" => { type: :string },
              "subject_path" => { type: :string, non_empty: true },
              "reviewer" => { type: :string },
              "updated_at" => { type: :string },
            },
          },
          "current_stage_review" => CURRENT_STAGE_REVIEW_SCHEMA,
          "findings" => {
            type: :hash,
            keys: {
              "issues" => { type: :array, item_schema: { type: :string } },
              "missing_info" => { type: :array, item_schema: { type: :string } },
              "p0" => { type: :array, item_schema: { type: :string } },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "has_blocking_issue" => { type: :boolean },
              "allow_next_step" => { type: :boolean },
              "need_human_escalation" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
          "required_revisions" => { type: :array, item_schema: { type: :string } },
          "notes" => { type: :array, item_schema: { type: :string } },
        },
      },
      "baseline" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "baseline" },
          "version" => { type: :string, equals: "1.0" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "initialization_baseline" },
              "attempt" => { type: :integer, min: 1 },
              "max_retry" => { type: :integer, equals: 2 },
              "ready_for_next" => { type: :boolean },
            },
          },
          "meta" => {
            type: :hash,
            keys: {
              "title" => { type: :string, non_empty: true },
              "flow_id" => { type: :string },
              "step_id" => { type: :string },
              "artifact_id" => { type: :string },
              "source_paths" => { type: :array, item_schema: { type: :string, non_empty: true } },
              "updated_at" => { type: :string },
            },
          },
          "project_summary" => {
            type: :hash,
            keys: {
              "product_type" => { type: :string },
              "business_mode" => { type: :string },
              "target_market" => { type: :string },
              "default_region" => { type: :string },
              "default_language" => { type: :string },
            },
          },
          "identity_access" => {
            type: :hash,
            keys: {
              "login_methods" => { type: :array, item_schema: { type: :string } },
              "account_identifier" => { type: :string },
              "account_model" => { type: :string },
              "permission_model" => { type: :string },
              "tenant_model" => { type: :string },
            },
          },
          "ui_foundation" => {
            type: :hash,
            keys: {
              "visual_direction" => { type: :string },
              "theme_mode" => { type: :string },
              "density" => { type: :string },
              "navigation_style" => { type: :string },
            },
          },
          "platform_defaults" => {
            type: :hash,
            keys: {
              "notifications" => { type: :string },
              "audit_log" => { type: :string },
              "upload" => { type: :string },
              "export" => { type: :string },
              "i18n" => { type: :string },
            },
          },
          "field_sources" => BASELINE_FIELD_SOURCES_SCHEMA,
          "key_decisions" => { type: :array, item_schema: DECISION_CANDIDATE_SCHEMA },
          "recommended_defaults" => { type: :array, item_schema: DEFAULT_SCHEMA },
          "open_questions" => {
            type: :hash,
            keys: {
              "p0" => { type: :array, item_schema: { type: :string } },
              "p1" => { type: :array, item_schema: { type: :string } },
              "p2" => { type: :array, item_schema: { type: :string } },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "baseline_confirmed" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "change_request" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "change_request" },
          "version" => { type: :string, equals: "1.0" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "initialization_change" },
              "attempt" => { type: :integer, min: 1 },
              "max_retry" => { type: :integer, equals: 2 },
              "ready_for_next" => { type: :boolean },
            },
          },
          "meta" => {
            type: :hash,
            keys: {
              "title" => { type: :string, non_empty: true },
              "flow_id" => { type: :string },
              "step_id" => { type: :string },
              "artifact_id" => { type: :string },
              "source_paths" => { type: :array, item_schema: { type: :string, non_empty: true } },
              "updated_at" => { type: :string },
            },
          },
          "change" => {
            type: :hash,
            keys: {
              "target_domain" => { type: :string, non_empty: true },
              "current_baseline" => { type: :string },
              "requested_change" => { type: :string, non_empty: true },
              "reason" => { type: :string, non_empty: true },
            },
          },
          "impact" => {
            type: :hash,
            keys: {
              "affected_areas" => { type: :array, item_schema: { type: :string } },
              "blocking_risk" => { type: :string },
              "migration_notes" => { type: :array, item_schema: { type: :string } },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "allow_update" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
    }.freeze

    def load_yaml(path)
      YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
    rescue Psych::SyntaxError => e
      raise ArgumentError, "Invalid YAML syntax: #{e.message}"
    end

    def validate_artifact(artifact, data, artifact_path: nil)
      errors = []
      schema = SCHEMAS[artifact]
      unless schema
        errors << "Unknown artifact type: #{artifact}"
        return errors
      end

      validate_node(data, schema, [], errors)
      validate_state_rules(artifact, data, errors) if errors.empty?
      validate_cross_file_rules(artifact, data, artifact_path, errors) if errors.empty? && artifact_path
      errors
    end

    def validate_node(value, schema, path, errors)
      label = path.empty? ? "<root>" : path.join(".")
      case schema[:type]
      when :hash
        unless value.is_a?(Hash)
          errors << "#{label} must be an object"
          return
        end
        expected_keys = schema.fetch(:keys)
        value.keys.each do |key|
          errors << "#{join_path(path, key)} is not allowed" unless expected_keys.key?(key)
        end
        expected_keys.each do |key, child_schema|
          if value.key?(key)
            validate_node(value[key], child_schema, path + [key], errors)
          else
            errors << "#{join_path(path, key)} is missing"
          end
        end
      when :array
        unless value.is_a?(Array)
          errors << "#{label} must be an array"
          return
        end
        if schema[:max_items] && value.length > schema[:max_items]
          errors << "#{label} must contain at most #{schema[:max_items]} items"
        end
        return unless schema[:item_schema]
        value.each_with_index do |item, index|
          validate_node(item, schema[:item_schema], path + [index.to_s], errors)
        end
      when :string
        unless value.is_a?(String)
          errors << "#{label} must be a string"
          return
        end
        errors << "#{label} must not be empty" if schema[:non_empty] && value.strip.empty?
        errors << "#{label} must equal #{schema[:equals].inspect}" if schema[:equals] && value != schema[:equals]
        if schema[:enum] && !schema[:enum].include?(value)
          errors << "#{label} must be one of: #{schema[:enum].join(', ')}"
        end
      when :integer
        errors << "#{label} must be an integer" unless value.is_a?(Integer)
        errors << "#{label} must be >= #{schema[:min]}" if schema[:min] && value.is_a?(Integer) && value < schema[:min]
        errors << "#{label} must equal #{schema[:equals]}" if schema[:equals] && value.is_a?(Integer) && value != schema[:equals]
      when :boolean
        errors << "#{label} must be a boolean" unless value == true || value == false
      end
    end

    def validate_state_rules(artifact, data, errors)
      attempt = dig(data, %w[status attempt]).to_i
      max_retry = dig(data, %w[status max_retry]).to_i
      if attempt > max_retry + 1
        errors << "status.attempt exceeds allowed retry window (max #{max_retry + 1})"
      end

      case artifact
      when "project_profile"
        ensure_ready_flag_matches(errors, data, %w[decision allow_baseline], "decision.allow_baseline")
        ensure_ready_flag_matches(errors, data, %w[stage_progress profile_ready], "stage_progress.profile_ready")
        validate_profile_stages(data, errors)
        validate_profile_stage_decisions(data, errors)
      when "baseline"
        ensure_ready_flag_matches(errors, data, %w[decision baseline_confirmed], "decision.baseline_confirmed")
        block_on_p0(errors, data, %w[open_questions p0], %w[decision baseline_confirmed], "decision.baseline_confirmed")
        validate_decision_candidates(data, errors)
        validate_baseline_field_source_completeness(data, errors)
      when "change_request"
        ensure_ready_flag_matches(errors, data, %w[decision allow_update], "decision.allow_update")
      when "review"
        validate_review_state(data, errors)
      end
    end

    def validate_review_state(data, errors)
      has_blocking = dig(data, %w[decision has_blocking_issue])
      allow_next = dig(data, %w[decision allow_next_step])
      escalation = dig(data, %w[decision need_human_escalation])
      p0 = Array(dig(data, %w[findings p0]))
      step = dig(data, %w[status step])
      subject_type = dig(data, %w[meta subject_type])

      errors << "decision.has_blocking_issue must be true when findings.p0 is not empty" if !p0.empty? && has_blocking != true
      errors << "decision.allow_next_step cannot be true when decision.has_blocking_issue is true" if has_blocking == true && allow_next == true
      errors << "decision.allow_next_step cannot be true when decision.need_human_escalation is true" if escalation == true && allow_next == true
      expected_subject = REVIEWABLE_SUBJECTS[step]
      errors << "meta.subject_type must be #{expected_subject.inspect} when status.step is #{step.inspect}" if expected_subject && subject_type != expected_subject

      checklist = Array(dig(data, %w[current_stage_review checklist]))
      if checklist.any? && has_blocking != true && checklist.any? { |item| item["passed"] == false }
        errors << "decision.has_blocking_issue must be true when current_stage_review.checklist contains failed items"
      end
    end

    def validate_profile_stages(data, errors)
      stages = Array(data["stages"])
      stage_ids = stages.map { |stage| stage["stage_id"] }
      errors << "stages must contain each required stage exactly once" unless stage_ids.sort == PROJECT_PROFILE_STAGE_IDS.sort

      progress = data["stage_progress"] || {}
      current_stage = progress["current_stage"]
      last_confirmed_stage = progress["last_confirmed_stage"].to_s
      completed_stages = Array(progress["completed_stages"])
      remaining_stages = Array(progress["remaining_stages"])
      profile_ready = progress["profile_ready"]
      stage_map = stages.each_with_object({}) { |stage, memo| memo[stage["stage_id"]] = stage }
      ordered_stages = PROJECT_PROFILE_STAGE_IDS.map { |stage_id| stage_map[stage_id] }
      statuses = ordered_stages.map { |stage| stage["status"] }
      in_progress = ordered_stages.select { |stage| stage["status"] == "in_progress" }.map { |stage| stage["stage_id"] }
      confirmed = ordered_stages.select { |stage| stage["status"] == "confirmed" }.map { |stage| stage["stage_id"] }
      pending = ordered_stages.select { |stage| stage["status"] == "pending" }.map { |stage| stage["stage_id"] }

      if completed_stages.uniq.length != completed_stages.length
        errors << "stage_progress.completed_stages must not contain duplicates"
      end
      if remaining_stages.uniq.length != remaining_stages.length
        errors << "stage_progress.remaining_stages must not contain duplicates"
      end

      unless contiguous_statuses?(statuses, profile_ready)
        errors << "stages must progress in order: confirmed -> in_progress -> pending"
      end

      ordered_stages.each do |stage|
        validate_profile_stage_content(stage, current_stage, errors)
        validate_profile_stage_confirmation(stage, errors)
        validate_profile_stage_questions(stage, errors)
      end

      unless completed_stages == confirmed
        errors << "stage_progress.completed_stages must match stages marked confirmed"
      end
      unless remaining_stages == pending
        errors << "stage_progress.remaining_stages must match stages marked pending"
      end

      expected_last_confirmed = confirmed.last.to_s
      unless last_confirmed_stage == expected_last_confirmed
        errors << "stage_progress.last_confirmed_stage must match the latest confirmed stage"
      end

      if profile_ready
        errors << "all stages must be completed when stage_progress.profile_ready is true" unless pending.empty? && in_progress.empty?
      else
        errors << "exactly one stage must be in_progress before profile is ready" unless in_progress.length == 1
      end

      if profile_ready
        errors << "stage_progress.current_stage must match the last confirmed stage when profile is ready" unless current_stage == confirmed.last
      elsif in_progress.first != current_stage
        errors << "stage_progress.current_stage must match the stage marked in_progress"
      end

      expected_remaining = if profile_ready
        []
      else
        current_index = PROJECT_PROFILE_STAGE_IDS.index(current_stage)
        current_index ? PROJECT_PROFILE_STAGE_IDS[(current_index + 1)..] || [] : []
      end
      unless remaining_stages == expected_remaining
        errors << "stage_progress.remaining_stages must list stages after current_stage in order"
      end

      all_p0 = ordered_stages.flat_map { |stage| Array(dig(stage, %w[open_questions p0])) }
      if all_p0.any?
        errors << "decision.allow_baseline must be false when any stage open_questions.p0 is not empty" if dig(data, %w[decision allow_baseline]) != false
        errors << "status.ready_for_next must be false when any stage open_questions.p0 is not empty" if dig(data, %w[status ready_for_next]) != false
        errors << "stage_progress.profile_ready must be false when any stage open_questions.p0 is not empty" if dig(data, %w[stage_progress profile_ready]) != false
      end

      unless profile_ready == (confirmed.length == PROJECT_PROFILE_STAGE_IDS.length)
        errors << "stage_progress.profile_ready must be true only when all stages are confirmed"
      end
      unless dig(data, %w[decision allow_baseline]) == profile_ready
        errors << "decision.allow_baseline must match stage_progress.profile_ready"
      end
      unless dig(data, %w[status ready_for_next]) == profile_ready
        errors << "status.ready_for_next must match stage_progress.profile_ready"
      end
    end

    def validate_profile_stage_decisions(data, errors)
      Array(data["stages"]).each do |stage|
        validate_decision_candidates(stage, errors, prefix: "stages.#{stage['stage_id']}")
      end
    end

    def validate_profile_stage_content(stage, current_stage, errors)
      stage_id = stage["stage_id"]
      status = stage["status"]
      has_summary = !stage["summary"].to_s.strip.empty?
      has_adaptive_questions = Array(stage["adaptive_questions"]).any?
      has_decisions = Array(stage["key_decisions"]).any?
      has_defaults = Array(stage["recommended_defaults"]).any?
      has_open_questions = %w[p0 p1 p2].any? { |level| Array(dig(stage, ["open_questions", level])).any? }

      if status == "pending"
        if has_summary || has_adaptive_questions || has_decisions || has_defaults || has_open_questions
          errors << "stages.#{stage_id} must stay empty while pending; do not prefill future stages"
        end
      end

      if status == "in_progress" && stage_id != current_stage
        errors << "only stage_progress.current_stage may be marked in_progress"
      end
    end

    def validate_profile_stage_confirmation(stage, errors)
      stage_id = stage["stage_id"]
      status = stage["status"]
      confirmation = stage["confirmation"] || {}
      confirmed = confirmation["confirmed"]
      summary = confirmation["summary"].to_s.strip
      confirmed_by = confirmation["confirmed_by"].to_s.strip
      confirmed_at = confirmation["confirmed_at"].to_s.strip

      if status == "confirmed"
        errors << "stages.#{stage_id}.confirmation.confirmed must be true when stage status is confirmed" unless confirmed == true
        errors << "stages.#{stage_id}.confirmation.summary must not be empty when stage status is confirmed" if summary.empty?
      else
        errors << "stages.#{stage_id}.confirmation.confirmed must be false before the stage is confirmed" unless confirmed == false
        errors << "stages.#{stage_id}.confirmation.summary must stay empty before the stage is confirmed" unless summary.empty?
        errors << "stages.#{stage_id}.confirmation.confirmed_by must stay empty before the stage is confirmed" unless confirmed_by.empty?
        errors << "stages.#{stage_id}.confirmation.confirmed_at must stay empty before the stage is confirmed" unless confirmed_at.empty?
      end
    end

    def validate_profile_stage_questions(stage, errors)
      stage_id = stage["stage_id"]
      expected_ids = STAGE_REQUIRED_QUESTION_IDS.fetch(stage_id)
      required_questions = Array(stage["required_questions"])
      actual_ids = required_questions.map { |item| item["question_id"] }

      unless actual_ids == expected_ids
        errors << "stages.#{stage_id}.required_questions must match the fixed question set and order"
      end

      required_questions.each_with_index do |question, index|
        validate_question_suggestion(stage_id, question, errors, "stages.#{stage_id}.required_questions.#{index}", adaptive: false)
      end

      adaptive_questions = Array(stage["adaptive_questions"])
      adaptive_questions.each_with_index do |question, index|
        validate_question_suggestion(stage_id, question, errors, "stages.#{stage_id}.adaptive_questions.#{index}", adaptive: true)
      end
    end

    def validate_question_suggestion(stage_id, question, errors, prefix, adaptive:)
      options = Array(question["options"])
      recommended = question["recommended"].to_s.strip
      reason = question["reason"].to_s.strip
      question_id = question["question_id"].to_s.strip

      if adaptive && STAGE_REQUIRED_QUESTION_IDS.fetch(stage_id).include?(question_id)
        errors << "#{prefix}.question_id must not duplicate a fixed required question"
      end

      if recommended.empty?
        errors << "#{prefix}.reason must explain why no recommendation is provided" if reason.empty?
      else
        errors << "#{prefix}.options must not be empty when recommended is present" if options.empty?
        option_values = options.map { |option| option["value"] }
        errors << "#{prefix}.recommended must match one of options.value" unless option_values.include?(recommended)
      end
    end

    def contiguous_statuses?(statuses, profile_ready)
      if profile_ready
        statuses.all? { |status| status == "confirmed" }
      else
        seen_in_progress = false
        seen_pending = false
        statuses.all? do |status|
          case status
          when "confirmed"
            !seen_in_progress && !seen_pending
          when "in_progress"
            return false if seen_pending || seen_in_progress
            seen_in_progress = true
            true
          when "pending"
            seen_pending = true
            true
          else
            false
          end
        end
      end
    end

    def validate_decision_candidates(data, errors, prefix: "key_decisions")
      Array(data["key_decisions"]).each_with_index do |item, index|
        option_values = Array(item["options"]).map { |option| option["value"] }
        errors << "#{prefix}.#{index}.recommended must match one of options.value" unless option_values.include?(item["recommended"])
        next if item["default_if_no_answer"].to_s.strip.empty?
        errors << "#{prefix}.#{index}.default_if_no_answer must match one of options.value" unless option_values.include?(item["default_if_no_answer"])
      end
    end

    def validate_cross_file_rules(artifact, data, artifact_path, errors)
      case artifact
      when "project_profile", "baseline", "change_request"
        validate_source_paths(data, artifact_path, errors)
      when "review"
        validate_review_subject(data, artifact_path, errors)
      end
      if artifact == "baseline"
        paths = validate_source_paths(data, artifact_path, errors)
        referenced = paths.map { |path| load_referenced_yaml(path) }.compact
        errors << "meta.source_paths must include at least one project_profile artifact" unless referenced.any? { |ref| ref["artifact_type"] == "project_profile" }
        referenced.select { |ref| ref["artifact_type"] == "project_profile" }.each do |profile|
          validate_baseline_source_profile(profile, errors)
          validate_baseline_field_sources(data, profile, errors)
        end
      end
    end

    def validate_baseline_source_profile(profile, errors)
      unless dig(profile, %w[stage_progress profile_ready]) == true
        errors << "baseline source project_profile must have stage_progress.profile_ready=true"
      end
      unless dig(profile, %w[decision allow_baseline]) == true
        errors << "baseline source project_profile must have decision.allow_baseline=true"
      end
      Array(profile["stages"]).each do |stage|
        next if dig(stage, %w[confirmation confirmed]) == true
        errors << "baseline source project_profile contains an unconfirmed stage: #{stage['stage_id']}"
      end
    end

    def validate_baseline_field_source_completeness(data, errors)
      BASELINE_TRACKED_FIELDS.each do |section, fields|
        fields.each do |field|
          value = dig(data, [section, field])
          source = dig(data, ["field_sources", section, field]) || {}
          if present_value?(value)
            errors << "field_sources.#{section}.#{field}.stage_id must not be empty when #{section}.#{field} is set" if source["stage_id"].to_s.strip.empty?
            errors << "field_sources.#{section}.#{field}.source_type must not be empty when #{section}.#{field} is set" if source["source_type"].to_s.strip.empty?
            errors << "field_sources.#{section}.#{field}.source_id must not be empty when #{section}.#{field} is set" if source["source_id"].to_s.strip.empty?
          end
        end
      end
    end

    def validate_baseline_field_sources(data, profile, errors)
      stage_map = Array(profile["stages"]).each_with_object({}) { |stage, memo| memo[stage["stage_id"]] = stage }

      BASELINE_TRACKED_FIELDS.each do |section, fields|
        fields.each do |field|
          value = dig(data, [section, field])
          next unless present_value?(value)

          source = dig(data, ["field_sources", section, field]) || {}
          validate_single_field_source(profile, stage_map, source, errors, "#{section}.#{field}")
        end
      end
    end

    def validate_single_field_source(profile, stage_map, source, errors, label)
      stage_id = source["stage_id"].to_s.strip
      source_type = source["source_type"].to_s.strip
      source_id = source["source_id"].to_s.strip

      unless PROJECT_PROFILE_STAGE_IDS.include?(stage_id) || source_type == "project_profile_field"
        errors << "field_sources.#{label}.stage_id must reference a known stage unless source_type is project_profile_field"
      end

      allowed_source_types = %w[required_question adaptive_question key_decision recommended_default project_profile_field stage_summary]
      unless allowed_source_types.include?(source_type)
        errors << "field_sources.#{label}.source_type must be one of: #{allowed_source_types.join(', ')}"
        return
      end

      if source_type == "project_profile_field"
        profile_fields = profile.fetch("project_profile", {}).keys
        errors << "field_sources.#{label}.source_id must reference project_profile.*" unless profile_fields.include?(source_id)
        return
      end

      stage = stage_map[stage_id]
      unless stage
        errors << "field_sources.#{label}.stage_id references a missing stage"
        return
      end
      unless dig(stage, %w[confirmation confirmed]) == true
        errors << "field_sources.#{label}.stage_id must point to a confirmed stage"
        return
      end

      case source_type
      when "required_question"
        question_ids = Array(stage["required_questions"]).map { |item| item["question_id"] }
        errors << "field_sources.#{label}.source_id must match a required question_id in stage #{stage_id}" unless question_ids.include?(source_id)
      when "adaptive_question"
        question_ids = Array(stage["adaptive_questions"]).map { |item| item["question_id"] }
        errors << "field_sources.#{label}.source_id must match an adaptive question_id in stage #{stage_id}" unless question_ids.include?(source_id)
      when "key_decision"
        topics = Array(stage["key_decisions"]).map { |item| item["topic"] }
        errors << "field_sources.#{label}.source_id must match a key_decisions.topic in stage #{stage_id}" unless topics.include?(source_id)
      when "recommended_default"
        topics = Array(stage["recommended_defaults"]).map { |item| item["topic"] }
        errors << "field_sources.#{label}.source_id must match a recommended_defaults.topic in stage #{stage_id}" unless topics.include?(source_id)
      when "stage_summary"
        errors << "field_sources.#{label}.source_id must be 'summary' when source_type is stage_summary" unless source_id == "summary"
        errors << "field_sources.#{label}.stage_id must have a non-empty summary when source_type is stage_summary" if stage["summary"].to_s.strip.empty?
      end
    end

    def present_value?(value)
      case value
      when Array
        !value.empty?
      when String
        !value.strip.empty?
      else
        !value.nil?
      end
    end

    def validate_source_paths(data, artifact_path, errors)
      source_paths = Array(dig(data, %w[meta source_paths]))
      if source_paths.empty?
        errors << "meta.source_paths must include at least one source file"
        return []
      end
      source_paths.map do |raw_path|
        resolved = resolve_existing_path(raw_path, artifact_path)
        if resolved
          resolved
        else
          errors << "meta.source_paths contains a missing file: #{raw_path}"
          nil
        end
      end.compact
    end

    def validate_review_subject(data, artifact_path, errors)
      raw_path = dig(data, %w[meta subject_path])
      resolved = resolve_existing_path(raw_path, artifact_path)
      unless resolved
        errors << "meta.subject_path points to a missing file: #{raw_path}"
        return
      end
      subject = load_referenced_yaml(resolved)
      unless subject
        errors << "meta.subject_path is not a valid YAML artifact: #{raw_path}"
        return
      end
      review_step = dig(data, %w[status step])
      expected_subject = REVIEWABLE_SUBJECTS[review_step]
      errors << "meta.subject_path must point to a #{expected_subject.inspect} artifact when status.step is #{review_step.inspect}" if expected_subject && subject["artifact_type"] != expected_subject
      errors << "subject status.step=#{dig(subject, %w[status step]).inspect} does not match review status.step=#{review_step.inspect}" if dig(subject, %w[status step]) != review_step
      validate_review_stage_checklist(data, subject, errors) if subject["artifact_type"] == "project_profile"
    end

    def validate_review_stage_checklist(review, subject, errors)
      current_stage = dig(subject, %w[stage_progress current_stage]).to_s
      stage_id = dig(review, %w[current_stage_review stage_id]).to_s
      checklist = Array(dig(review, %w[current_stage_review checklist]))
      expected_ids = REVIEW_STAGE_CHECKLIST_IDS[current_stage] || []
      actual_ids = checklist.map { |item| item["item_id"] }

      errors << "current_stage_review.stage_id must match subject current stage #{current_stage.inspect}" unless stage_id == current_stage
      unless actual_ids == expected_ids
        errors << "current_stage_review.checklist must match the required review checklist for stage #{current_stage.inspect}"
      end
    end

    def ensure_ready_flag_matches(errors, data, decision_path, label)
      ready = dig(data, %w[status ready_for_next])
      decision = dig(data, decision_path)
      errors << "status.ready_for_next must match #{label}" unless ready == decision
    end

    def block_on_p0(errors, data, p0_path, decision_path, label)
      p0 = Array(dig(data, p0_path))
      return if p0.empty?
      errors << "#{label} must be false when #{p0_path.join('.')} is not empty" if dig(data, decision_path) != false
      errors << "status.ready_for_next must be false when #{p0_path.join('.')} is not empty" if dig(data, %w[status ready_for_next]) != false
    end

    def dig(data, keys)
      keys.reduce(data) { |value, key| value.is_a?(Hash) ? value[key] : nil }
    end

    def load_referenced_yaml(path)
      load_yaml(path)
    rescue ArgumentError
      nil
    end

    def resolve_existing_path(raw_path, artifact_path)
      return nil unless raw_path.is_a?(String) && !raw_path.strip.empty?
      candidates = []
      candidates << raw_path if raw_path.start_with?("/")
      candidates << File.expand_path(raw_path, File.dirname(artifact_path))
      candidates << File.expand_path(raw_path, ROOT)
      candidates.uniq.find { |candidate| File.exist?(candidate) }
    end

    def join_path(path, key)
      (path + [key]).join(".")
    end
  end
end
