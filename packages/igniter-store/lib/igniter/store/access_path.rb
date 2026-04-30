# frozen_string_literal: true

module Igniter
  module Store
    AccessPath = Struct.new(
      :store,
      :lookup,
      :scope,
      :filters,
      :cache_ttl,
      :consumers,
      keyword_init: true
    )
  end
end
