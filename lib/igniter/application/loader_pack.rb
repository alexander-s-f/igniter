# frozen_string_literal: true

require_relative "loader_registry"
require_relative "filesystem_loader_adapter"

Igniter::Application::LoaderRegistry.register(:filesystem) do
  Igniter::Application::FilesystemLoaderAdapter.new
end
