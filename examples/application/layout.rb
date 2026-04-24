#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

root = File.expand_path("../tmp/shop_app", __dir__)

profile = Igniter::Application.build_kernel(Igniter::Extensions::Contracts::ComposePack)
                              .manifest(:shop, root: root, env: :test, metadata: { owner: :commerce })
                              .providers_path("app/providers")
                              .services_path("app/services")
                              .effects_path("app/effects")
                              .packs_path("app/packs")
                              .contracts_path("app/contracts")
                              .config_path("config/igniter.rb")
                              .set(:runtime, :mode, value: :test)
                              .provide(:pricing_api, -> { :ok })
                              .register("PricingContract", Object)
                              .finalize

environment = Igniter::Application::Environment.new(profile: profile)
manifest = environment.manifest

puts "application_manifest_name=#{manifest.name}"
puts "application_manifest_env=#{manifest.env}"
puts "application_layout_contracts=#{environment.layout.path(:contracts)}"
puts "application_layout_config=#{environment.layout.path(:config)}"
puts "application_manifest_services=#{manifest.services.join(",")}"
puts "application_manifest_contracts=#{manifest.contracts.join(",")}"
puts "application_manifest_owner=#{manifest.metadata.fetch(:owner)}"
