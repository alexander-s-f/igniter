#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "igniter/application"
require "igniter/web"

web = Igniter::Web.application do
  root title: "Operator" do
    main do
      h1 assigns[:ctx].manifest.name
      para assigns[:ctx].route("/events")
      para assigns[:ctx].service(:cluster_status).call
      para assigns[:ctx].capabilities.join(",")
    end
  end

  command "/incidents/:id/resolve", to: Igniter::Web.contract("Contracts::ResolveIncident")
  stream "/events", to: Igniter::Web.projection("Projections::ClusterEvents")
end

mount = Igniter::Web.mount(:operator, path: "/operator", application: web)

kernel = Igniter::Application.build_kernel
kernel.manifest(:operator, root: "/tmp/igniter_operator", env: :test)
kernel.provide(:cluster_status, -> { "green" })
kernel.mount_web(
  :operator,
  mount,
  at: "/operator",
  capabilities: %i[screen stream command],
  metadata: { interaction_model: :agent_operated }
)

environment = Igniter::Application::Environment.new(profile: kernel.finalize)
bound_mount = mount.bind(environment: environment)
status, headers, body = bound_mount.rack_app.call("PATH_INFO" => "/operator")
html = body.join

puts "application_web_mount_status=#{status}"
puts "application_web_mount_content_type=#{headers.fetch("content-type")}"
puts "application_web_mount_manifest=#{html.include?("operator")}"
puts "application_web_mount_route=#{html.include?("/operator/events")}"
puts "application_web_mount_service=#{html.include?("green")}"
puts "application_web_mount_capabilities=#{html.include?("command,screen,stream")}"
puts "application_web_mount_registration=#{environment.mount(:operator).to_h.fetch(:kind)}"
puts "application_web_mount_command=#{web.api_surface.endpoints.find { |endpoint| endpoint.kind == :command }.target}"
puts "application_web_mount_stream=#{web.api_surface.endpoints.find { |endpoint| endpoint.kind == :stream }.target}"
puts "application_web_mount_command_shape=#{web.api_surface.endpoints.find { |endpoint| endpoint.kind == :command }.target.kind}"
puts "application_web_mount_stream_shape=#{web.api_surface.endpoints.find { |endpoint| endpoint.kind == :stream }.target.kind}"
