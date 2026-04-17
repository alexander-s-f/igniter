# frozen_string_literal: true

require "igniter/cluster"

module Companion
  class SessionStateMachine < Igniter::Cluster::Consensus::StateMachine
    apply :append_turn do |state, cmd|
      entry = { role: cmd[:role].to_s, content: cmd[:content].to_s }
      history = (state[:history] || []) + [entry]
      state.merge(history: history.last(40))
    end

    apply :set_note do |state, cmd|
      notes = (state[:notes] || {}).merge(cmd[:key].to_s => cmd[:value].to_s)
      state.merge(notes: notes)
    end

    apply :delete_note do |state, cmd|
      notes = (state[:notes] || {}).reject { |key, _| key == cmd[:key].to_s }
      state.merge(notes: notes)
    end

    apply :clear_history do |state, _cmd|
      state.merge(history: [])
    end
  end
end
