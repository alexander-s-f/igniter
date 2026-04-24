#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-web/lib", __dir__))

require "tmpdir"

require "igniter/application"
require "igniter/web"

Dir.mktmpdir("igniter-web-structure") do |root|
  compact = Igniter::Application.blueprint(
    name: :operator,
    root: File.join(root, "operator"),
    env: :test,
    layout_profile: :capsule,
    web_surfaces: [:operator_console]
  )
  expanded = Igniter::Application.blueprint(
    name: :dashboard,
    root: File.join(root, "dashboard"),
    env: :test,
    layout_profile: :standalone,
    web_surfaces: [:cluster_dashboard]
  )
  non_web = Igniter::Application.blueprint(
    name: :pricing,
    root: File.join(root, "pricing"),
    env: :test,
    layout_profile: :capsule,
    groups: %i[contracts services]
  )

  compact_structure = Igniter::Web.surface_structure(compact)
  expanded_structure = Igniter::Web.surface_structure(expanded)

  puts "application_web_surface_compact_root=#{compact_structure.web_root}"
  puts "application_web_surface_expanded_root=#{expanded_structure.web_root}"
  puts "application_web_surface_compact_screens=#{compact_structure.path(:screens)}"
  puts "application_web_surface_expanded_screens=#{expanded_structure.path(:screens)}"
  puts "application_web_surface_groups=#{compact_structure.groups.join(",")}"
  puts "application_web_surface_active_compact=#{compact.active_groups.join(",")}"
  puts "application_web_surface_active_non_web=#{non_web.active_groups.join(",")}"
  puts "application_web_surface_non_web=#{non_web.active_groups.include?(:web)}"
  puts "application_web_surface_projection_path=#{compact_structure.path(:projections)}"
end
