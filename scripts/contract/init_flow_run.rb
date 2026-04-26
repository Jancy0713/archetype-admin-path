#!/usr/bin/env ruby
require "fileutils"
require "pathname"
require "yaml"

require_relative "artifact_utils"
require_relative "workflow_manifest"
require_relative "progress_board"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/contract/init_flow_run.rb [--force] <flow-handoff.yaml>"
  exit 1
end

def read_yaml(path)
  Contract::ArtifactUtils.load_yaml(path)
end

def relative_path(from, to)
  Pathname.new(File.expand_path(to)).relative_path_from(Pathname.new(File.expand_path(from))).to_s
rescue ArgumentError
  File.expand_path(to)
end

args = ARGV.dup
force = args.delete("--force")
handoff_path = args[0]
usage if handoff_path.to_s.strip.empty?

source_handoff_yaml = File.expand_path(handoff_path, ROOT)
unless File.exist?(source_handoff_yaml)
  warn "Flow handoff not found: #{source_handoff_yaml}"
  exit 1
end

handoff = read_yaml(source_handoff_yaml)
unless handoff["artifact_type"] == "contract_flow_handoff"
  warn "Expected contract_flow_handoff artifact: #{source_handoff_yaml}"
  exit 1
end

flow_id = handoff["flow_id"].to_s
if flow_id.empty?
  warn "contract_flow_handoff.flow_id is required"
  exit 1
end

# Handoff status check removed to allow initializing pending flows as standardized shells

# Standard creation logic is now in create_run.rb
# init_flow_run.rb will:
# 1. Parse the handoff
# 2. Call create_run.rb to create the standard shell
# 3. Copy intake snapshots
# 4. Fill in flow-specific prompt details (if needed)

handoff = read_yaml(source_handoff_yaml)
# ... validations already done above ...

flow_id = handoff["flow_id"].to_s
title = flow_id # Default title to flow_id
run_id = ContractFlow::WorkflowManifest.run_id(flow_id)
run_root = ContractFlow::WorkflowManifest.run_root(ROOT, flow_id)

if Dir.exist?(run_root)
  if force
    FileUtils.rm_rf(run_root)
  else
    warn "Flow run already exists: #{run_root} (use --force to overwrite)"
    exit 1
  end
end

depends_on = Array(handoff["dependency_flows"]).join(", ")
depends_on = "None" if depends_on.empty?

create_cmd = [
  "ruby", "scripts/create_run.rb",
  "--flow", "contract",
  "--run-id", run_id,
  "--flow-id", flow_id,
  "--title", title,
  "--owner", ENV["USER"] || "script",
  "--handoff", handoff_path,
  "--status", handoff["status"] || "ready",
  "--dependencies", depends_on
]
success = system(*create_cmd, chdir: ROOT)
exit 1 unless success

# 3. Copy intake snapshots
source_handoff_markdown = source_handoff_yaml.sub(/\.ya?ml\z/, ".md")
source_handoff_markdown = nil unless File.exist?(source_handoff_markdown)

FileUtils.cp(source_handoff_yaml, ContractFlow::WorkflowManifest.handoff_snapshot_yaml_path(run_root))
if source_handoff_markdown
  FileUtils.cp(source_handoff_markdown, ContractFlow::WorkflowManifest.handoff_snapshot_markdown_path(run_root))
else
  File.write(
    ContractFlow::WorkflowManifest.handoff_snapshot_markdown_path(run_root),
    "# Contract Handoff Snapshot\n\n- Source: `#{relative_path(run_root, source_handoff_yaml)}`\n"
  )
end

# 4. Initialize progress board with specific meta
ContractFlow::ProgressBoard.initialize!(
  run_root: run_root,
  flow_id: flow_id,
  source_handoff_yaml_path: source_handoff_yaml,
  source_handoff_markdown_path: source_handoff_markdown
)

# 5. Enrich the run.yaml with more detail
manifest_path = File.join(run_root, "run.yaml")
if File.exist?(manifest_path)
  manifest = YAML.load_file(manifest_path)
  manifest.merge!({
    "source_prd_run_id" => handoff["run_id"],
    "source_prd_run_root" => File.expand_path(File.join(File.dirname(source_handoff_yaml), "..", "..")),
    "source_handoff_yaml" => source_handoff_yaml,
    "source_handoff_markdown" => source_handoff_markdown,
    "source_final_prd" => handoff["source_final_prd"],
    "intake" => {
      "handoff_snapshot_yaml" => ContractFlow::WorkflowManifest.handoff_snapshot_yaml_relative_path,
      "handoff_snapshot_markdown" => ContractFlow::WorkflowManifest.handoff_snapshot_markdown_relative_path,
    },
    "working" => {
      "root" => ContractFlow::WorkflowManifest.working_dir_relative_path,
      "first_artifact" => ContractFlow::WorkflowManifest.artifact_relative_path("contract-01"),
    },
    "release" => {
      "root" => ContractFlow::WorkflowManifest.release_dir_relative_path,
      "formal_outputs" => ContractFlow::WorkflowManifest.release_files_relative_paths,
    }
  })
  File.write(manifest_path, YAML.dump(manifest))
end

# 6. Finalization
puts "Flow run initialized for #{flow_id} at #{run_root}"
