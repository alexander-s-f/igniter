# frozen_string_literal: true

[
  File.expand_path("../../packages/igniter-contracts/lib", __dir__),
  File.expand_path("../../packages/igniter-extensions/lib", __dir__),
  File.expand_path("../../packages/igniter-application/lib", __dir__),
  File.expand_path("../../packages/igniter-mcp-adapter/lib", __dir__)
].each do |path|
  $LOAD_PATH.unshift(path) if File.directory?(path) && !$LOAD_PATH.include?(path)
end
