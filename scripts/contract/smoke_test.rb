#!/usr/bin/env ruby

ROOT = File.expand_path("../..", __dir__)

def run!(*cmd)
  puts "$ #{cmd.join(' ')}"
  success = system(*cmd, chdir: ROOT)
  return if success

  exit(Process.last_status&.exitstatus || 1)
end

run!("ruby", "scripts/contract/handoff_smoke.rb")
run!("ruby", "scripts/contract/initial_ready_smoke.rb")
run!("ruby", "scripts/contract/progress_board_smoke.rb")
run!("ruby", "scripts/contract/mainline_smoke.rb")
run!("ruby", "scripts/contract/single_flow_release_smoke.rb")
run!("ruby", "scripts/contract/build_release_guard_smoke.rb")
run!("ruby", "scripts/contract/build_release_resume_smoke.rb")
run!("ruby", "scripts/contract/blocked_review_smoke.rb")
run!("ruby", "scripts/contract/review_escalation_smoke.rb")
run!("ruby", "scripts/contract/release_atomicity_smoke.rb")
puts "Contract core smoke test passed."
