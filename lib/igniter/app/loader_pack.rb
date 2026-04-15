# frozen_string_literal: true

require_relative "loader_registry"
require_relative "filesystem_loader_adapter"

Igniter::App::LoaderRegistry.register(:filesystem) do
  Igniter::App::FilesystemLoaderAdapter.new
end
