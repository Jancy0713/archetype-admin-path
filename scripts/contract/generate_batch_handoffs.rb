#!/usr/bin/env ruby
require "fileutils"

require_relative "handoff_generation"

ROOT = File.expand_path("../..", __dir__)

def usage
  warn "Usage: ruby scripts/contract/generate_batch_handoffs.rb [--force] <run_dir> <final_prd.yml>"
  exit 1
end

args = ARGV.dup
force = args.delete("--force")
run_dir = args[0]
final_prd_path = args[1]
usage if run_dir.to_s.strip.empty? || final_prd_path.to_s.strip.empty?

begin
  result = ContractFlow::HandoffGeneration.generate!(
    run_root: File.expand_path(run_dir, ROOT),
    final_prd_path: File.expand_path(final_prd_path, ROOT),
    force: force,
    allow_existing: false
  )
rescue ArgumentError => e
  warn e.message
  exit 1
end

puts "Generated contract handoff index at #{result.fetch(:index_path)}"
puts "Generated contract handoff overview at #{result.fetch(:overview_doc_path)}"
result.fetch(:ordered_flow_ids).each_with_index do |flow_id, index_position|
  run_root = File.expand_path(run_dir, ROOT)
  puts "Generated structured flow handoff: #{ContractFlow::HandoffGeneration.contract_flow_handoff_yaml_path(run_root, index_position + 1, flow_id)}"
  puts "Generated readable flow handoff: #{ContractFlow::HandoffGeneration.contract_flow_handoff_markdown_path(run_root, index_position + 1, flow_id)}"
end
