# frozen_string_literal: true

module LineUp
  # Domain vocabulary for the Igniter project.
  #
  # Maps surface text to compact semantic atoms. The vocabulary is the shared
  # context that makes Line-Up compression economical — without it, every message
  # must carry its own definitions.
  #
  # Adding a concept here reduces every future message that uses it by
  # (prose_tokens - 1 atom). The registry pays for itself across sessions.

  module Vocabulary
    # --- Roles ---

    ROLES = {
      /architect.supervisor/i          => :supervisor,
      /\[architect supervisor/i        => :supervisor,
      /research.horizon/i              => :researcher,
      /\[research horizon/i            => :researcher,
      /agent.application/i             => :agent_application,
      /\[agent application/i           => :agent_application,
      /agent.web/i                     => :agent_web,
      /\[agent web/i                   => :agent_web,
      /agent.contracts/i               => :agent_contracts,
      /\[agent contracts/i             => :agent_contracts,
      /agent.embed/i                   => :agent_embed,
      /\[agent embed/i                 => :agent_embed,
      /agent.cluster/i                 => :agent_cluster,
      /\[agent cluster/i               => :agent_cluster,
      /external.expert/i               => :external_expert,
      /\[external expert/i             => :external_expert,
    }.freeze

    # --- Concepts ---

    CONCEPTS = {
      /handoff.doctrine/i              => :handoff_doctrine,
      /interaction.doctrine/i          => :interaction_doctrine,
      /runtime.observatory/i           => :runtime_observatory,
      /observation.frame/i             => :observation_frame,
      /capsule.transfer/i              => :capsule_transfer,
      /host.activation/i               => :host_activation,
      /transfer.receipt/i              => :transfer_receipt,
      /transfer.bundle/i               => :transfer_bundle,
      /assembly.plan/i                 => :assembly_plan,
      /handoff.manifest/i              => :handoff_manifest,
      /interaction.kernel/i            => :interaction_kernel,
      /grammar.compress/i              => :grammar_compression,
      /line.up/i                       => :line_up,
      /constraint.set/i                => :constraint_set,
      /track.lifecycle/i               => :track_lifecycle,
      /plastic.cell/i                  => :plastic_cell,
      /cell.mutation/i                 => :cell_mutation,
      /igniter.web/i                   => :igniter_web,
      /igniter.application/i           => :igniter_application,
      /igniter.cluster/i               => :igniter_cluster,
      /rack.host/i                     => :rack_host,
      /interactive.poc/i               => :interactive_poc,
      /feedback.track/i                => :feedback_track,
      /action.log/i                    => :action_log,
      /read.model/i                    => :read_model,
      /capsule.inspection/i            => :capsule_inspection,
      /human.sugar/i                   => :human_sugar_dsl,
      /contractable/i                  => :contractable,
      /step.result/i                   => :step_result_pack,
    }.freeze

    # --- Frames (event/action types) ---

    FRAMES = {
      /\blanded\b/i                    => :task_completion,
      /\baccepted\b/i                  => :supervisor_acceptance,
      /\brejected\b/i                  => :supervisor_rejection,
      /\bdeferred\b/i                  => :deferral,
      /\bblocked\b/i                   => :blocker,
      /\bproposed\b/i                  => :proposal,
      /\bresearch\b/i                  => :research_activity,
      /docs.only/i                     => :documentation_only,
      /read.only/i                     => :read_only_boundary,
      /handoff/i                       => :ownership_transfer,
      /graduation/i                    => :graduation,
      /doctrine/i                      => :doctrine_definition,
      /pressure.test/i                 => :pressure_testing,
      /verification.*pass/i            => :verification_success,
      /verification.*fail/i            => :verification_failure,
    }.freeze

    # --- Constraint patterns → { atom, kind }
    # kind: :must  = this must hold (positive requirement)
    # kind: :forbid = this must NOT happen (prohibition)

    CONSTRAINT_PATTERNS = [
      [/no.new.package/i,               :no_new_package,           :forbid],
      [/no.*shared.*runtime|no.runtime/i, :no_runtime,             :forbid],
      [/no.*browser.transport/i,        :no_browser_transport,     :forbid],
      [/no.*sse|no.*live.update/i,      :no_sse,                   :forbid],
      [/no.*session|no.*cookie/i,       :no_session_framework,     :forbid],
      [/no.*cluster.plac/i,             :no_cluster_placement,     :forbid],
      [/no.*ai.provider|no.*llm/i,      :no_ai_provider,           :forbid],
      [/no.*agent.execut/i,             :no_agent_execution,       :forbid],
      [/no.*workflow.engine/i,          :no_workflow_engine,       :forbid],
      [/no.*ui.kit/i,                   :no_ui_kit,                :forbid],
      [/no.*generator/i,                :no_generator,             :forbid],
      [/no.*mutation|no.*mutate/i,      :no_mutation,              :forbid],
      [/no.*host.activation\b(?!.*(plan|read|check))/i, :no_activation_execution, :forbid],
      # positive requirements
      [/docs.only|documentation.only/i, :docs_only,                :must],
      [/read.only/i,                    :read_only,                :must],
      [/dry.run/i,                      :dry_run_first,            :must],
      [/interactive_poc_guardrails/i,   :interactive_poc_guardrails, :must],
      [/activation_safety/i,            :activation_safety,        :must],
      [/research_only/i,                :research_only,            :must],
    ].freeze

    # --- Named constraint sets (folding map) ---
    # When an extracted forbid/must list contains enough atoms from a set,
    # replace them with the set name. This is where compression becomes economic:
    # ":docs_only_scope" is 1 atom vs 6 individual prohibitions.

    CONSTRAINT_SETS = {
      docs_only_scope: {
        atoms:     %i[docs_only read_only no_runtime no_browser_transport
                      no_cluster_placement no_ai_provider no_agent_execution
                      no_workflow_engine no_new_package no_session_framework],
        threshold: 3   # fold if >= 3 atoms from this set are present
      },
      interactive_poc_guardrails: {
        atoms:     %i[no_ui_kit no_sse no_session_framework no_generator
                      no_runtime no_new_package],
        threshold: 3
      },
      activation_safety: {
        atoms:     %i[no_mutation no_activation_execution read_only dry_run_first],
        threshold: 2
      }
    }.freeze

    # Fold a list of atoms into named sets where threshold is met.
    # Returns { sets: [:name, ...], remainder: [:ungrouped, ...] }
    def self.fold_constraints(atoms)
      remaining = atoms.dup
      sets      = []

      CONSTRAINT_SETS.each do |name, config|
        overlap = config[:atoms] & remaining
        next if overlap.length < config[:threshold]

        sets      << name
        remaining  = remaining - config[:atoms]
      end

      { sets: sets, remainder: remaining }
    end

    # --- Public API ---

    def self.lookup_role(text)
      ROLES.each { |pat, atom| return atom if text.match?(pat) }
      nil
    end

    def self.lookup_concepts(text)
      CONCEPTS.filter_map { |pat, atom| atom if text.match?(pat) }.uniq
    end

    def self.lookup_frames(text)
      FRAMES.filter_map { |pat, atom| atom if text.match?(pat) }.uniq
    end

    def self.recognize_constraints(text)
      # Normalize newlines → spaces so multi-line "No X,\nY,\nZ" clauses match.
      flat = text.gsub(/\s+/, " ")
      must   = []
      forbid = []
      CONSTRAINT_PATTERNS.each do |pat, atom, kind|
        next unless flat.match?(pat)

        kind == :must ? must << atom : forbid << atom
      end
      { must: must.uniq, forbid: forbid.uniq }
    end

    # Find all roles mentioned (not just sender/recipient)
    def self.all_roles(text)
      ROLES.filter_map { |pat, atom| atom if text.match?(pat) }.uniq
    end

    # Detect the primary subject: track filename, doctrine name, or concept
    def self.detect_subject(text)
      # Track file reference
      if (m = text.match(/track:\s*([^\n]+)/i))
        return m[1].strip.sub(%r{docs/dev/}, "").sub(/-track\.md$/, "").gsub("-", "_")
      end
      # Track: label (prose format)
      if (m = text.match(/^Track:\s*([^\n]+)/i))
        return m[1].strip.sub(%r{docs/dev/}, "").sub(/-track\.md$/, "").gsub("-", "_")
      end
      # Named concept
      CONCEPTS.each { |pat, atom| return atom.to_s if text.match?(pat) }
      nil
    end
  end
end
