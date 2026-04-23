# frozen_string_literal: true

require_relative "../core/legacy"

Igniter::Core::Legacy.without_warning do
  require_relative "../core/type_system"
end
