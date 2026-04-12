# frozen_string_literal: true

require "igniter/cluster"

module Companion
  # Raft state machine for replicated companion session state.
  #
  # State shape:
  #   {
  #     history: Array<{ role: String, content: String }>,  # conversation turns
  #     notes:   Hash<String, String>                       # persistent user notes
  #   }
  #
  # Supported commands:
  #   { op: :append_turn, role: "user"|"assistant", content: "..." }
  #   { op: :set_note,    key: "...", value: "..." }
  #   { op: :delete_note, key: "..." }
  #   { op: :clear_history }
  class SessionStateMachine < Igniter::Cluster::Consensus::StateMachine
    apply :append_turn do |state, cmd|
      entry   = { role: cmd[:role].to_s, content: cmd[:content].to_s }
      history = (state[:history] || []) + [entry]
      state.merge(history: history.last(40))  # cap: 20 exchanges
    end

    apply :set_note do |state, cmd|
      notes = (state[:notes] || {}).merge(cmd[:key].to_s => cmd[:value].to_s)
      state.merge(notes: notes)
    end

    apply :delete_note do |state, cmd|
      notes = (state[:notes] || {}).reject { |k, _| k == cmd[:key].to_s }
      state.merge(notes: notes)
    end

    apply :clear_history do |state, _cmd|
      state.merge(history: [])
    end
  end
end
