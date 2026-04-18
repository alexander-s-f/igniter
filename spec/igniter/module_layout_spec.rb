# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Igniter module layout" do
  MODULE_LAYOUT_ROOT = File.expand_path("../..", __dir__)
  IGNITER_LIB = File.join(MODULE_LAYOUT_ROOT, "lib/igniter")

  def children_for(path)
    Dir.children(path).sort
  end

  it "keeps only canonical top-level runtime and registry entrypoints under lib/igniter" do
    expect(children_for(IGNITER_LIB)).to eq(%w[
      app
      app.rb
      cluster
      cluster.rb
      core
      core.rb
      extensions
      monorepo_packages.rb
      plugins
      plugins.rb
      sdk
      sdk.rb
      server
      server.rb
      stack.rb
    ])
  end

  it "keeps sdk packs under the canonical sdk namespace" do
    expect(children_for(File.join(IGNITER_LIB, "sdk"))).to eq(%w[
      agents
      agents.rb
      ai
      ai.rb
      channels
      channels.rb
      data
      data.rb
      tools
      tools.rb
    ])
  end

  it "keeps plugins under the canonical plugins namespace" do
    expect(children_for(File.join(IGNITER_LIB, "plugins"))).to eq(%w[
      rails
      rails.rb
    ])
  end
end
