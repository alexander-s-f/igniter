# frozen_string_literal: true

module Igniter
  module PropertyTesting
    # Built-in convenience generators for property testing.
    #
    # Each method returns a callable (lambda) that produces a random value
    # when invoked. Pass these as values in the `generators:` hash to
    # ContractClass.property_test.
    #
    # @example
    #   G = Igniter::PropertyTesting::Generators
    #
    #   MyContract.property_test(
    #     generators: {
    #       price:    G.float(0.0..500.0),
    #       quantity: G.positive_integer(max: 100),
    #       label:    G.string(length: 3..10),
    #       active:   G.boolean
    #     },
    #     runs: 200
    #   )
    module Generators
      # @param min [Integer]
      # @param max [Integer]
      # @return [#call]
      def self.integer(min: -100, max: 100)
        -> { rand(min..max) }
      end

      # @param max [Integer]
      # @return [#call]
      def self.positive_integer(max: 1000)
        -> { rand(1..max) }
      end

      # @param range [Range<Float>]
      # @return [#call]
      def self.float(range = 0.0..1.0)
        -> { range.min + rand * (range.max - range.min) }
      end

      # @param length [Range<Integer>, Integer]
      # @param charset [Symbol] :alpha, :alphanumeric, :hex, :printable
      # @return [#call]
      def self.string(length: 1..20, charset: :alpha) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        chars = case charset
                when :alpha        then ("a".."z").to_a + ("A".."Z").to_a
                when :alphanumeric then ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
                when :hex          then ("0".."9").to_a + ("a".."f").to_a
                when :printable    then (32..126).map(&:chr)
                else raise ArgumentError, "Unknown charset: #{charset}"
                end

        lambda do
          len = length.is_a?(Range) ? rand(length) : length
          Array.new(len) { chars.sample }.join
        end
      end

      # Returns one of the supplied values at random.
      #
      # @param values [Array]
      # @return [#call]
      def self.one_of(*values)
        raise ArgumentError, "one_of requires at least one value" if values.empty?

        -> { values.sample }
      end

      # Generates an array of values produced by the given generator.
      #
      # @param generator [#call]
      # @param size [Range<Integer>, Integer]
      # @return [#call]
      def self.array(generator, size: 0..10)
        lambda do
          len = size.is_a?(Range) ? rand(size) : size
          Array.new(len) { generator.call }
        end
      end

      # @return [#call]
      def self.boolean
        -> { [true, false].sample }
      end

      # Wraps another generator, occasionally returning nil.
      #
      # @param generator [#call]
      # @param null_rate [Float] probability of nil (0.0..1.0)
      # @return [#call]
      def self.nullable(generator, null_rate: 0.1)
        -> { rand < null_rate ? nil : generator.call }
      end

      # Generates a Hash where each key maps to a generated value.
      #
      # @param fields [Hash{Symbol => #call}]
      # @return [#call]
      def self.hash_of(**fields)
        -> { fields.transform_values(&:call) }
      end

      # Always returns the same constant value. Useful for pinning one input
      # while randomising others.
      #
      # @param value [Object]
      # @return [#call]
      def self.constant(value)
        -> { value }
      end
    end
  end
end
