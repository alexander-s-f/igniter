#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

OperatorSurface = Struct.new(:name)

profile = Igniter::Application.build_kernel
                              .manifest(:operator, root: "/tmp/igniter_operator", env: :test)
                              .mount_web(
                                :operator_console,
                                OperatorSurface.new("OperatorConsole"),
                                at: "operator",
                                capabilities: %i[screen stream],
                                metadata: { interaction_model: :agent_operated }
                              )
                              .mount(
                                :agent_bus,
                                :agent_bus_adapter,
                                kind: :agent,
                                at: "/agents",
                                capabilities: [:command]
                              )
                              .finalize

environment = Igniter::Application::Environment.new(profile: profile)
web_mount = environment.mount(:operator_console)

puts "application_mount_names=#{profile.mount_names.join(",")}"
puts "application_mount_web_kind=#{web_mount.kind}"
puts "application_mount_web_at=#{web_mount.at}"
puts "application_mount_web_capabilities=#{web_mount.capabilities.join(",")}"
puts "application_mount_web_target=#{web_mount.target_name}"
puts "application_mount_manifest=#{environment.manifest.mounts.map { |entry| entry.fetch(:name) }.join(",")}"
puts "application_mount_snapshot=#{environment.snapshot.to_h.fetch(:mounts).map { |entry| entry.fetch(:kind) }.join(",")}"
