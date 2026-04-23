# frozen_string_literal: true

module Igniter
  class App
    module Evolution
      class Store
        def append(_event)
          raise NotImplementedError, "#{self.class}#append not implemented"
        end

        def load_events
          raise NotImplementedError, "#{self.class}#load_events not implemented"
        end

        def clear!
          raise NotImplementedError, "#{self.class}#clear! not implemented"
        end
      end
    end
  end
end
