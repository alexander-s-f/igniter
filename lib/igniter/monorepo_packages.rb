# frozen_string_literal: true

[
  File.expand_path("../../packages/igniter-frontend/lib", __dir__),
  File.expand_path("../../packages/igniter-schema-rendering/lib", __dir__)
].each do |path|
  $LOAD_PATH.unshift(path) if File.directory?(path) && !$LOAD_PATH.include?(path)
end
