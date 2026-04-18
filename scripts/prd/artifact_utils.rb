require "yaml"

module Prd
  module ArtifactUtils
    module_function

    ROOT = File.expand_path("../..", __dir__)

    ARTIFACT_TYPES = %w[clarification review brief decomposition].freeze
    REVIEWABLE_STEPS = %w[requirement_clarification prd_decomposition].freeze
    REVIEWABLE_SUBJECTS = {
      "requirement_clarification" => "clarification",
      "prd_decomposition" => "decomposition",
    }.freeze

    SCHEMAS = {
      "clarification" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "clarification" },
          "version" => { type: :string, equals: "1.0" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "requirement_clarification" },
              "attempt" => { type: :integer, min: 1, max_from: %w[status max_retry], offset: 1 },
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
          "confirmed" => {
            type: :hash,
            keys: {
              "product_type" => { type: :string },
              "target_users" => { type: :array },
              "primary_platforms" => { type: :array },
              "in_scope" => { type: :array },
              "out_of_scope" => { type: :array },
            },
          },
          "gaps" => {
            type: :hash,
            keys: {
              "p0" => { type: :array },
              "p1" => { type: :array },
              "p2" => { type: :array },
            },
          },
          "questions" => {
            type: :hash,
            keys: {
              "business_goal" => { type: :array },
              "role_and_tenant" => { type: :array },
              "resources" => { type: :array },
              "workflows" => { type: :array },
              "states_and_rules" => { type: :array },
              "frontend_backend_split" => { type: :array },
            },
          },
          "decision_candidates" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "topic" => { type: :string, non_empty: true },
                "question" => { type: :string, non_empty: true },
                "explanation" => { type: :string },
                "recommended" => { type: :string, non_empty: true },
                "options" => {
                  type: :array,
                  item_schema: {
                    type: :hash,
                    keys: {
                      "value" => { type: :string, non_empty: true },
                      "label" => { type: :string, non_empty: true },
                      "description" => { type: :string },
                    },
                  },
                },
                "allow_multiple" => { type: :boolean },
                "default_if_no_answer" => { type: :string },
                "must_confirm" => { type: :boolean },
              },
            },
          },
          "proposed_defaults" => {
            type: :array,
            item_schema: {
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
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "allowed_to_write_brief" => { type: :boolean },
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
              "attempt" => { type: :integer, min: 1, max_from: %w[status max_retry], offset: 1 },
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
          "findings" => {
            type: :hash,
            keys: {
              "issues" => { type: :array },
              "missing_info" => { type: :array },
              "p0" => { type: :array },
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
          "required_revisions" => { type: :array },
          "notes" => { type: :array },
        },
      },
      "brief" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "brief" },
          "version" => { type: :string, equals: "1.0" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "clarified_brief" },
              "attempt" => { type: :integer, min: 1, max_from: %w[status max_retry], offset: 1 },
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
          "summary" => {
            type: :hash,
            keys: {
              "system" => { type: :string, non_empty: true },
              "target_users" => { type: :array },
              "current_goal" => { type: :array },
              "why_now" => { type: :string },
            },
          },
          "scope" => {
            type: :hash,
            keys: {
              "clients" => { type: :array },
              "modules_in_scope" => { type: :array },
              "modules_out_of_scope" => { type: :array },
              "collaboration_constraints" => { type: :array },
            },
          },
          "roles" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "name" => { type: :string, non_empty: true },
                "client" => { type: :string },
                "main_goal" => { type: :string },
                "visible_scope" => { type: :array, item_schema: { type: :string } },
                "permission_notes" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "core_flows" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "name" => { type: :string, non_empty: true },
                "start" => { type: :string },
                "key_steps" => { type: :array, item_schema: { type: :string } },
                "end" => { type: :string },
                "is_async" => { type: :boolean },
                "need_review" => { type: :boolean },
              },
            },
          },
          "core_resources" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "name" => { type: :string, non_empty: true },
                "resource_type" => { type: :string },
                "purpose" => { type: :string },
                "owner" => { type: :string },
                "key_fields" => { type: :array, item_schema: { type: :string } },
                "known_states" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "mvp" => {
            type: :hash,
            keys: {
              "must_have" => { type: :array },
              "should_have" => { type: :array },
              "not_now" => { type: :array },
            },
          },
          "constraints" => {
            type: :hash,
            keys: {
              "multi_tenant" => { type: :string },
              "permissions" => { type: :string },
              "billing" => { type: :string },
              "non_functional" => { type: :array },
              "collaboration_mode" => { type: :string },
            },
          },
          "decision_candidates" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "topic" => { type: :string, non_empty: true },
                "question" => { type: :string, non_empty: true },
                "explanation" => { type: :string },
                "recommended" => { type: :string, non_empty: true },
                "options" => {
                  type: :array,
                  item_schema: {
                    type: :hash,
                    keys: {
                      "value" => { type: :string, non_empty: true },
                      "label" => { type: :string, non_empty: true },
                      "description" => { type: :string },
                    },
                  },
                },
                "allow_multiple" => { type: :boolean },
                "default_if_no_answer" => { type: :string },
                "must_confirm" => { type: :boolean },
              },
            },
          },
          "proposed_defaults" => {
            type: :array,
            item_schema: {
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
            },
          },
          "open_questions" => {
            type: :hash,
            keys: {
              "p0" => { type: :array },
              "p1" => { type: :array },
              "p2" => { type: :array },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "allow_decomposition" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "decomposition" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "decomposition" },
          "version" => { type: :string, equals: "1.0" },
          "status" => {
            type: :hash,
            keys: {
              "step" => { type: :string, equals: "prd_decomposition" },
              "attempt" => { type: :integer, min: 1, max_from: %w[status max_retry], offset: 1 },
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
          "modules" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "name" => { type: :string, non_empty: true },
                "target_users" => { type: :array, item_schema: { type: :string } },
                "responsibilities" => { type: :array, item_schema: { type: :string } },
                "in_mvp" => { type: :boolean },
              },
            },
          },
          "pages" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "client" => { type: :string },
                "module" => { type: :string },
                "name" => { type: :string, non_empty: true },
                "page_type" => { type: :string },
                "goal" => { type: :string },
                "primary_actions" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "roles" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "name" => { type: :string, non_empty: true },
                "client" => { type: :string },
                "main_goal" => { type: :string },
                "visible_scope" => { type: :array, item_schema: { type: :string } },
                "permission_notes" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "resources" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "name" => { type: :string, non_empty: true },
                "resource_type" => { type: :string },
                "purpose" => { type: :string },
                "owner" => { type: :string },
                "key_attributes" => { type: :array, item_schema: { type: :string } },
                "known_states" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "flows" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "name" => { type: :string, non_empty: true },
                "trigger" => { type: :string },
                "start" => { type: :string },
                "key_steps" => { type: :array, item_schema: { type: :string } },
                "end" => { type: :string },
                "is_async" => { type: :boolean },
                "need_review" => { type: :boolean },
              },
            },
          },
          "states" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "resource_name" => { type: :string, non_empty: true },
                "current_states" => { type: :array, item_schema: { type: :string } },
                "evidence" => { type: :array, item_schema: { type: :string } },
                "missing_states" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "observations" => {
            type: :hash,
            keys: {
              "permissions" => { type: :array },
              "tenant_boundaries" => { type: :array },
              "missing_boundaries" => { type: :array },
            },
          },
          "open_questions" => {
            type: :hash,
            keys: {
              "p0" => { type: :array },
              "p1" => { type: :array },
              "p2" => { type: :array },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "allow_contract_design" => { type: :boolean },
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
      path_label = path.empty? ? "<root>" : path.join(".")

      case schema[:type]
      when :hash
        unless value.is_a?(Hash)
          errors << "#{path_label} must be an object"
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
          errors << "#{path_label} must be an array"
          return
        end
        return unless schema[:item_schema]

        value.each_with_index do |item, index|
          validate_node(item, schema[:item_schema], path + [index.to_s], errors)
        end
      when :string
        unless value.is_a?(String)
          errors << "#{path_label} must be a string"
          return
        end
        errors << "#{path_label} must not be empty" if schema[:non_empty] && value.strip.empty?
        errors << "#{path_label} must equal #{schema[:equals].inspect}" if schema[:equals] && value != schema[:equals]
        if schema[:enum] && !schema[:enum].include?(value)
          errors << "#{path_label} must be one of: #{schema[:enum].join(', ')}"
        end
      when :integer
        unless value.is_a?(Integer)
          errors << "#{path_label} must be an integer"
          return
        end
        errors << "#{path_label} must be >= #{schema[:min]}" if schema[:min] && value < schema[:min]
        errors << "#{path_label} must equal #{schema[:equals]}" if schema[:equals] && value != schema[:equals]
      when :boolean
        errors << "#{path_label} must be a boolean" unless value == true || value == false
      else
        errors << "#{path_label} has unsupported schema type #{schema[:type].inspect}"
      end
    end

    def validate_state_rules(artifact, data, errors)
      attempt = dig(data, %w[status attempt])
      max_retry = dig(data, %w[status max_retry])
      allowed_max = max_retry.to_i + 1
      if attempt.to_i > allowed_max
        errors << "status.attempt exceeds allowed retry window (max #{allowed_max})"
      end

      case artifact
      when "clarification"
        ensure_ready_flag_matches(errors, data, %w[decision allowed_to_write_brief], "decision.allowed_to_write_brief")
        block_on_p0(errors, data, %w[gaps p0], %w[decision allowed_to_write_brief], "decision.allowed_to_write_brief")
        validate_candidate_consistency(data, errors)
      when "brief"
        ensure_ready_flag_matches(errors, data, %w[decision allow_decomposition], "decision.allow_decomposition")
        block_on_p0(errors, data, %w[open_questions p0], %w[decision allow_decomposition], "decision.allow_decomposition")
        validate_candidate_consistency(data, errors)
      when "decomposition"
        ensure_ready_flag_matches(errors, data, %w[decision allow_contract_design], "decision.allow_contract_design")
        block_on_p0(errors, data, %w[open_questions p0], %w[decision allow_contract_design], "decision.allow_contract_design")
      when "review"
        has_blocking = dig(data, %w[decision has_blocking_issue])
        allow_next = dig(data, %w[decision allow_next_step])
        escalation = dig(data, %w[decision need_human_escalation])
        p0 = Array(dig(data, %w[findings p0]))
        step = dig(data, %w[status step])
        subject_type = dig(data, %w[meta subject_type])

        if !p0.empty? && has_blocking != true
          errors << "decision.has_blocking_issue must be true when findings.p0 is not empty"
        end
        if has_blocking == true && allow_next == true
          errors << "decision.allow_next_step cannot be true when decision.has_blocking_issue is true"
        end
        if escalation == true && allow_next == true
          errors << "decision.allow_next_step cannot be true when decision.need_human_escalation is true"
        end
        if attempt.to_i > max_retry.to_i && has_blocking == true && escalation != true
          errors << "decision.need_human_escalation must be true after retry limit is exceeded with blocking issues"
        end
        if escalation == true && has_blocking != true
          errors << "decision.has_blocking_issue must be true when decision.need_human_escalation is true"
        end
        expected_subject = REVIEWABLE_SUBJECTS[step]
        if expected_subject && subject_type != expected_subject
          errors << "meta.subject_type must be #{expected_subject.inspect} when status.step is #{step.inspect}"
        end
      end
    end

    def validate_cross_file_rules(artifact, data, artifact_path, errors)
      case artifact
      when "clarification"
        validate_source_paths(data, artifact_path, errors)
      when "brief"
        paths = validate_source_paths(data, artifact_path, errors)
        ensure_referenced_artifact_type(paths, artifact_path, "clarification", "meta.source_paths", errors)
      when "decomposition"
        paths = validate_source_paths(data, artifact_path, errors)
        ensure_referenced_artifact_type(paths, artifact_path, "brief", "meta.source_paths", errors)
      when "review"
        validate_review_subject(data, artifact_path, errors)
      end
    end

    def validate_candidate_consistency(data, errors)
      Array(data["decision_candidates"]).each_with_index do |candidate, index|
        options = Array(candidate["options"])
        recommended = candidate["recommended"]
        default_if_no_answer = candidate["default_if_no_answer"]
        option_values = options.map { |option| option["value"] }

        unless option_values.include?(recommended)
          errors << "decision_candidates.#{index}.recommended must match one of options.value"
        end

        if candidate["must_confirm"] == false && !default_if_no_answer.to_s.strip.empty? && !option_values.include?(default_if_no_answer)
          errors << "decision_candidates.#{index}.default_if_no_answer must match one of options.value when provided"
        end
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

    def ensure_referenced_artifact_type(paths, artifact_path, expected_type, label, errors)
      referenced = paths.map { |path| load_referenced_yaml(path) }.compact
      return if referenced.any? { |ref| ref["artifact_type"] == expected_type }

      errors << "#{label} must include at least one #{expected_type} artifact"
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

      subject_type = dig(data, %w[meta subject_type])
      review_step = dig(data, %w[status step])
      expected_subject_type = REVIEWABLE_SUBJECTS[review_step]
      actual_type = subject["artifact_type"]
      actual_step = dig(subject, %w[status step])

      if actual_type != subject_type
        errors << "meta.subject_type=#{subject_type.inspect} does not match subject artifact_type=#{actual_type.inspect}"
      end
      if expected_subject_type && actual_type != expected_subject_type
        errors << "meta.subject_path must point to a #{expected_subject_type.inspect} artifact when status.step is #{review_step.inspect}"
      end
      if actual_step != review_step
        errors << "subject status.step=#{actual_step.inspect} does not match review status.step=#{review_step.inspect}"
      end
    end

    def ensure_ready_flag_matches(errors, data, decision_path, decision_label)
      ready = dig(data, %w[status ready_for_next])
      decision = dig(data, decision_path)
      return if ready == decision

      errors << "status.ready_for_next must match #{decision_label}"
    end

    def block_on_p0(errors, data, p0_path, decision_path, decision_label)
      p0 = Array(dig(data, p0_path))
      decision = dig(data, decision_path)
      ready = dig(data, %w[status ready_for_next])

      return if p0.empty?

      errors << "#{decision_label} must be false when #{p0_path.join('.')} is not empty" if decision != false
      errors << "status.ready_for_next must be false when #{p0_path.join('.')} is not empty" if ready != false
    end

    def dig(data, keys)
      keys.reduce(data) do |value, key|
        value.is_a?(Hash) ? value[key] : nil
      end
    end

    def load_referenced_yaml(path)
      load_yaml(path)
    rescue ArgumentError
      nil
    end

    def resolve_existing_path(raw_path, artifact_path)
      return nil unless raw_path.is_a?(String) && !raw_path.strip.empty?

      candidates = []
      candidates << raw_path if File.absolute_path(raw_path) == raw_path rescue false
      candidates << File.expand_path(raw_path, File.dirname(artifact_path))
      candidates << File.expand_path(raw_path, ROOT)

      candidates.uniq.find { |candidate| File.exist?(candidate) }
    end

    def join_path(path, key)
      (path + [key]).join(".")
    end
  end
end
