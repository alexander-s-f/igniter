# frozen_string_literal: true

require "spec_helper"
require "igniter/plugins/view"

RSpec.describe Igniter::Plugins::View do
  class TestMetricCard < Igniter::Plugins::View::Component
    def initialize(label:, value:)
      @label = label
      @value = value
    end

    def call(view)
      view.tag(:div, class: "metric") do |card|
        card.tag(:strong, @label)
        card.tag(:span, @value, class: "value")
      end
    end
  end

  class TestPage < Igniter::Plugins::View::Page
    def call(view)
      render_document(view, title: "View Test") do |body|
        body.tag(:main) do |main|
          main.component(TestMetricCard, label: "Notes", value: 4)
          main.form(action: "/checkins") do |form|
            form.label("mood", "Mood")
            form.select("mood", options: [["Great", "great"], ["Okay", "okay"]], selected: "okay", id: "mood")
            form.textarea("notes", value: "Felt good today", rows: 3)
            form.checkbox("public", checked: true)
            form.submit("Save")
          end
        end
      end
    end
  end

  describe ".render" do
    it "renders nested HTML and escapes text and attributes" do
      html = described_class.render do |view|
        view.doctype
        view.tag(:div, class: ["card", "accent"], data: { chat_id: 123 }, hidden: true) do |div|
          div.tag(:strong, "<hello>")
          div.tag(:br)
          div.text("A & B")
        end
      end

      expect(html).to include("<!DOCTYPE html>")
      expect(html).to include('<div class="card accent" data-chat-id="123" hidden>')
      expect(html).to include("<strong>&lt;hello&gt;</strong>")
      expect(html).to include("<br>")
      expect(html).to include("A &amp; B")
    end
  end

  it "renders components and forms through page abstractions" do
    html = TestPage.render

    expect(html).to include("<!DOCTYPE html>")
    expect(html).to include("<title>View Test</title>")
    expect(html).to include('<div class="metric"><strong>Notes</strong><span class="value">4</span></div>')
    expect(html).to include('<form action="/checkins" method="post">')
    expect(html).to include('<label for="mood">Mood</label>')
    expect(html).to include('<option value="okay" selected>Okay</option>')
    expect(html).to include("<textarea")
    expect(html).to include('name="notes"')
    expect(html).to include('rows="3"')
    expect(html).to include(">Felt good today</textarea>")
    expect(html).to include('<input type="checkbox" name="public" value="1" checked>')
    expect(html).to include('<button type="submit">Save</button>')
  end

  describe Igniter::Plugins::View::Response do
    it "builds a standard HTML response" do
      response = described_class.html("<h1>Hello</h1>", headers: { "X-Test" => "1" })

      expect(response).to eq(
        status: 200,
        body: "<h1>Hello</h1>",
        headers: {
          "Content-Type" => "text/html; charset=utf-8",
          "X-Test" => "1"
        }
      )
    end
  end
end
