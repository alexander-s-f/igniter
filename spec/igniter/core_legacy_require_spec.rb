# frozen_string_literal: true

require "spec_helper"
require "open3"
require "rbconfig"

RSpec.describe "Igniter legacy core entrypoints" do
  LEGACY_ROOT = File.expand_path("../..", __dir__)

  def bundled_load_path_script(entrypoint)
    <<~RUBY
      $LOAD_PATH.unshift(File.expand_path("lib", #{LEGACY_ROOT.inspect}))
      $LOAD_PATH.unshift(File.expand_path("packages/igniter-core/lib", #{LEGACY_ROOT.inspect}))
      $LOAD_PATH.unshift(File.expand_path("packages/igniter-contracts/lib", #{LEGACY_ROOT.inspect}))
      $LOAD_PATH.unshift(File.expand_path("packages/igniter-extensions/lib", #{LEGACY_ROOT.inspect}))
      require #{entrypoint.inspect}
    RUBY
  end

  def capture_require(entrypoint, env: {})
    Open3.capture3(
      env,
      RbConfig.ruby,
      "-e",
      bundled_load_path_script(entrypoint),
      chdir: LEGACY_ROOT
    )
  end

  it "warns when loading igniter/core by default" do
    _stdout, stderr, status = capture_require(
      "igniter/core",
      env: { "IGNITER_LEGACY_CORE_REQUIRE" => nil }
    )

    expect(status.success?).to eq(true)
    expect(stderr).to include("legacy reference implementation")
    expect(stderr).to include("igniter/core")
    expect(stderr).to include("igniter-contracts")
  end

  it "can fail fast for legacy core entrypoints in strict mode" do
    _stdout, stderr, status = capture_require(
      "igniter/core/tool",
      env: { "IGNITER_LEGACY_CORE_REQUIRE" => "error" }
    )

    expect(status.success?).to eq(false)
    expect(stderr).to include("Igniter::Core::Legacy::RequireError")
    expect(stderr).to include("igniter/core/tool")
  end

  it "does not emit a legacy core warning for the contracts-facing extensions facade" do
    _stdout, stderr, status = capture_require(
      "igniter/extensions/contracts",
      env: { "IGNITER_LEGACY_CORE_REQUIRE" => nil }
    )

    expect(status.success?).to eq(true)
    expect(stderr).not_to include("legacy reference implementation")
    expect(stderr).not_to include("igniter-core")
  end

  it "does not emit a legacy core warning for the package root facade alone" do
    _stdout, stderr, status = capture_require(
      "igniter-extensions",
      env: { "IGNITER_LEGACY_CORE_REQUIRE" => nil }
    )

    expect(status.success?).to eq(true)
    expect(stderr).not_to include("legacy reference implementation")
    expect(stderr).not_to include("igniter-core")
  end
end
