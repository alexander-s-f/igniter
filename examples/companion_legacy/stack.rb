# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../../lib", __dir__))

require "igniter/stack"
require_relative "apps/main/app"
require_relative "apps/inference/app"
require_relative "apps/dashboard/app"

module Companion
  class Stack < Igniter::Stack
    root_dir __dir__
    shared_lib_path "lib"

    app :main, path: "apps/main", klass: Companion::MainApp, default: true
    app :inference, path: "apps/inference", klass: Companion::InferenceApp
    app :dashboard, path: "apps/dashboard", klass: Companion::DashboardApp
  end
end

if $PROGRAM_NAME == __FILE__
  Companion::Stack.start_cli(ARGV)
end
