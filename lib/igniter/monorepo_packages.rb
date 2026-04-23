# frozen_string_literal: true

[
  File.expand_path("../../packages/igniter-contracts/lib", __dir__),
  File.expand_path("../../packages/igniter-extensions/lib", __dir__),
  File.expand_path("../../packages/igniter-application/lib", __dir__),
  # deprecated:
  # File.expand_path("../../packages/archive/igniter-core/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-agents/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-ai/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-sdk/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-extensions/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-app/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-server/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-cluster/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-rails/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-frontend/lib", __dir__),
  # File.expand_path("../../packages/archive/igniter-schema-rendering/lib", __dir__)
].each do |path|
  $LOAD_PATH.unshift(path) if File.directory?(path) && !$LOAD_PATH.include?(path)
end
