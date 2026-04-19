# frozen_string_literal: true

[
  File.expand_path("../../packages/igniter-core/lib", __dir__),
  File.expand_path("../../packages/igniter-agents/lib", __dir__),
  File.expand_path("../../packages/igniter-ai/lib", __dir__),
  File.expand_path("../../packages/igniter-sdk/lib", __dir__),
  File.expand_path("../../packages/igniter-extensions/lib", __dir__),
  File.expand_path("../../packages/igniter-app/lib", __dir__),
  File.expand_path("../../packages/igniter-server/lib", __dir__),
  File.expand_path("../../packages/igniter-cluster/lib", __dir__),
  File.expand_path("../../packages/igniter-rails/lib", __dir__),
  File.expand_path("../../packages/igniter-frontend/lib", __dir__),
  File.expand_path("../../packages/igniter-schema-rendering/lib", __dir__)
].each do |path|
  $LOAD_PATH.unshift(path) if File.directory?(path) && !$LOAD_PATH.include?(path)
end
