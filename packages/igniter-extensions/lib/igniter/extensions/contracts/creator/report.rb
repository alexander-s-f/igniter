# frozen_string_literal: true

require_relative "scaffold"

module Igniter
  module Extensions
    module Contracts
      module Creator
        class Report
          attr_reader :scaffold, :audit

          def initialize(scaffold:, audit: nil)
            @scaffold = scaffold
            @audit = audit
            freeze
          end

          def next_steps
            steps = [
              "fill in #{scaffold.pack_file_path} using only public Igniter::Contracts APIs",
              "run the generated spec and example",
              "use Igniter::Extensions::Contracts.audit_pack(...) before finalize"
            ]

            case scaffold.kind
            when :feature
              steps << "implement node kind, DSL keyword, validator, and runtime handler"
            when :operational
              steps << "implement effect and executor handlers with typed invocation contracts"
            when :bundle
              steps << "install dependency packs and keep the bundle free of hidden runtime mutation"
            end

            steps
          end

          def quality_bar
            {
              public_contracts_only: true,
              includes_spec: true,
              includes_example: true,
              includes_readme: true,
              audit_ok: audit&.ok?
            }
          end

          def to_h
            payload = {
              scaffold: scaffold.to_h,
              next_steps: next_steps,
              quality_bar: quality_bar
            }
            payload[:audit] = audit.to_h if audit
            payload
          end
        end
      end
    end
  end
end
