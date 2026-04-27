#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "fileutils"
require "tmpdir"

require "igniter/application"

Dir.mktmpdir("igniter-capsule-agent-transfer") do |root|
  capsule_root = File.join(root, "companion")
  artifact = File.join(root, "companion_bundle")
  destination = File.join(root, "destination")

  FileUtils.mkdir_p(File.join(capsule_root, "agents"))
  FileUtils.mkdir_p(File.join(capsule_root, "providers"))
  FileUtils.mkdir_p(File.join(capsule_root, "services"))
  FileUtils.mkdir_p(File.join(capsule_root, "spec"))
  File.write(File.join(capsule_root, "agents/daily_companion.rb"), "# daily companion agent\n")
  File.write(File.join(capsule_root, "igniter.rb"), "# config\n")

  capsule = Igniter::Application.capsule(:companion, root: capsule_root, env: :test) do
    layout :capsule
    groups :agents, :services
    provider :openai
    service :companion_store
    agent :daily_companion,
          ai: :openai,
          instructions: "Give one practical next action.",
          tools: [:complete_reminder],
          metadata: { capsule: :daily_summary }
    export :daily_companion, kind: :agent
  end

  handoff = Igniter::Application.handoff_manifest(subject: :companion_bundle, capsules: [capsule])
  inventory = Igniter::Application.transfer_inventory(capsule)
  readiness = Igniter::Application.transfer_readiness(
    handoff_manifest: handoff,
    transfer_inventory: inventory
  )
  bundle_plan = Igniter::Application.transfer_bundle_plan(transfer_readiness: readiness)
  Igniter::Application.write_transfer_bundle(bundle_plan, output: artifact)
  verification = Igniter::Application.verify_transfer_bundle(artifact)
  intake = Igniter::Application.transfer_intake_plan(verification, destination_root: destination)
  apply_plan = Igniter::Application.transfer_apply_plan(intake)
  committed = Igniter::Application.apply_transfer_plan(apply_plan, commit: true)
  applied_verification = Igniter::Application.verify_applied_transfer(committed, apply_plan: apply_plan)
  receipt = Igniter::Application.transfer_receipt(
    applied_verification,
    apply_result: committed,
    apply_plan: apply_plan
  )

  agent = receipt.to_h.fetch(:agent_capabilities).first

  puts "application_capsule_agent_transfer_ready=#{readiness.to_h.fetch(:ready)}"
  puts "application_capsule_agent_transfer_bundle_allowed=#{bundle_plan.to_h.fetch(:bundle_allowed)}"
  puts "application_capsule_agent_transfer_receipt_complete=#{receipt.to_h.fetch(:complete)}"
  puts "application_capsule_agent_transfer_agent=#{agent.fetch(:name)}"
  puts "application_capsule_agent_transfer_ai_provider=#{agent.fetch(:ai_provider)}"
  puts "application_capsule_agent_transfer_tools=#{agent.fetch(:tools).join(",")}"
  puts "application_capsule_agent_transfer_export=#{handoff.to_h.fetch(:exports).first.fetch(:kind)}"
end
