# frozen_string_literal: true

module Igniter
  module Companion
    # Mixin that turns a plain Ruby class into a Record type backed by Store[T].
    #
    # DSL:
    #   store_name :reminders           # storage namespace key (defaults to lowercased class name)
    #   field :title                    # declares a readable attribute
    #   field :status, default: :open   # with default filled in on read
    #   scope :open, filters: { status: :open }
    #   scope :open, filters: {...}, cache_ttl: 30
    #
    # Usage via Igniter::Companion::Store:
    #   store.write(Reminder, key: "r1", title: "Buy milk")
    #   store.read(Reminder, key: "r1")   # => #<Reminder key="r1" title="Buy milk" status=:open>
    #   store.scope(Reminder, :open)       # => [#<Reminder ...>, ...]
    module Record
      def self.included(base)
        base.extend(ClassMethods)
        base.instance_variable_set(:@_fields, {})
        base.instance_variable_set(:@_scopes, {})
      end

      module ClassMethods
        def store_name(name = nil)
          if name
            @_store_name = name
          else
            @_store_name ||= self.name&.split("::")&.last&.downcase&.to_sym || :records
          end
        end

        def field(name, default: nil)
          @_fields ||= {}
          @_fields[name] = { default: default }
          attr_reader name
        end

        def scope(name, filters:, cache_ttl: nil)
          @_scopes ||= {}
          @_scopes[name] = { filters: filters, cache_ttl: cache_ttl }
        end

        def _fields; @_fields ||= {}; end
        def _scopes; @_scopes ||= {}; end

        def from_fact(fact)
          new(key: fact.key, **fact.value)
        end
      end

      # Build an anonymous Record class from a persistence_manifest hash.
      # Manifest structure (from app-local contract DSL):
      #   storage: { shape: :store, key: :id, adapter: ... }
      #   fields:  [{ name: :title, attributes: {} },
      #             { name: :status, attributes: { default: :open } }, ...]
      #   scopes:  [{ name: :open, attributes: { where: { status: :open } } }, ...]
      #
      # Usage:
      #   klass = Igniter::Companion::Record.from_manifest(manifest, store: :reminders)
      def self.from_manifest(manifest, store:)
        Class.new do
          include Igniter::Companion::Record
          store_name store

          manifest.fetch(:fields, []).each do |field_def|
            attrs = field_def.fetch(:attributes, {})
            if attrs.key?(:default)
              field field_def.fetch(:name), default: attrs.fetch(:default)
            else
              field field_def.fetch(:name)
            end
          end

          manifest.fetch(:scopes, []).each do |scope_def|
            filters = scope_def.fetch(:attributes, {}).fetch(:where, {})
            scope scope_def.fetch(:name), filters: filters
          end
        end
      end

      attr_reader :key

      def initialize(key:, **attrs)
        @key = key
        self.class._fields.each do |name, opts|
          val = attrs.key?(name) ? attrs[name] : opts[:default]
          instance_variable_set(:"@#{name}", val)
        end
      end

      def to_h
        self.class._fields.keys.each_with_object({}) do |name, h|
          h[name] = public_send(name)
        end
      end

      def inspect
        fields = self.class._fields.keys.map { |n| "#{n}=#{public_send(n).inspect}" }.join(" ")
        "#<#{self.class.name} key=#{@key.inspect} #{fields}>"
      end
    end
  end
end
