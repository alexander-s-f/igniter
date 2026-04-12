# frozen_string_literal: true

require "igniter/application"
require_relative "apps/main/application"
require_relative "apps/inference/application"

module Companion
  class Workspace < Igniter::Workspace
    root_dir __dir__
    shared_lib_path "lib"

    app :main, path: "apps/main", klass: Companion::MainApp, default: true
    app :inference, path: "apps/inference", klass: Companion::InferenceApp
  end
end

if $PROGRAM_NAME == __FILE__
  app_name = ARGV.shift || ENV.fetch("IGNITER_APP", "main")
  Companion::Workspace.start(app_name)
end
