#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "tmpdir"

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-contracts/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-extensions/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../../packages/igniter-application/lib", __dir__))

require "igniter/application"

Dir.mktmpdir("igniter-shop") do |root|
  FileUtils.mkdir_p(File.join(root, "app/contracts"))
  FileUtils.mkdir_p(File.join(root, "app/services"))
  FileUtils.mkdir_p(File.join(root, "config"))
  File.write(File.join(root, "config/igniter.rb"), "# example config\n")

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
  boot_report = environment.boot(base_dir: root, start_scheduler: false)
  load_report = boot_report.loader_result.metadata.fetch(:load_report)

  puts "application_manifest_name=#{manifest.name}"
  puts "application_manifest_env=#{manifest.env}"
  puts "application_layout_contracts=#{environment.layout.path(:contracts)}"
  puts "application_layout_config=#{environment.layout.path(:config)}"
  puts "application_manifest_services=#{manifest.services.join(",")}"
  puts "application_manifest_contracts=#{manifest.contracts.join(",")}"
  puts "application_manifest_owner=#{manifest.metadata.fetch(:owner)}"
  puts "application_load_present=#{load_report.fetch(:present_groups).join(",")}"
  puts "application_load_missing=#{load_report.fetch(:missing_groups).join(",")}"
end
