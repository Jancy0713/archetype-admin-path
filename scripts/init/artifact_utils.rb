require "yaml"

module InitFlow
  module ArtifactUtils
    module_function

    ROOT = File.expand_path("../..", __dir__)

    ARTIFACT_TYPES = %w[project_profile review baseline design_seed bootstrap_plan change_request].freeze
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
        ui_style_recipe
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
      "ui_foundation" => %w[visual_direction style_recipe theme_mode density navigation_style],
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
        ui_style_recipe_clarity
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

    CONFIRMATION_ITEM_SCHEMA = {
      type: :hash,
      keys: {
        "item_id" => { type: :string, non_empty: true },
        "question" => { type: :string, non_empty: true },
        "level" => { type: :string, enum: %w[secondary primary required] },
        "answer_mode" => { type: :string, enum: %w[single_choice multi_choice text] },
        "recommended" => { type: :string },
        "options" => { type: :array, item_schema: OPTION_SCHEMA },
        "reason" => { type: :string },
        "allow_custom_answer" => { type: :boolean },
        "default_if_no_answer" => { type: :string },
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

    DESIGN_TOKEN_ITEM_SCHEMA = {
      type: :hash,
      keys: {
        "token" => { type: :string, non_empty: true },
        "value" => { type: :string, non_empty: true },
        "note" => { type: :string },
      },
    }.freeze

    DESIGN_COLOR_ROLE_SCHEMA = {
      type: :hash,
      keys: {
        "role" => { type: :string, non_empty: true },
        "value" => { type: :string, non_empty: true },
        "usage" => { type: :string },
      },
    }.freeze

    BOOTSTRAP_CONTEXT_SECTION_SCHEMA = {
      type: :hash,
      keys: {
        "primary_inputs" => { type: :array, item_schema: { type: :string } },
        "design_seed_highlights" => { type: :array, item_schema: { type: :string } },
      },
    }.freeze

    PRD_BOOTSTRAP_MODULE_SCHEMA = {
      type: :hash,
      keys: {
        "module_id" => { type: :string, non_empty: true },
        "name" => { type: :string, non_empty: true },
        "objective" => { type: :string, non_empty: true },
        "requirements" => { type: :array, item_schema: { type: :string } },
      },
    }.freeze

    BOOTSTRAP_OUTPUT_ARTIFACTS_SCHEMA = {
      type: :hash,
      keys: {
        "template_path" => { type: :string, non_empty: true },
        "target_path" => { type: :string, non_empty: true },
      },
    }.freeze

    BOOTSTRAP_PRESET_PACK_SCHEMA = {
      type: :hash,
      keys: {
        "pack_id" => { type: :string, non_empty: true },
        "name" => { type: :string, non_empty: true },
        "enabled_when" => { type: :string, non_empty: true },
        "preset_actions" => { type: :array, item_schema: { type: :string } },
        "install_commands" => { type: :array, item_schema: { type: :string } },
        "generated_files" => { type: :array, item_schema: { type: :string } },
        "ai_followups" => { type: :array, item_schema: { type: :string } },
      },
    }.freeze

    BOOTSTRAP_CONDITIONAL_PARAMETER_SCHEMA = {
      type: :hash,
      keys: {
        "parameter_id" => { type: :string, non_empty: true },
        "source_field" => { type: :string, non_empty: true },
        "current_value" => { type: :string, non_empty: true },
        "effect_on_scope" => { type: :array, item_schema: { type: :string } },
      },
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
        "confirmation_items" => { type: :array, item_schema: CONFIRMATION_ITEM_SCHEMA },
      },
    }.freeze

    SCHEMAS = {
      "project_profile" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "project_profile" },
          "version" => { type: :string, equals: "1.0.2" },
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
          "version" => { type: :string, equals: "1.0.2" },
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
          "version" => { type: :string, equals: "1.0.2" },
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
              "style_recipe" => { type: :string },
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
          "confirmation_items" => { type: :array, item_schema: CONFIRMATION_ITEM_SCHEMA },
          "decision" => {
            type: :hash,
            keys: {
              "baseline_confirmed" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "design_seed" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "design_seed" },
          "version" => { type: :string, equals: "1.0.2" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "initialization_design_seed" },
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
          "design_context" => {
            type: :hash,
            keys: {
              "current_baseline" => { type: :string, non_empty: true },
              "selected_style_recipe" => { type: :string, non_empty: true },
              "source_style_reference" => { type: :string, non_empty: true },
              "generation_policy" => { type: :string, non_empty: true },
            },
          },
          "theme_strategy" => {
            type: :hash,
            keys: {
              "default_mode" => { type: :string, non_empty: true },
              "supports_dark_mode" => { type: :string, non_empty: true },
              "density_strategy" => { type: :string, non_empty: true },
              "navigation_principle" => { type: :string, non_empty: true },
            },
          },
          "token_baseline" => {
            type: :hash,
            keys: {
              "spacing_scale" => { type: :array, item_schema: DESIGN_TOKEN_ITEM_SCHEMA },
              "radius_scale" => { type: :array, item_schema: DESIGN_TOKEN_ITEM_SCHEMA },
              "shadow_scale" => { type: :array, item_schema: DESIGN_TOKEN_ITEM_SCHEMA },
              "typography_scale" => { type: :array, item_schema: DESIGN_TOKEN_ITEM_SCHEMA },
              "color_roles" => { type: :array, item_schema: DESIGN_COLOR_ROLE_SCHEMA },
            },
          },
          "layout_principles" => {
            type: :hash,
            keys: {
              "app_shell" => { type: :string, non_empty: true },
              "page_patterns" => { type: :array, item_schema: { type: :string } },
              "component_principles" => { type: :array, item_schema: { type: :string } },
              "prohibited_patterns" => { type: :array, item_schema: { type: :string } },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "seed_ready" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "bootstrap_plan" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "bootstrap_plan" },
          "version" => { type: :string, equals: "1.0.2" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "initialization_bootstrap_plan" },
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
          "init_execution_scope" => {
            type: :hash,
            keys: {
              "output_artifacts" => BOOTSTRAP_OUTPUT_ARTIFACTS_SCHEMA,
              "conditional_parameters" => { type: :array, item_schema: BOOTSTRAP_CONDITIONAL_PARAMETER_SCHEMA },
              "preset_capability_packs" => { type: :array, item_schema: BOOTSTRAP_PRESET_PACK_SCHEMA },
              "command_blueprints" => { type: :array, item_schema: { type: :string } },
              "code_artifacts" => { type: :array, item_schema: { type: :string } },
              "ai_followups" => { type: :array, item_schema: { type: :string } },
              "allowed_work" => { type: :array, item_schema: { type: :string } },
              "excluded_work" => { type: :array, item_schema: { type: :string } },
              "deliverables" => { type: :array, item_schema: { type: :string } },
              "completion_criteria" => { type: :array, item_schema: { type: :string } },
              "reviewer_focus" => { type: :array, item_schema: { type: :string } },
            },
          },
          "project_conventions" => {
            type: :hash,
            keys: {
              "output_artifacts" => BOOTSTRAP_OUTPUT_ARTIFACTS_SCHEMA,
              "generation_workflow" => { type: :array, item_schema: { type: :string } },
              "source_of_truth" => BOOTSTRAP_CONTEXT_SECTION_SCHEMA,
              "sections_to_fill" => { type: :array, item_schema: { type: :string } },
              "reviewer_focus" => { type: :array, item_schema: { type: :string } },
              "notes" => { type: :array, item_schema: { type: :string } },
            },
          },
          "prd_bootstrap_context" => {
            type: :hash,
            keys: {
              "output_artifacts" => BOOTSTRAP_OUTPUT_ARTIFACTS_SCHEMA,
              "generation_workflow" => { type: :array, item_schema: { type: :string } },
              "document_goal" => { type: :array, item_schema: { type: :string } },
              "project_overview" => { type: :array, item_schema: { type: :string } },
              "confirmed_foundation" => { type: :array, item_schema: { type: :string } },
              "priority_modules" => { type: :array, item_schema: PRD_BOOTSTRAP_MODULE_SCHEMA },
              "prd_focus" => { type: :array, item_schema: { type: :string } },
              "reviewer_focus" => { type: :array, item_schema: { type: :string } },
              "notes" => { type: :array, item_schema: { type: :string } },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "plan_confirmed" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "change_request" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "change_request" },
          "version" => { type: :string, equals: "1.0.2" },
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
        if schema[:min_items] && value.length < schema[:min_items]
          errors << "#{label} must contain at least #{schema[:min_items]} items"
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
      when "baseline"
        ensure_ready_flag_matches(errors, data, %w[decision baseline_confirmed], "decision.baseline_confirmed")
        block_on_required_confirmation_items(errors, data["confirmation_items"], dig(data, %w[decision baseline_confirmed]), "decision.baseline_confirmed")
        validate_confirmation_items_collection(data["confirmation_items"], errors, prefix: "confirmation_items")
        validate_baseline_field_source_completeness(data, errors)
      when "design_seed"
        ensure_ready_flag_matches(errors, data, %w[decision seed_ready], "decision.seed_ready")
        validate_design_seed_content(data, errors)
      when "bootstrap_plan"
        ensure_ready_flag_matches(errors, data, %w[decision plan_confirmed], "decision.plan_confirmed")
        validate_bootstrap_plan_content(data, errors)
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
        validate_profile_stage_confirmation_items(stage, errors)
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

      all_required_items = ordered_stages.flat_map { |stage| Array(stage["confirmation_items"]).select { |item| item["level"] == "required" } }
      if all_required_items.any?
        errors << "decision.allow_baseline must be false when any stage has level=required confirmation_items" if dig(data, %w[decision allow_baseline]) != false
        errors << "status.ready_for_next must be false when any stage has level=required confirmation_items" if dig(data, %w[status ready_for_next]) != false
        errors << "stage_progress.profile_ready must be false when any stage has level=required confirmation_items" if dig(data, %w[stage_progress profile_ready]) != false
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

    def validate_profile_stage_content(stage, current_stage, errors)
      stage_id = stage["stage_id"]
      status = stage["status"]
      has_summary = !stage["summary"].to_s.strip.empty?
      has_prefilled_confirmation_items = Array(stage["confirmation_items"]).any? { |item| confirmation_item_has_content?(item) }
      has_extra_confirmation_items = extra_confirmation_items(stage).any?

      if status == "pending"
        if has_summary || has_prefilled_confirmation_items || has_extra_confirmation_items
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

    def validate_profile_stage_confirmation_items(stage, errors)
      stage_id = stage["stage_id"]
      expected_ids = STAGE_REQUIRED_QUESTION_IDS.fetch(stage_id)
      items = Array(stage["confirmation_items"])
      actual_ids = items.map { |item| item["item_id"] }
      fixed_ids = actual_ids.take(expected_ids.length)

      unless fixed_ids == expected_ids
        errors << "stages.#{stage_id}.confirmation_items must start with the fixed item set and order"
      end

      if actual_ids.uniq.length != actual_ids.length
        errors << "stages.#{stage_id}.confirmation_items must not contain duplicate item_id"
      end

      items.each_with_index do |item, index|
        fixed = index < expected_ids.length
        validate_confirmation_item(item, errors, "stages.#{stage_id}.confirmation_items.#{index}", allow_blank: stage["status"] == "pending", fixed_item: fixed)
      end
    end

    def validate_confirmation_item(item, errors, prefix, allow_blank:, fixed_item: false)
      item_id = item["item_id"].to_s.strip
      answer_mode = item["answer_mode"].to_s
      options = Array(item["options"])
      recommended = item["recommended"].to_s.strip
      reason = item["reason"].to_s.strip
      default_if_no_answer = item["default_if_no_answer"].to_s.strip
      level = item["level"].to_s

      if fixed_item && item_id.empty?
        errors << "#{prefix}.item_id must not be empty"
      end

      unless %w[secondary primary required].include?(level)
        errors << "#{prefix}.level must be one of secondary, primary, required"
      end

      unless %w[single_choice multi_choice text].include?(answer_mode)
        errors << "#{prefix}.answer_mode must be one of single_choice, multi_choice, text"
      end

      if allow_blank && !confirmation_item_has_content?(item)
        return
      end

      errors << "#{prefix}.reason must not be empty" if reason.empty?

      if answer_mode == "text"
        errors << "#{prefix}.options must stay empty when answer_mode is text" if options.any?
        errors << "#{prefix}.default_if_no_answer should stay empty when answer_mode is text" unless default_if_no_answer.empty?
      else
        if options.length < 2
          errors << "#{prefix}.options should contain at least 2 items"
        elsif options.length > 5
          errors << "#{prefix}.options should contain at most 5 items; split the question if needed"
        end

        option_values = options.map { |option| option["value"] }
        unless recommended.empty?
          errors << "#{prefix}.recommended must match one of options.value" unless option_values.include?(recommended)
        end
        unless default_if_no_answer.empty?
          errors << "#{prefix}.default_if_no_answer must match one of options.value" unless option_values.include?(default_if_no_answer)
        end
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

    def validate_confirmation_items_collection(items, errors, prefix:)
      ids = Array(items).map { |item| item["item_id"] }
      if ids.uniq.length != ids.length
        errors << "#{prefix} must not contain duplicate item_id"
      end

      Array(items).each_with_index do |item, index|
        validate_confirmation_item(item, errors, "#{prefix}.#{index}", allow_blank: false)
      end
    end

    def block_on_required_confirmation_items(errors, items, value, label)
      return unless Array(items).any? { |item| item["level"] == "required" }
      errors << "#{label} must be false when confirmation_items contains level=required" if value != false
    end

    def extra_confirmation_items(stage)
      fixed_ids = STAGE_REQUIRED_QUESTION_IDS.fetch(stage["stage_id"])
      Array(stage["confirmation_items"]).drop(fixed_ids.length)
    end

    def confirmation_item_has_content?(item)
      present_value?(item["recommended"]) ||
        Array(item["options"]).any? ||
        present_value?(item["reason"]) ||
        present_value?(item["default_if_no_answer"])
    end

    def validate_design_seed_content(data, errors)
      color_roles = Array(dig(data, %w[token_baseline color_roles]))
      errors << "token_baseline.color_roles should contain at least 3 items" if color_roles.length < 3
      required_sections = %w[spacing_scale radius_scale shadow_scale typography_scale]
      required_sections.each do |section|
        items = Array(dig(data, ["token_baseline", section]))
        errors << "token_baseline.#{section} should contain at least 1 item" if items.empty?
      end
    end

    def validate_bootstrap_plan_content(data, errors)
      init_template = dig(data, %w[init_execution_scope output_artifacts template_path]).to_s.strip
      init_target = dig(data, %w[init_execution_scope output_artifacts target_path]).to_s.strip
      conditional_parameters = Array(dig(data, %w[init_execution_scope conditional_parameters]))
      preset_packs = Array(dig(data, %w[init_execution_scope preset_capability_packs]))
      command_blueprints = Array(dig(data, %w[init_execution_scope command_blueprints]))
      code_artifacts = Array(dig(data, %w[init_execution_scope code_artifacts]))
      ai_followups = Array(dig(data, %w[init_execution_scope ai_followups]))
      allowed_work = Array(dig(data, %w[init_execution_scope allowed_work]))
      excluded_work = Array(dig(data, %w[init_execution_scope excluded_work]))
      deliverables = Array(dig(data, %w[init_execution_scope deliverables]))
      completion_criteria = Array(dig(data, %w[init_execution_scope completion_criteria]))
      init_reviewer_focus = Array(dig(data, %w[init_execution_scope reviewer_focus]))
      output_template = dig(data, %w[project_conventions output_artifacts template_path]).to_s.strip
      output_target = dig(data, %w[project_conventions output_artifacts target_path]).to_s.strip
      generation_workflow = Array(dig(data, %w[project_conventions generation_workflow]))
      sections_to_fill = Array(dig(data, %w[project_conventions sections_to_fill]))
      reviewer_focus = Array(dig(data, %w[project_conventions reviewer_focus]))
      prd_template = dig(data, %w[prd_bootstrap_context output_artifacts template_path]).to_s.strip
      prd_target = dig(data, %w[prd_bootstrap_context output_artifacts target_path]).to_s.strip
      prd_generation_workflow = Array(dig(data, %w[prd_bootstrap_context generation_workflow]))
      document_goal = Array(dig(data, %w[prd_bootstrap_context document_goal]))
      project_overview = Array(dig(data, %w[prd_bootstrap_context project_overview]))
      confirmed_foundation = Array(dig(data, %w[prd_bootstrap_context confirmed_foundation]))
      priority_modules = Array(dig(data, %w[prd_bootstrap_context priority_modules]))
      prd_focus = Array(dig(data, %w[prd_bootstrap_context prd_focus]))
      prd_reviewer_focus = Array(dig(data, %w[prd_bootstrap_context reviewer_focus]))

      errors << "init_execution_scope.output_artifacts.template_path must not be empty" if init_template.empty?
      errors << "init_execution_scope.output_artifacts.target_path must not be empty" if init_target.empty?
      errors << "init_execution_scope.conditional_parameters should contain at least 1 item" if conditional_parameters.empty?
      errors << "init_execution_scope.preset_capability_packs should contain at least 1 item" if preset_packs.empty?
      errors << "init_execution_scope.command_blueprints should contain at least 1 item" if command_blueprints.empty?
      errors << "init_execution_scope.code_artifacts should contain at least 1 item" if code_artifacts.empty?
      errors << "init_execution_scope.ai_followups should contain at least 1 item" if ai_followups.empty?
      errors << "init_execution_scope.allowed_work should contain at least 1 item" if allowed_work.empty?
      errors << "init_execution_scope.excluded_work should contain at least 1 item" if excluded_work.empty?
      errors << "init_execution_scope.deliverables should contain at least 1 item" if deliverables.empty?
      errors << "init_execution_scope.completion_criteria should contain at least 1 item" if completion_criteria.empty?
      errors << "init_execution_scope.reviewer_focus should contain at least 1 item" if init_reviewer_focus.empty?
      errors << "project_conventions.output_artifacts.template_path must not be empty" if output_template.empty?
      errors << "project_conventions.output_artifacts.target_path must not be empty" if output_target.empty?
      errors << "project_conventions.generation_workflow should contain at least 1 item" if generation_workflow.empty?
      errors << "project_conventions.sections_to_fill should contain at least 1 item" if sections_to_fill.empty?
      errors << "project_conventions.reviewer_focus should contain at least 1 item" if reviewer_focus.empty?
      errors << "prd_bootstrap_context.output_artifacts.template_path must not be empty" if prd_template.empty?
      errors << "prd_bootstrap_context.output_artifacts.target_path must not be empty" if prd_target.empty?
      errors << "prd_bootstrap_context.generation_workflow should contain at least 1 item" if prd_generation_workflow.empty?
      errors << "prd_bootstrap_context.document_goal should contain at least 1 item" if document_goal.empty?
      errors << "prd_bootstrap_context.project_overview should contain at least 1 item" if project_overview.empty?
      errors << "prd_bootstrap_context.confirmed_foundation should contain at least 1 item" if confirmed_foundation.empty?
      errors << "prd_bootstrap_context.priority_modules should contain at least 1 item" if priority_modules.empty?
      errors << "prd_bootstrap_context.prd_focus should contain at least 1 item" if prd_focus.empty?
      errors << "prd_bootstrap_context.reviewer_focus should contain at least 1 item" if prd_reviewer_focus.empty?
    end

    def validate_cross_file_rules(artifact, data, artifact_path, errors)
      case artifact
      when "project_profile", "baseline", "design_seed", "bootstrap_plan", "change_request"
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
      elsif artifact == "design_seed"
        paths = validate_source_paths(data, artifact_path, errors)
        referenced = paths.map { |path| load_referenced_yaml(path) }.compact
        errors << "meta.source_paths must include at least one baseline artifact" unless referenced.any? { |ref| ref["artifact_type"] == "baseline" }
      elsif artifact == "bootstrap_plan"
        paths = validate_source_paths(data, artifact_path, errors)
        referenced = paths.map { |path| load_referenced_yaml(path) }.compact
        errors << "meta.source_paths must include at least one design_seed artifact" unless referenced.any? { |ref| ref["artifact_type"] == "design_seed" }
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

      allowed_source_types = %w[confirmation_item project_profile_field stage_summary]
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
      when "confirmation_item"
        item_ids = Array(stage["confirmation_items"]).map { |item| item["item_id"] }
        errors << "field_sources.#{label}.source_id must match a confirmation_items.item_id in stage #{stage_id}" unless item_ids.include?(source_id)
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
