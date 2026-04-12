# frozen_string_literal: true

require "igniter/application"
require_relative "apps/main/application"
require_relative "apps/inference/application"
require_relative "apps/dashboard/application"

module Companion
  class Workspace < Igniter::Workspace
    root_dir __dir__
    shared_lib_path "lib"

    app :main, path: "apps/main", klass: Companion::MainApp, default: true
    app :inference, path: "apps/inference", klass: Companion::InferenceApp
    app :dashboard, path: "apps/dashboard", klass: Companion::DashboardApp
  end
end

if $PROGRAM_NAME == __FILE__
  Companion::Workspace.start_cli(ARGV)
end
