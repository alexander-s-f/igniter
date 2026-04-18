# frozen_string_literal: true

require "spec_helper"
require "igniter/plugins/view"

RSpec.describe Igniter::Plugins::View::SchemaPage do
  it "delegates page rendering through SchemaRenderer with overridable options" do
    stub_const("Igniter::Plugins::View::SchemaRenderer", Class.new)
    allow(Igniter::Plugins::View::SchemaRenderer).to receive(:render).and_return("<html>schema</html>")

    page_class = Class.new(described_class) do
      def initialize(schema:)
        @schema = schema
      end

      private

      def schema
        @schema
      end

      def schema_render_options
        { values: { "mode" => "agent" } }
      end
    end

    html = page_class.new(schema: { title: "Agent Surface" }).render(notice: "ready")

    expect(html).to eq("<html>schema</html>")
    expect(Igniter::Plugins::View::SchemaRenderer).to have_received(:render).with(
      schema: { title: "Agent Surface" },
      values: { "mode" => "agent" },
      notice: "ready"
    )
  end
end
