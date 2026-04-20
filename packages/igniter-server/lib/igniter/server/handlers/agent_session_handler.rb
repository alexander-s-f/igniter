# frozen_string_literal: true

module Igniter
  module Server
    module Handlers
      class AgentSessionHandler < Base
        def initialize(registry, store, session_store:, mode:) # rubocop:disable Lint/UnusedMethodArgument
          super(registry, store)
          @session_store = session_store
          @mode = mode.to_sym
        end

        private

        def handle(params:, body:)
          require "igniter/agent"

          token = params.fetch(:token).to_s
          session = load_session(token, body)

          response =
            case @mode
            when :continue
              continue_session(session, body)
            when :resume
              resume_session(session, body)
            else
              raise ResolutionError, "Unsupported agent session mode '#{@mode}'"
            end

          json_ok(serialize_agent_response(response))
        end

        def load_session(token, body)
          return @session_store.fetch(token) if @session_store.exist?(token)

          raw = body["session"] || body[:session]
          raise ResolutionError, "Agent session payload is required" unless raw

          session = Igniter::Runtime::AgentSession.from_h(raw)
          raise ResolutionError, "Agent session token mismatch for '#{token}'" unless session.token.to_s == token

          @session_store.save(session)
        end

        def continue_session(session, body)
          payload = body["payload"] || body[:payload] || {}
          trace = body["trace"] || body[:trace]
          token = body["token"] || body[:token]
          waiting_on = body["waiting_on"] || body[:waiting_on]
          request = body["request"] || body[:request]
          reply = body["reply"] || body[:reply]
          phase = body["phase"] || body[:phase]

          continued = session.continue(
            payload: payload,
            trace: trace,
            token: token,
            waiting_on: waiting_on,
            request: request,
            reply: reply,
            phase: phase
          )
          @session_store.save(continued)

          {
            status: :pending,
            message: "continue",
            payload: continued.payload,
            agent_trace: continued.trace,
            agent_session: continued.to_h,
            deferred_result: Igniter::Runtime::DeferredResult.build(
              token: continued.token,
              payload: continued.payload,
              source_node: continued.source_node || continued.node_name,
              waiting_on: continued.waiting_on
            )
          }
        end

        def resume_session(session, body)
          trace = body["trace"] || body[:trace]
          reply = body["reply"] || body[:reply]
          value = if body.is_a?(Hash) && (body.key?("value") || body.key?(:value))
                    body["value"] || body[:value]
                  else
                    nil
                  end

          completed = session.complete(value: value, reply: reply, trace: trace)
          @session_store.delete(session.token)

          {
            status: :succeeded,
            output: value,
            agent_trace: completed.trace,
            agent_session: completed.to_h
          }
        end

        def serialize_agent_response(response)
          data = {
            status: response[:status].to_s,
            output: to_json_value(response[:output]),
            payload: to_json_value(response[:payload]),
            agent_trace: to_json_value(response[:agent_trace]),
            agent_session: to_json_value(response[:agent_session]),
            message: response[:message]
          }

          if response[:deferred_result]
            data[:deferred_result] = {
              token: response[:deferred_result].token,
              source_node: response[:deferred_result].source_node,
              waiting_on: response[:deferred_result].waiting_on,
              payload: to_json_value(response[:deferred_result].payload)
            }
          end

          data.compact
        end
      end
    end
  end
end
