# frozen_string_literal: true

require "spec_helper"
require "igniter/plugins/view"
require "igniter/plugins/view/arbre"
require "igniter/plugins/view/tailwind"

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

RSpec.describe Igniter::Plugins::View::Arbre do
  it "keeps the Arbre adapter optional" do
    expect([true, false]).to include(described_class.available?)
  end

  it "either exposes Arbre classes or raises a friendly missing dependency error" do
    if described_class.available?
      expect(described_class.component_class.name).to eq("Arbre::Component")
      expect(described_class.context_class.name).to eq("Arbre::Context")
    else
      expect do
        described_class.component_class
      end.to raise_error(described_class::MissingDependencyError, /arbre/)
    end
  end
end

RSpec.describe Igniter::Plugins::View::Tailwind do
  it "renders a Tailwind-friendly page shell with an optional config script" do
    html = described_class.render_page(
      title: "Ops Dashboard",
      tailwind_config: {
        theme: {
          extend: {
            colors: {
              accent: "#C2410C"
            }
          }
        }
      }
    ) do |main|
      main.tag(:section, class: "rounded-3xl border border-white/10 bg-white/5 p-8 shadow-2xl shadow-black/30") do |section|
        section.tag(:p, "Nodes healthy", class: "text-sm uppercase tracking-[0.3em] text-orange-300")
        section.tag(:h1, "Cluster Control", class: "mt-4 text-4xl font-semibold text-white")
      end
    end

    expect(html).to include("<!DOCTYPE html>")
    expect(html).to include("<title>Ops Dashboard</title>")
    expect(html).to include(Igniter::Plugins::View::Tailwind::PLAY_CDN_URL)
    expect(html).to include("tailwind.config = ")
    expect(html).to include('"accent":"#C2410C"')
    expect(html).to include("rounded-3xl")
    expect(html).to include("Cluster Control")
  end

  it "can inject additional head content" do
    html = described_class.render_page(
      title: "Ops Dashboard",
      head_content: lambda { |head|
        head.tag(:script, type: "text/javascript") { |script| script.raw("window.tailwindReady = true;") }
      }
    ) do |main|
      main.tag(:p, "Hello")
    end

    expect(html).to include("window.tailwindReady = true;")
    expect(html).to include("<p>Hello</p>")
  end

  it "can render without injecting the Tailwind Play CDN" do
    html = described_class.render_page(title: "Local Page", include_play_cdn: false) do |main|
      main.tag(:p, "Hello")
    end

    expect(html).not_to include(Igniter::Plugins::View::Tailwind::PLAY_CDN_URL)
    expect(html).to include("<p>Hello</p>")
  end
end

RSpec.describe Igniter::Plugins::View::Tailwind::UI do
  it "renders reusable metric cards, panels, and status badges" do
    html = Igniter::Plugins::View.render do |view|
      view.component(described_class::MetricCard, label: "Alerts", value: 3, hint: "pending")
      view.component(described_class::Panel.new(title: "Control", subtitle: "Main surface") do |panel|
        panel.component(described_class::StatusBadge, label: "ready")
      end)
    end

    expect(html).to include("Alerts")
    expect(html).to include("pending")
    expect(html).to include("Control")
    expect(html).to include("Main surface")
    expect(html).to include("status-badge")
    expect(html).to include("ready")
  end

  it "renders reusable action bars, form sections, and key-value lists" do
    html = Igniter::Plugins::View.render do |view|
      view.component(described_class::ActionBar.new(tag: :nav) do |bar|
        bar.tag(:a, "Overview", href: "/overview")
        bar.tag(:a, "Devices", href: "/devices")
      end)

      view.component(described_class::FormSection.new(title: "Reminder", subtitle: "Fast create", action: "/reminders") do |form|
        form.label("task", "Task")
        form.input("task", id: "task")
        form.submit("Create")
      end)

      view.component(described_class::KeyValueList.new(rows: [["role", "dashboard"], ["port", 4569]]))
    end

    expect(html).to include("<nav")
    expect(html).to include("Overview")
    expect(html).to include("Devices")
    expect(html).to include("Reminder")
    expect(html).to include("Fast create")
    expect(html).to include('action="/reminders"')
    expect(html).to include("<dt")
    expect(html).to include("dashboard")
    expect(html).to include("4569")
  end
end
