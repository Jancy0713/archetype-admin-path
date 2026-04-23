require "yaml"

module Prd
  module ArtifactUtils
    module_function

    ROOT = File.expand_path("../..", __dir__)

    ARTIFACT_TYPES = %w[analysis clarification execution_plan final_prd review].freeze
    REVIEWABLE_STEPS = %w[prd_analysis prd_clarification prd_execution_plan final_prd_ready].freeze
    ARTIFACT_VERSIONS = %w[2.0.0 2.1.0].freeze
    REVIEWABLE_SUBJECTS = {
      "prd_analysis" => "analysis",
      "prd_clarification" => "clarification",
      "prd_execution_plan" => "execution_plan",
      "final_prd_ready" => "final_prd",
    }.freeze
    ARTIFACT_STEP_IDS = {
      "analysis" => "prd-01",
      "clarification" => "prd-02",
      "execution_plan" => "prd-03",
      "final_prd" => "prd-04",
    }.freeze
    STEP_PROMPT_PATHS = {
      "analysis" => "docs/prd/prompts/analysis/STEP_PROMPT.md",
      "clarification" => "docs/prd/prompts/clarification/STEP_PROMPT.md",
      "execution_plan" => "docs/prd/prompts/execution_plan/STEP_PROMPT.md",
      "final_prd" => "docs/prd/prompts/final_prd/STEP_PROMPT.md",
    }.freeze
    RULE_PATHS = {
      "analysis" => "docs/prd/rules/ANALYSIS_RULE.md",
      "clarification" => "docs/prd/rules/REQUIREMENT_CLARIFICATION_RULE.md",
      "execution_plan" => "docs/prd/rules/EXECUTION_PLAN_RULE.md",
      "final_prd" => "docs/prd/rules/FINAL_PRD_RULE.md",
      "review" => "docs/prd/rules/REVIEWER_RULE.md",
    }.freeze
    TEMPLATE_PATHS = {
      "analysis" => "docs/prd/templates/structured/analysis.template.yaml",
      "clarification" => "docs/prd/templates/structured/clarification.template.yaml",
      "execution_plan" => "docs/prd/templates/structured/execution_plan.template.yaml",
      "final_prd" => "docs/prd/templates/structured/final_prd.template.yaml",
      "review" => "docs/prd/templates/structured/review.template.yaml",
    }.freeze
    REVIEWER_CHECKLIST_PATHS = {
      "prd_analysis" => "docs/prd/reviewer/checklists/prd_analysis.md",
      "prd_clarification" => "docs/prd/reviewer/checklists/prd_clarification.md",
      "prd_execution_plan" => "docs/prd/reviewer/checklists/prd_execution_plan.md",
      "final_prd_ready" => "docs/prd/reviewer/checklists/final_prd_ready.md",
    }.freeze
    SKILL_REFERENCE_PATHS = {
      "analysis" => [
        "docs/prd/references/TO_PRD_SKILL_ADAPTER.md",
        "/Users/wangwenjie/.agents/skills/to-prd/SKILL.md",
      ],
      "clarification" => [
        "docs/prd/references/GRILL_ME_SKILL_ADAPTER.md",
        "/Users/wangwenjie/.agents/skills/grill-me/SKILL.md",
      ],
      "execution_plan" => [
        "docs/prd/references/TO_PRD_SKILL_ADAPTER.md",
        "/Users/wangwenjie/.agents/skills/to-prd/SKILL.md",
      ],
      "final_prd" => [
        "docs/prd/references/TO_ISSUES_SKILL_ADAPTER.md",
        "/Users/wangwenjie/.agents/skills/to-issues/SKILL.md",
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

    CONFIRMATION_ITEM_SCHEMA = {
      type: :hash,
      keys: {
        "item_id" => { type: :string, non_empty: true },
        "question" => { type: :string, non_empty: true },
        "level" => { type: :string, enum: %w[secondary primary required] },
        "answer_mode" => { type: :string, enum: %w[boolean single_choice multiple_choice open_text] },
        "recommended" => { type: :string },
        "options" => { type: :array, item_schema: OPTION_SCHEMA },
        "reason" => { type: :string },
        "allow_custom_answer" => { type: :boolean },
        "default_if_no_answer" => { type: :string },
      },
    }.freeze

    COMMON_META_SCHEMA = {
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
    }.freeze

    COMMON_STATUS_SCHEMA = lambda do |step_name|
      {
        type: :hash,
        keys: {
          "step" => { type: :string, equals: step_name },
          "attempt" => { type: :integer, min: 1, max_from: %w[status max_retry], offset: 1 },
          "max_retry" => { type: :integer, equals: 2 },
          "ready_for_next" => { type: :boolean },
        },
      }
    end

    STRING_ARRAY_SCHEMA = { type: :array, item_schema: { type: :string } }.freeze

    CONTRACT_HANDOFF_SCHEMA = {
      type: :hash,
      keys: {
        "contract_scope" => STRING_ARRAY_SCHEMA,
        "priority_modules" => STRING_ARRAY_SCHEMA,
        "required_contract_views" => STRING_ARRAY_SCHEMA,
        "do_not_assume" => STRING_ARRAY_SCHEMA,
      },
    }.freeze

    PRD_BATCH_SCHEMA = {
      type: :hash,
      keys: {
        "batch_id" => { type: :string, non_empty: true },
        "title" => { type: :string, non_empty: true },
        "goal" => { type: :string, non_empty: true },
        "summary" => STRING_ARRAY_SCHEMA,
        "grouped_modules" => STRING_ARRAY_SCHEMA,
        "dependency_batches" => STRING_ARRAY_SCHEMA,
        "grouping_reason" => STRING_ARRAY_SCHEMA,
        "in_scope_pages" => STRING_ARRAY_SCHEMA,
        "key_resources" => STRING_ARRAY_SCHEMA,
        "key_flows" => STRING_ARRAY_SCHEMA,
        "size_control" => {
          type: :hash,
          keys: {
            "target_contract_size" => { type: :string, non_empty: true },
            "keep_together" => STRING_ARRAY_SCHEMA,
            "split_triggers" => STRING_ARRAY_SCHEMA,
          },
        },
        "contract_constraints" => STRING_ARRAY_SCHEMA,
        "contract_handoff" => CONTRACT_HANDOFF_SCHEMA,
        "decision" => {
          type: :hash,
          keys: {
            "allow_contract_design" => { type: :boolean },
            "reason" => { type: :string, non_empty: true },
          },
        },
      },
    }.freeze

    SCHEMAS = {
      "analysis" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "analysis" },
          "version" => { type: :string, enum: ARTIFACT_VERSIONS },
          "status" => COMMON_STATUS_SCHEMA.call("prd_analysis"),
          "meta" => COMMON_META_SCHEMA,
          "input_summary" => {
            type: :hash,
            keys: {
              "request_summary" => { type: :string, non_empty: true },
              "project_context" => { type: :array, item_schema: { type: :string } },
              "inherited_constraints" => { type: :array, item_schema: { type: :string } },
              "assumptions_adopted" => { type: :array, item_schema: { type: :string } },
            },
          },
          "scope_analysis" => {
            type: :hash,
            keys: {
              "business_goal" => { type: :array, item_schema: { type: :string } },
              "success_criteria" => { type: :array, item_schema: { type: :string } },
              "modules_in_scope" => { type: :array, item_schema: { type: :string } },
              "modules_out_of_scope" => { type: :array, item_schema: { type: :string } },
              "execution_boundary" => { type: :array, item_schema: { type: :string } },
            },
          },
          "domain_breakdown" => {
            type: :hash,
            keys: {
              "modules" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "module_id" => { type: :string, non_empty: true },
                    "name" => { type: :string, non_empty: true },
                    "objective" => { type: :string },
                    "priority" => { type: :string },
                    "dependencies" => { type: :array, item_schema: { type: :string } },
                    "notes" => { type: :array, item_schema: { type: :string } },
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
                    "goal" => { type: :string },
                    "priority" => { type: :string },
                  },
                },
              },
              "resources" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "name" => { type: :string, non_empty: true },
                    "purpose" => { type: :string },
                    "owner" => { type: :string },
                    "priority" => { type: :string },
                    "notes" => { type: :array, item_schema: { type: :string } },
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
                    "outcome" => { type: :string },
                    "priority" => { type: :string },
                    "notes" => { type: :array, item_schema: { type: :string } },
                  },
                },
              },
            },
          },
          "risk_analysis" => {
            type: :hash,
            keys: {
              "confirmed" => { type: :array, item_schema: { type: :string } },
              "unclear" => { type: :array, item_schema: { type: :string } },
              "risks" => { type: :array, item_schema: { type: :string } },
              "blocking_gaps" => {
                type: :hash,
                keys: {
                  "p0" => { type: :array, item_schema: { type: :string } },
                  "p1" => { type: :array, item_schema: { type: :string } },
                  "p2" => { type: :array, item_schema: { type: :string } },
                },
              },
            },
          },
          "clarification_candidates" => {
            type: :hash,
            keys: {
              "confirmation_items" => { type: :array, item_schema: CONFIRMATION_ITEM_SCHEMA },
            },
          },
          "handoff" => {
            type: :hash,
            keys: {
              "recommended_next_step" => { type: :string, equals: "clarification" },
              "ready_for_clarification" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "clarification" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "clarification" },
          "version" => { type: :string, enum: ARTIFACT_VERSIONS },
          "status" => COMMON_STATUS_SCHEMA.call("prd_clarification"),
          "meta" => COMMON_META_SCHEMA,
          "clarification_context" => {
            type: :hash,
            keys: {
              "scope_summary" => { type: :array, item_schema: { type: :string } },
              "inherited_constraints" => { type: :array, item_schema: { type: :string } },
              "fixed_assumptions" => { type: :array, item_schema: { type: :string } },
              "excluded_topics" => { type: :array, item_schema: { type: :string } },
            },
          },
          "confirmation_items" => { type: :array, item_schema: CONFIRMATION_ITEM_SCHEMA },
          "applied_defaults" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "topic" => { type: :string, non_empty: true },
                "adopted_value" => { type: :string, non_empty: true },
                "rationale" => { type: :string, non_empty: true },
                "upgrade_condition" => { type: :string },
              },
            },
          },
          "clarified_decisions" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "item_id" => { type: :string },
                "topic" => { type: :string, non_empty: true },
                "decision" => { type: :string, non_empty: true },
                "source" => { type: :string, non_empty: true },
                "impact" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "human_confirmation" => {
            type: :hash,
            keys: {
              "required" => { type: :boolean },
              "confirmed" => { type: :boolean },
              "summary" => { type: :string },
              "confirmed_by" => { type: :string },
              "confirmed_at" => { type: :string },
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "allow_execution_plan" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "execution_plan" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "execution_plan" },
          "version" => { type: :string, enum: ARTIFACT_VERSIONS },
          "status" => COMMON_STATUS_SCHEMA.call("prd_execution_plan"),
          "meta" => COMMON_META_SCHEMA,
          "planning_basis" => {
            type: :hash,
            keys: {
              "scope_summary" => { type: :array, item_schema: { type: :string } },
              "confirmed_constraints" => { type: :array, item_schema: { type: :string } },
              "contract_assumptions" => { type: :array, item_schema: { type: :string } },
            },
          },
          "delivery_strategy" => {
            type: :hash,
            keys: {
              "sequencing_principles" => { type: :array, item_schema: { type: :string } },
              "phase_boundaries" => { type: :array, item_schema: { type: :string } },
            },
          },
          "workstreams" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "workstream_id" => { type: :string, non_empty: true },
                "name" => { type: :string, non_empty: true },
                "objective" => { type: :string },
                "depends_on" => { type: :array, item_schema: { type: :string } },
                "can_run_in_parallel" => { type: :boolean },
                "outputs" => { type: :array, item_schema: { type: :string } },
              },
            },
          },
          "plan_steps" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "step_order" => { type: :integer, min: 1 },
                "name" => { type: :string, non_empty: true },
                "goal" => { type: :string },
                "inputs" => { type: :array, item_schema: { type: :string } },
                "outputs" => { type: :array, item_schema: { type: :string } },
                "dependencies" => { type: :array, item_schema: { type: :string } },
                "handoff_to" => { type: :string },
              },
            },
          },
          "contract_priorities" => {
            type: :array,
            item_schema: {
              type: :hash,
              keys: {
                "module" => { type: :string, non_empty: true },
                "priority" => { type: :string, non_empty: true },
                "reason" => { type: :string, non_empty: true },
                "required_inputs" => STRING_ARRAY_SCHEMA,
                "not_in_scope_for_now" => STRING_ARRAY_SCHEMA,
              },
            },
          },
          "batching_strategy" => {
            type: :hash,
            keys: {
              "principles" => STRING_ARRAY_SCHEMA,
              "batches" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "batch_id" => { type: :string, non_empty: true },
                    "title" => { type: :string, non_empty: true },
                    "goal" => { type: :string, non_empty: true },
                    "included_modules" => STRING_ARRAY_SCHEMA,
                    "depends_on_batches" => STRING_ARRAY_SCHEMA,
                    "contract_views" => STRING_ARRAY_SCHEMA,
                    "handoff_to" => { type: :string, non_empty: true },
                  },
                },
              },
              "batch_order" => STRING_ARRAY_SCHEMA,
            },
          },
          "risks_and_watchpoints" => {
            type: :hash,
            keys: {
              "blockers" => STRING_ARRAY_SCHEMA,
              "coordination_notes" => STRING_ARRAY_SCHEMA,
              "followup_watchpoints" => STRING_ARRAY_SCHEMA,
            },
          },
          "decision" => {
            type: :hash,
            keys: {
              "allow_final_prd" => { type: :boolean },
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "final_prd" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "final_prd" },
          "version" => { type: :string, enum: ARTIFACT_VERSIONS },
          "status" => COMMON_STATUS_SCHEMA.call("final_prd_ready"),
          "meta" => COMMON_META_SCHEMA,
          "overview" => {
            type: :hash,
            keys: {
              "product_summary" => { type: :string, non_empty: true },
              "current_goal" => STRING_ARRAY_SCHEMA,
              "success_criteria" => STRING_ARRAY_SCHEMA,
              "collaboration_mode" => { type: :string },
            },
          },
          "scope" => {
            type: :hash,
            keys: {
              "modules_in_scope" => STRING_ARRAY_SCHEMA,
              "modules_out_of_scope" => STRING_ARRAY_SCHEMA,
              "rollout_boundary" => STRING_ARRAY_SCHEMA,
            },
          },
          "roles_and_permissions" => {
            type: :hash,
            keys: {
              "roles" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "name" => { type: :string, non_empty: true },
                    "client" => { type: :string },
                    "main_goal" => { type: :string },
                    "visible_scope" => STRING_ARRAY_SCHEMA,
                    "permission_notes" => STRING_ARRAY_SCHEMA,
                  },
                },
              },
              "tenant_boundary" => STRING_ARRAY_SCHEMA,
            },
          },
          "domain_model" => {
            type: :hash,
            keys: {
              "resources" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "name" => { type: :string, non_empty: true },
                    "resource_type" => { type: :string },
                    "purpose" => { type: :string },
                    "owner" => { type: :string },
                    "key_attributes" => STRING_ARRAY_SCHEMA,
                    "known_states" => STRING_ARRAY_SCHEMA,
                  },
                },
              },
            },
          },
          "experience_design" => {
            type: :hash,
            keys: {
              "modules" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "name" => { type: :string, non_empty: true },
                    "objective" => { type: :string },
                    "in_scope_pages" => STRING_ARRAY_SCHEMA,
                    "key_actions" => STRING_ARRAY_SCHEMA,
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
                    "primary_actions" => STRING_ARRAY_SCHEMA,
                  },
                },
              },
            },
          },
          "workflow_design" => {
            type: :hash,
            keys: {
              "flows" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "name" => { type: :string, non_empty: true },
                    "trigger" => { type: :string },
                    "start" => { type: :string },
                    "key_steps" => STRING_ARRAY_SCHEMA,
                    "end" => { type: :string },
                    "is_async" => { type: :boolean },
                  },
                },
              },
              "states" => {
                type: :array,
                item_schema: {
                  type: :hash,
                  keys: {
                    "resource_name" => { type: :string, non_empty: true },
                    "current_states" => STRING_ARRAY_SCHEMA,
                    "missing_states" => STRING_ARRAY_SCHEMA,
                  },
                },
              },
            },
          },
          "constraints" => {
            type: :hash,
            keys: {
              "non_functional" => STRING_ARRAY_SCHEMA,
              "external_dependencies" => STRING_ARRAY_SCHEMA,
              "contract_constraints" => STRING_ARRAY_SCHEMA,
            },
          },
          "blocking_questions" => {
            type: :hash,
            keys: {
              "p0" => STRING_ARRAY_SCHEMA,
            },
          },
          "contract_execution" => {
            type: :hash,
            keys: {
              "recommended_batch_order" => STRING_ARRAY_SCHEMA,
              "parallel_batches" => STRING_ARRAY_SCHEMA,
              "selection_guidance" => STRING_ARRAY_SCHEMA,
            },
          },
          "prd_batches" => { type: :array, item_schema: PRD_BATCH_SCHEMA },
          "decision" => {
            type: :hash,
            keys: {
              "allow_contract_design" => { type: :boolean },
              "ready_batches" => STRING_ARRAY_SCHEMA,
              "blocked_batches" => STRING_ARRAY_SCHEMA,
              "reason" => { type: :string, non_empty: true },
            },
          },
        },
      },
      "review" => {
        type: :hash,
        keys: {
          "artifact_type" => { type: :string, equals: "review" },
          "version" => { type: :string, enum: ARTIFACT_VERSIONS },
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
    }.freeze

    def load_yaml(path)
      YAML.safe_load(File.read(path), permitted_classes: [], aliases: false)
    rescue Psych::SyntaxError => e
      raise ArgumentError, "Invalid YAML syntax: #{e.message}"
    end

    def artifact_materials(artifact)
      return nil unless ARTIFACT_TYPES.include?(artifact)

      {
        "artifact" => artifact,
        "step_id" => ARTIFACT_STEP_IDS[artifact],
        "step_prompt" => expand_repo_path(STEP_PROMPT_PATHS[artifact]),
        "rule" => expand_repo_path(RULE_PATHS[artifact]),
        "template" => expand_repo_path(TEMPLATE_PATHS[artifact]),
        "optional_references" => Array(SKILL_REFERENCE_PATHS[artifact]).map { |path| expand_repo_path(path) || path },
      }
    end

    def review_materials(step)
      return nil unless REVIEWABLE_STEPS.include?(step)

      {
        "review_step" => step,
        "subject_type" => REVIEWABLE_SUBJECTS[step],
        "reviewer_workflow" => expand_repo_path("docs/prd/reviewer/common/REVIEWER_WORKFLOW.md"),
        "reviewer_rule" => expand_repo_path(RULE_PATHS["review"]),
        "review_template" => expand_repo_path(TEMPLATE_PATHS["review"]),
        "reviewer_checklist" => expand_repo_path(REVIEWER_CHECKLIST_PATHS[step]),
      }
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
      attempt = dig(data, %w[status attempt]).to_i
      max_retry = dig(data, %w[status max_retry]).to_i
      allowed_max = max_retry + 1
      errors << "status.attempt exceeds allowed retry window (max #{allowed_max})" if attempt > allowed_max

      case artifact
      when "analysis"
        ensure_ready_flag_matches(errors, data, %w[handoff ready_for_clarification], "handoff.ready_for_clarification")
        block_on_p0(errors, data, %w[risk_analysis blocking_gaps p0], %w[handoff ready_for_clarification], "handoff.ready_for_clarification")
        validate_confirmation_items(data.dig("clarification_candidates", "confirmation_items"), errors, "clarification_candidates.confirmation_items", expected_step_id: ARTIFACT_STEP_IDS["analysis"])
      when "clarification"
        ensure_ready_flag_matches(errors, data, %w[decision allow_execution_plan], "decision.allow_execution_plan")
        validate_confirmation_items(data["confirmation_items"], errors, "confirmation_items", expected_step_id: ARTIFACT_STEP_IDS["clarification"])
        confirmation_required = dig(data, %w[human_confirmation required])
        confirmation_done = dig(data, %w[human_confirmation confirmed])
        allow_execution = dig(data, %w[decision allow_execution_plan])
        ready = dig(data, %w[status ready_for_next])
        validate_clarification_resolution(data, errors)
        if confirmation_required == true && confirmation_done != true
          errors << "decision.allow_execution_plan must be false until human_confirmation.confirmed is true" if allow_execution != false
          errors << "status.ready_for_next must be false until human_confirmation.confirmed is true" if ready != false
        end
      when "execution_plan"
        ensure_ready_flag_matches(errors, data, %w[decision allow_final_prd], "decision.allow_final_prd")
        block_on_p0(errors, data, %w[risks_and_watchpoints blockers], %w[decision allow_final_prd], "decision.allow_final_prd")
        validate_batching_strategy(data, errors)
      when "final_prd"
        ensure_ready_flag_matches(errors, data, %w[decision allow_contract_design], "decision.allow_contract_design")
        block_on_p0(errors, data, %w[blocking_questions p0], %w[decision allow_contract_design], "decision.allow_contract_design")
        validate_final_prd_batches(data, errors)
      when "review"
        validate_review_state(data, errors, attempt, max_retry)
      end
    end

    def validate_review_state(data, errors, attempt, max_retry)
      has_blocking = dig(data, %w[decision has_blocking_issue])
      allow_next = dig(data, %w[decision allow_next_step])
      escalation = dig(data, %w[decision need_human_escalation])
      p0 = Array(dig(data, %w[findings p0]))
      step = dig(data, %w[status step])
      subject_type = dig(data, %w[meta subject_type])

      errors << "decision.has_blocking_issue must be true when findings.p0 is not empty" if !p0.empty? && has_blocking != true
      errors << "decision.allow_next_step cannot be true when decision.has_blocking_issue is true" if has_blocking == true && allow_next == true
      errors << "decision.allow_next_step cannot be true when decision.need_human_escalation is true" if escalation == true && allow_next == true
      errors << "decision.need_human_escalation must be true after retry limit is exceeded with blocking issues" if attempt > max_retry && has_blocking == true && escalation != true
      errors << "decision.has_blocking_issue must be true when decision.need_human_escalation is true" if escalation == true && has_blocking != true

      expected_subject = REVIEWABLE_SUBJECTS[step]
      if expected_subject && subject_type != expected_subject
        errors << "meta.subject_type must be #{expected_subject.inspect} when status.step is #{step.inspect}"
      end
    end

    def validate_contract_handoff(handoff, errors, label:, required:)
      required_lists = %w[contract_scope priority_modules required_contract_views do_not_assume]

      required_lists.each do |key|
        values = Array(handoff[key]).select { |item| item.is_a?(String) && !item.strip.empty? }
        next unless required && values.empty?

        errors << "#{label}.#{key} must not be empty when allow_contract_design is true"
      end

      return unless required

      duplicate_keys = required_lists.select do |key|
        values = Array(handoff[key]).select { |item| item.is_a?(String) && !item.strip.empty? }
        values.uniq.length != values.length
      end

      duplicate_keys.each do |key|
        errors << "#{label}.#{key} must not contain duplicate entries"
      end
    end

    def validate_batching_strategy(data, errors)
      strategy = dig(data, %w[batching_strategy]) || {}
      batches = Array(strategy["batches"])
      batch_ids = batches.map { |batch| batch["batch_id"].to_s.strip }.reject(&:empty?)
      batch_order = Array(strategy["batch_order"]).map(&:to_s).map(&:strip).reject(&:empty?)

      errors << "batching_strategy.batches must not be empty" if batches.empty?
      errors << "batching_strategy.batches must use unique batch_id values" if batch_ids.uniq.length != batch_ids.length

      batches.each_with_index do |batch, index|
        depends_on = Array(batch["depends_on_batches"]).map(&:to_s).map(&:strip).reject(&:empty?)
        missing_dependencies = depends_on.reject { |batch_id| batch_ids.include?(batch_id) }
        next if missing_dependencies.empty?

        errors << "batching_strategy.batches.#{index}.depends_on_batches contains unknown batch ids: #{missing_dependencies.join(', ')}"
      end

      return if batch_order.empty?

      missing_from_order = batch_ids - batch_order
      unknown_in_order = batch_order - batch_ids
      errors << "batching_strategy.batch_order must include every batch_id" unless missing_from_order.empty?
      errors << "batching_strategy.batch_order contains unknown batch ids: #{unknown_in_order.join(', ')}" unless unknown_in_order.empty?
      errors << "batching_strategy.batch_order must not contain duplicate batch ids" if batch_order.uniq.length != batch_order.length
    end

    def validate_final_prd_batches(data, errors)
      allow_contract = dig(data, %w[decision allow_contract_design])
      batches = Array(data["prd_batches"])
      batch_ids = batches.map { |batch| batch["batch_id"].to_s.strip }.reject(&:empty?)
      ready_batches = Array(dig(data, %w[decision ready_batches])).map(&:to_s).map(&:strip).reject(&:empty?)
      blocked_batches = Array(dig(data, %w[decision blocked_batches])).map(&:to_s).map(&:strip).reject(&:empty?)
      recommended_batch_order = Array(dig(data, %w[contract_execution recommended_batch_order])).map(&:to_s).map(&:strip).reject(&:empty?)

      errors << "prd_batches must not be empty" if batches.empty?
      errors << "prd_batches must use unique batch_id values" if batch_ids.uniq.length != batch_ids.length

      batches.each_with_index do |batch, index|
        depends_on = Array(batch["dependency_batches"]).map(&:to_s).map(&:strip).reject(&:empty?)
        missing_dependencies = depends_on.reject { |value| batch_ids.include?(value) }
        errors << "prd_batches.#{index}.dependency_batches contains unknown batch ids: #{missing_dependencies.join(', ')}" unless missing_dependencies.empty?

        batch_allow = dig(batch, %w[decision allow_contract_design]) == true
        validate_contract_handoff(batch["contract_handoff"] || {}, errors, label: "prd_batches.#{index}.contract_handoff", required: batch_allow)
      end

      unknown_ready = ready_batches - batch_ids
      unknown_blocked = blocked_batches - batch_ids
      errors << "decision.ready_batches contains unknown batch ids: #{unknown_ready.join(', ')}" unless unknown_ready.empty?
      errors << "decision.blocked_batches contains unknown batch ids: #{unknown_blocked.join(', ')}" unless unknown_blocked.empty?
      errors << "decision.ready_batches must not contain duplicate batch ids" if ready_batches.uniq.length != ready_batches.length
      errors << "decision.blocked_batches must not contain duplicate batch ids" if blocked_batches.uniq.length != blocked_batches.length

      batch_decisions = batches.each_with_object({}) do |batch, acc|
        acc[batch["batch_id"].to_s.strip] = dig(batch, %w[decision allow_contract_design]) == true
      end

      ready_by_batch = batch_decisions.select { |_batch_id, ready| ready }.keys
      blocked_by_batch = batch_decisions.select { |_batch_id, ready| !ready }.keys

      errors << "decision.ready_batches must match prd_batches[*].decision.allow_contract_design=true" if ready_batches.sort != ready_by_batch.sort
      errors << "decision.blocked_batches must match prd_batches[*].decision.allow_contract_design=false" if blocked_batches.sort != blocked_by_batch.sort

      if allow_contract == true && ready_batches.empty?
        errors << "decision.ready_batches must not be empty when decision.allow_contract_design is true"
      end
      if allow_contract == false && !ready_batches.empty?
        errors << "decision.ready_batches must be empty when decision.allow_contract_design is false"
      end

      return if recommended_batch_order.empty?

      unknown_in_order = recommended_batch_order - batch_ids
      missing_from_order = batch_ids - recommended_batch_order
      errors << "contract_execution.recommended_batch_order contains unknown batch ids: #{unknown_in_order.join(', ')}" unless unknown_in_order.empty?
      errors << "contract_execution.recommended_batch_order must include every batch_id" unless missing_from_order.empty?
      errors << "contract_execution.recommended_batch_order must not contain duplicate batch ids" if recommended_batch_order.uniq.length != recommended_batch_order.length
    end

    def validate_cross_file_rules(artifact, data, artifact_path, errors)
      case artifact
      when "analysis"
        validate_source_paths(data, artifact_path, errors)
      when "clarification"
        paths = validate_source_paths(data, artifact_path, errors)
        ensure_referenced_artifact_type(paths, "analysis", "meta.source_paths", errors)
      when "execution_plan"
        paths = validate_source_paths(data, artifact_path, errors)
        ensure_referenced_artifact_type(paths, "clarification", "meta.source_paths", errors)
      when "final_prd"
        paths = validate_source_paths(data, artifact_path, errors)
        ensure_referenced_artifact_type(paths, "execution_plan", "meta.source_paths", errors)
        ensure_referenced_artifact_type(paths, "clarification", "meta.source_paths", errors)
      when "review"
        validate_review_subject(data, artifact_path, errors)
      end
    end

    def validate_confirmation_items(items, errors, prefix, expected_step_id:)
      Array(items).each_with_index do |item, index|
        options = Array(item["options"])
        answer_mode = item["answer_mode"]
        recommended = item["recommended"].to_s
        default_if_no_answer = item["default_if_no_answer"].to_s
        option_values = options.map { |option| option["value"] }
        item_id = item["item_id"].to_s

        if %w[single_choice multiple_choice boolean].include?(answer_mode) && options.empty?
          errors << "#{prefix}.#{index}.options must not be empty for answer_mode=#{answer_mode}"
        end
        if !recommended.strip.empty? && !option_values.empty? && !option_values.include?(recommended)
          errors << "#{prefix}.#{index}.recommended must match one of options.value when provided"
        end
        if !default_if_no_answer.strip.empty? && !option_values.empty? && !option_values.include?(default_if_no_answer)
          errors << "#{prefix}.#{index}.default_if_no_answer must match one of options.value when provided"
        end
        unless stable_confirmation_item_id?(item_id, expected_step_id)
          errors << "#{prefix}.#{index}.item_id must use stable step numbering like #{expected_step_id}-01"
        end
      end
    end

    def validate_clarification_resolution(data, errors)
      confirmation_items = Array(data["confirmation_items"])
      clarified_decisions = Array(data["clarified_decisions"])
      resolved_item_ids = clarified_decisions.map { |item| item["item_id"].to_s.strip }.reject(&:empty?)
      confirmation_required = dig(data, %w[human_confirmation required])
      confirmation_done = dig(data, %w[human_confirmation confirmed])
      allow_execution = dig(data, %w[decision allow_execution_plan])

      required_ids = confirmation_items.each_with_object([]) do |item, acc|
        next unless item.is_a?(Hash) && item["level"] == "required"

        item_id = item["item_id"].to_s.strip
        acc << item_id unless item_id.empty?
      end

      unresolved_ids = required_ids.reject { |item_id| resolved_item_ids.include?(item_id) }

      if confirmation_done == true && !unresolved_ids.empty?
        errors << "clarified_decisions must include item_id for every required confirmation item before human_confirmation.confirmed can be true: #{unresolved_ids.join(', ')}"
      end

      if allow_execution == true && confirmation_required == true && !required_ids.empty? && !unresolved_ids.empty?
        errors << "decision.allow_execution_plan cannot be true while required confirmation_items are unresolved"
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

    def ensure_referenced_artifact_type(paths, expected_type, label, errors)
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

      errors << "meta.subject_type=#{subject_type.inspect} does not match subject artifact_type=#{actual_type.inspect}" if actual_type != subject_type
      if expected_subject_type && actual_type != expected_subject_type
        errors << "meta.subject_path must point to a #{expected_subject_type.inspect} artifact when status.step is #{review_step.inspect}"
      end
      errors << "subject status.step=#{actual_step.inspect} does not match review status.step=#{review_step.inspect}" if actual_step != review_step
    end

    def ensure_ready_flag_matches(errors, data, decision_path, decision_label)
      ready = dig(data, %w[status ready_for_next])
      decision = dig(data, decision_path)
      errors << "status.ready_for_next must match #{decision_label}" unless ready == decision
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
      candidates << raw_path if File.absolute_path(raw_path) == raw_path rescue false
      candidates << File.expand_path(raw_path, File.dirname(artifact_path))
      candidates << File.expand_path(raw_path, ROOT)
      candidates.uniq.find { |candidate| File.exist?(candidate) }
    end

    def join_path(path, key)
      (path + [key]).join(".")
    end

    def expand_repo_path(path)
      return nil unless path

      File.expand_path(path, ROOT)
    end

    def stable_confirmation_item_id?(item_id, expected_step_id)
      return false if item_id.strip.empty?

      /\A#{Regexp.escape(expected_step_id)}-\d{2}\z/.match?(item_id)
    end
  end
end
