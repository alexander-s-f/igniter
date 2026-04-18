# frozen_string_literal: true

require "cgi"
require "spec_helper"
require "tmpdir"
require "igniter/plugins/view/arbre"

RSpec.describe "Igniter::Plugins::View::Arbre page authoring" do
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
          arbre_context.respond_to?(:assigns) ? arbre_context.assigns : {}
        end

        def helpers
          arbre_context.respond_to?(:helpers) ? arbre_context.helpers : nil
        end

        def current_arbre_element
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
          child = component_class.new(nil, self)
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

  it "renders breadcrumbs and cards through a developer-facing Arbre page shell" do
    stub_const("Arbre", build_fake_arbre)

    html = Igniter::Plugins::View::Arbre::Page.render_page(title: "Order Details", theme: :companion) do
      breadcrumbs do
        crumb :home, "/"
        crumb :orders, "/orders"
        crumb :"order_42", nil, current: true
      end

      card(title: "Metadata", subtitle: "Compact developer-authored view") do
        line :created_at, "2026-04-18"
        line :trace_id, "abc-123", as_code: true
      end
    end

    expect(html).to include("<!DOCTYPE html>")
    expect(html).to include("@tailwindcss/browser@4")
    expect(html).to include('aria-label="Breadcrumb"')
    expect(html).to include(">Home<")
    expect(html).to include(">Orders<")
    expect(html).to include('aria-current="page"')
    expect(html).to include(">Order 42<")
    expect(html).to include(">Metadata<")
    expect(html).to include("Compact developer-authored view")
    expect(html).to include(">Created At<")
    expect(html).to include(">Trace Id<")
    expect(html).to include("<code")
    expect(html).to include("abc-123")
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

      page_class = Class.new(Igniter::Plugins::View::ArbrePage) do
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
end
