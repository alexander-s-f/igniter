# frozen_string_literal: true

require "cgi"
require "spec_helper"
require "tmpdir"
require "igniter-frontend"

RSpec.describe "Igniter::Frontend::Arbre page authoring" do
  def build_fake_arbre
    Module.new do
      registry = {}
      const_set(:REGISTRY, registry)

      tag_class = Class.new do
        attr_reader :children

        def initialize(name = nil, parent = nil)
          @name = name
          @parent = parent
          @arbre_context = parent.respond_to?(:arbre_context) ? parent.arbre_context : self
          @children = []
          @attributes = {}
        end

        def self.builder_method(name)
          ::Arbre::REGISTRY[name.to_sym] = self
        end

        def build(attributes = {})
          apply_attributes(attributes)
          self
        end

        def <<(child)
          @children << child
          child
        end

        def add_child(child)
          self << child
        end

        def add_class(value)
          merged = [@attributes["class"], value].compact.join(" ").strip
          @attributes["class"] = merged unless merged.empty?
        end

        def set_attribute(name, value)
          @attributes[name.to_s] = value unless value.nil?
        end

        attr_reader :arbre_context

        def text_node(value)
          @children << CGI.escape_html(value.to_s)
        end

        def assigns
          return @assigns if instance_variable_defined?(:@assigns)
          return {} if arbre_context.equal?(self)

          arbre_context.respond_to?(:assigns) ? arbre_context.assigns : {}
        end

        def helpers
          return @helpers if instance_variable_defined?(:@helpers)
          return nil if arbre_context.equal?(self)

          arbre_context.respond_to?(:helpers) ? arbre_context.helpers : nil
        end

        def current_arbre_element
          return self if arbre_context.equal?(self)

          arbre_context.respond_to?(:current_arbre_element) ? arbre_context.current_arbre_element : self
        end

        def with_current_arbre_element(element, &block)
          if arbre_context.respond_to?(:with_current_arbre_element)
            arbre_context.with_current_arbre_element(element, &block)
          else
            yield
          end
        end

        def method_missing(name, *args, **kwargs, &block)
          if respond_to?(:current_arbre_element) && current_arbre_element && current_arbre_element != self &&
             current_arbre_element.respond_to?(name)
            return current_arbre_element.public_send(name, *args, **kwargs, &block)
          end

          return assigns[name.to_sym] if respond_to?(:assigns) && assigns.key?(name.to_sym)
          return helpers.public_send(name, *args, **kwargs, &block) if respond_to?(:helpers) && helpers&.respond_to?(name)

          component_class = ::Arbre::REGISTRY[name.to_sym]
          return build_component(component_class, *args, **kwargs, &block) if component_class

          tag(name, *args, **kwargs, &block)
        end

        def respond_to_missing?(name, include_private = false)
          ::Arbre::REGISTRY.key?(name.to_sym) || super
        end

        def tag(name, *args, **kwargs, &block)
          content, attributes = extract_content_and_attributes(args, kwargs)
          child = ::Arbre::Tag.new(name.to_s, self)
          child.build(attributes)
          child.text_node(content) unless content.nil?
          with_child_context(child) { child.instance_exec(&block) } if block
          self << child
        end

        def to_s
          render_node
        end

        private

        def build_component(component_class, *args, **kwargs, &block)
          initialize_arity = component_class.instance_method(:initialize).arity
          child = if initialize_arity.zero?
                    component_class.new
                  elsif initialize_arity == 1 || initialize_arity.negative?
                    component_class.new(arbre_context)
                  else
                    component_class.new(nil, self)
                  end
          child.parent = self if child.respond_to?(:parent=)
          self << child
          with_child_context(child) { child.build(*args, **kwargs, &block) }
          child
        end

        def with_child_context(child)
          return yield unless respond_to?(:with_current_arbre_element)

          with_current_arbre_element(child) { yield }
        end

        def apply_attributes(attributes)
          attributes.each do |key, value|
            next if value.nil?

            @attributes[key.to_s] = value
          end
        end

        def extract_content_and_attributes(args, kwargs)
          attributes = kwargs.dup
          content = nil

          if args.first.is_a?(Hash)
            attributes = args.shift.merge(attributes)
          elsif args.first
            content = args.shift
          end

          [content, attributes]
        end

        def render_node
          opening = +"<#{tag_name}"
          @attributes.each do |key, value|
            next if value.nil?

            escaped = CGI.escape_html(value.to_s)
            opening << %( #{key}="#{escaped}")
          end
          opening << ">"
          inner = @children.map { |child| child.is_a?(String) ? child : child.to_s }.join
          "#{opening}#{inner}</#{tag_name}>"
        end

        def tag_name
          @name || self.class.name.split("::").last.downcase
        end
      end

      const_set(:Tag, tag_class)

      context_class = Class.new(tag_class) do
        def initialize(assigns = {}, helpers = nil, &block)
          super(nil, nil)
          @assigns = assigns.transform_keys(&:to_sym)
          @helpers = helpers
          @current_arbre_element_buffer = [self]
          instance_exec(&block) if block
        end

        def to_s
          @children.map { |child| child.is_a?(String) ? child : child.to_s }.join
        end

        attr_reader :helpers, :assigns

        def current_arbre_element
          @current_arbre_element_buffer.last
        end

        def with_current_arbre_element(element)
          @current_arbre_element_buffer << element
          yield
        ensure
          @current_arbre_element_buffer.pop
        end
      end

      component_class = Class.new(tag_class) do
        def initialize(_name = nil, parent = nil)
          super(nil, parent)
        end
      end

      const_set(:Context, context_class)
      const_set(:Component, component_class)
    end
  end

  it "renders a developer-facing Arbre page shell around a fragment" do
    stub_const("Arbre", build_fake_arbre)

    html = Igniter::Frontend::Arbre::Page.render_page(title: "Order Details", theme: :companion) do
      nav("Home / Orders / Order 42", "aria-label": "Breadcrumb")

      article(class: "panel span-4") do
        h2 "Metadata"
        div "Compact developer-authored view"
        dl do
          dt "Created At"
          dd "2026-04-18"
          dt "Trace Id"
          dd { code "abc-123" }
        end
      end
    end

    expect(html).to include("<!DOCTYPE html>")
    expect(html).to include("@tailwindcss/browser@4")
    expect(html).to include('aria-label="Breadcrumb"')
    expect(html).to include(">Metadata<")
    expect(html).to include("Compact developer-authored view")
    expect(html).to include(">Created At<")
    expect(html).to include(">Trace Id<")
    expect(html).to include("<code")
    expect(html).to include("abc-123")
  end

  it "renders plain Arbre sections for developer-authored dashboards" do
    stub_const("Arbre", build_fake_arbre)

    html = Igniter::Frontend::Arbre::Page.render_page(title: "Lab", theme: :companion) do
      section(class: "hero") do
        div "Operator", class: "eyebrow"
        h1 "HomeLab"
        div "Developer-authored screen"
        div(class: "meta") do
          text_node "node=seed"
        end
        div(class: "actions") do
          a "Overview API", href: "/api/overview", class: "button secondary"
        end
        div "Last demo: healthy_lab", class: "ok"
      end

      article(class: "panel span-4") do
        h2 "Topology Health"
        span "healthy", class: "pill"
      end
    end

    expect(html).to include(">Operator<")
    expect(html).to include(">HomeLab<")
    expect(html).to include("Developer-authored screen")
    expect(html).to include("node=seed")
    expect(html).to include("Overview API")
    expect(html).to include("Last demo: healthy_lab")
    expect(html).to include("Topology Health")
    expect(html).to include(">healthy<")
    expect(html).to include('class="panel span-4"')
  end

  it "renders an Arbre template with layout and page helpers" do
    stub_const("Arbre", build_fake_arbre)

    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "layout.arb"), <<~ARB)
        html do
          body do
            section class: "layout-shell" do
              h1 page_title
              render_template_content
            end
          end
        end
      ARB

      File.write(File.join(dir, "home_page.arb"), <<~ARB)
        article class: "summary" do
          h2 page_context.fetch(:title)
          div helper_summary
        end
      ARB

      page_class = Class.new(Igniter::Frontend::ArbrePage) do
        template_root dir
        template "home_page"
        layout "layout"

        def initialize(context:)
          @context = context
        end

        def template_locals
          { page_context: @context }
        end

        def page_title
          "Human Home"
        end

        def helper_summary
          "Developer-authored template"
        end
      end

      html = page_class.render(context: { title: "Lab Overview" })

      expect(html).to include("Human Home")
      expect(html).to include("Lab Overview")
      expect(html).to include("Developer-authored template")
      expect(html).to include("layout-shell")
      expect(html).to include("summary")
    end
  end

  it "renders mounted frontend javascript tags from the layout" do
    stub_const("Arbre", build_fake_arbre)

    route_context = Struct.new(:base_path) do
      def route(suffix)
        "#{base_path}#{suffix}"
      end
    end

    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "layout.arb"), <<~ARB)
        html do
          body do
            render_template_content
            render_frontend_javascript "application"
          end
        end
      ARB

      File.write(File.join(dir, "home_page.arb"), <<~ARB)
        article class: "summary" do
          h2 "Frontend JS"
        end
      ARB

      page_class = Class.new(Igniter::Frontend::ArbrePage) do
        template_root dir
        template "home_page"
        layout "layout"

        def initialize(context:)
          @context = context
        end
      end

      html = page_class.render(context: route_context.new("/dashboard"))

      expect(html).to include("/dashboard/__frontend/runtime.js")
      expect(html).to include("/dashboard/__frontend/assets/application.js")
      expect(html).to include("summary")
    end
  end
end
