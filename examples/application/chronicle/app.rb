# frozen_string_literal: true

require "uri"

require "igniter/application"

require_relative "services/decision_conflict_scanner"
require_relative "services/decision_session_store"
require_relative "services/decision_store"
require_relative "services/proposal_store"
require_relative "web/decision_compass"

module Chronicle
  APP_ROOT = File.expand_path(__dir__)
  DATA_ROOT = File.join(APP_ROOT, "data")

  def self.default_workdir
    ENV.fetch("CHRONICLE_WORKDIR", "/tmp/igniter_chronicle_poc")
  end

  def self.feedback_path(params)
    "/?#{URI.encode_www_form(params)}"
  end

  def self.result_feedback_path(result)
    feedback_param = result.success? ? :notice : :error
    feedback_path(
      {
        feedback_param => result.feedback_code,
        session: result.session_id,
        proposal: result.proposal_id,
        decision: result.decision_id,
        receipt: result.receipt_id
      }.compact
    )
  end

  def self.events_read_model(snapshot)
    recent = snapshot.recent_events.map do |event|
      decision_id = event.fetch(:decision_id) || "-"
      "#{event.fetch(:kind)}:#{event.fetch(:proposal_id)}:#{decision_id}:#{event.fetch(:status)}"
    end
    "proposal=#{snapshot.proposal_id || "none"} session=#{snapshot.session_id || "none"} status=#{snapshot.status} conflicts=#{snapshot.conflict_count} open=#{snapshot.open_conflict_count} receipt=#{snapshot.receipt_id || "none"} actions=#{snapshot.action_count} recent=#{recent.join("|")}"
  end

  def self.build(data_root: DATA_ROOT, workdir: Chronicle.default_workdir)
    Igniter::Application.rack_app(:chronicle, root: APP_ROOT, env: :test) do
      service(:chronicle) { App.new(data_root: data_root, workdir: workdir) }

      mount_web(
        :decision_compass,
        Web.decision_compass_mount,
        at: "/",
        capabilities: %i[screen command],
        metadata: { poc: true }
      )

      get "/events" do
        text Chronicle.events_read_model(service(:chronicle).snapshot)
      end

      get "/receipt" do
        text service(:chronicle).latest_receipt_text
      end

      post "/proposals/scan" do |params|
        result = service(:chronicle).scan_proposal(proposal_id: params.fetch("proposal_id", ""))
        redirect Chronicle.result_feedback_path(result)
      end

      post "/conflicts/acknowledge" do |params|
        result = service(:chronicle).acknowledge_conflict(
          session_id: params.fetch("session_id", ""),
          decision_id: params.fetch("decision_id", "")
        )
        redirect Chronicle.result_feedback_path(result)
      end

      post "/signoffs" do |params|
        result = service(:chronicle).sign_off(
          session_id: params.fetch("session_id", ""),
          signer: params.fetch("signer", "")
        )
        redirect Chronicle.result_feedback_path(result)
      end

      post "/signoffs/refuse" do |params|
        result = service(:chronicle).refuse_signoff(
          session_id: params.fetch("session_id", ""),
          signer: params.fetch("signer", ""),
          reason: params.fetch("reason", "")
        )
        redirect Chronicle.result_feedback_path(result)
      end

      post "/receipts" do |params|
        result = service(:chronicle).emit_receipt(
          session_id: params.fetch("session_id", ""),
          metadata: { source: :chronicle_web }
        )
        redirect Chronicle.result_feedback_path(result)
      end
    end
  end

  class App
    attr_reader :decisions, :proposals, :scanner, :sessions

    def initialize(data_root: DATA_ROOT, workdir: Chronicle.default_workdir)
      @decisions = Services::DecisionStore.new(root: File.join(data_root, "decisions"))
      @proposals = Services::ProposalStore.new(root: File.join(data_root, "proposals"))
      @scanner = Services::DecisionConflictScanner.new
      @sessions = Services::DecisionSessionStore.new(workdir: workdir)
    end

    def scan_proposal(proposal_id:)
      proposal = proposals.find(proposal_id)
      return unknown_proposal(proposal_id) unless proposal

      sessions.create_scan(proposal: proposal, decisions: decisions.all, scanner: scanner)
    end

    def acknowledge_conflict(session_id:, decision_id:)
      session_proposal(session_id) do |proposal|
        sessions.acknowledge_conflict(
          session_id: session_id,
          decision_id: decision_id,
          decisions: decisions.all,
          scanner: scanner,
          proposal: proposal
        )
      end
    end

    def sign_off(session_id:, signer:)
      session_proposal(session_id) do |proposal|
        sessions.sign_off(
          session_id: session_id,
          signer: signer,
          decisions: decisions.all,
          scanner: scanner,
          proposal: proposal
        )
      end
    end

    def refuse_signoff(session_id:, signer:, reason:)
      session_proposal(session_id) do |proposal|
        sessions.refuse_signoff(
          session_id: session_id,
          signer: signer,
          reason: reason,
          decisions: decisions.all,
          scanner: scanner,
          proposal: proposal
        )
      end
    end

    def emit_receipt(session_id:, metadata: {})
      sessions.emit_receipt(session_id: session_id, metadata: metadata)
    end

    def snapshot(recent_limit: 8)
      sessions.snapshot(recent_limit: recent_limit)
    end

    def events
      sessions.events
    end

    def latest_receipt_text
      path = sessions.latest_receipt_path
      path ? File.read(path) : ""
    end

    private

    def unknown_proposal(proposal_id)
      sessions.command_refusal(
        feedback_code: :chronicle_unknown_proposal,
        session_id: nil,
        proposal_id: proposal_id.to_s,
        decision_id: nil,
        status: :unknown_proposal
      )
    end

    def session_proposal(session_id)
      snapshot = sessions.snapshot
      if snapshot.session_id != session_id.to_s
        return sessions.command_refusal(
          feedback_code: :chronicle_unknown_session,
          session_id: session_id,
          proposal_id: nil,
          decision_id: nil,
          status: :unknown_session
        )
      end

      proposal = proposals.find(snapshot.proposal_id)
      return unknown_proposal(snapshot.proposal_id) unless proposal

      yield proposal
    end
  end
end
