# frozen_string_literal: true

module Igniter
  module Events
    Event = Struct.new(
      :event_id,
      :type,
      :execution_id,
      :node_name,
      :path,
      :status,
      :payload,
      :timestamp,
      keyword_init: true
    )
  end
end
