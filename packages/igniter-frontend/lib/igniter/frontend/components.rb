# frozen_string_literal: true

module Igniter
  module Frontend
    Components = Igniter::Plugins::View::Arbre::Components unless const_defined?(:Components, false)
  end
end
