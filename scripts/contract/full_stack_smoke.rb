#!/usr/bin/env ruby

ROOT = File.expand_path("../..", __dir__)

def run!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

run!("ruby", "scripts/contract/smoke_test.rb")
puts "Contract full-stack smoke test passed."
