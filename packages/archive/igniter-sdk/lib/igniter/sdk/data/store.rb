# frozen_string_literal: true

module Igniter
  module Data
    class Store
      def put(collection:, key:, value:)
        raise NotImplementedError, "#{self.class}#put not implemented"
      end

      def get(collection:, key:)
        raise NotImplementedError, "#{self.class}#get not implemented"
      end

      def delete(collection:, key:)
        raise NotImplementedError, "#{self.class}#delete not implemented"
      end

      def all(collection:)
        raise NotImplementedError, "#{self.class}#all not implemented"
      end

      def keys(collection:)
        raise NotImplementedError, "#{self.class}#keys not implemented"
      end

      def clear(collection: nil)
        raise NotImplementedError, "#{self.class}#clear not implemented"
      end
    end
  end
end
