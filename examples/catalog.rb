# frozen_string_literal: true

module IgniterExamples
  ROOT = File.expand_path("..", __dir__)

  Example = Struct.new(
    :id,
    :path,
    :summary,
    :smoke,
    :autonomous,
    :runnable,
    :timeout,
    :args,
    :expected_fragments,
    :skip_reason,
    keyword_init: true
  ) do
    def full_path
      File.expand_path(path, ROOT)
    end

    def command_args
      Array(args)
    end

    def smoke?
      smoke
    end

    def autonomous?
      autonomous
    end

    def runnable?
      runnable
    end

    def status
      return :smoke if smoke?
      return :manual if runnable?

      :unsupported
    end
  end

  ALL = [
    Example.new(
      id: "agents",
      path: "examples/agents.rb",
      summary: "Supervision, registry lookups, and stream loops.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["=== Supervised agents ===", "done=true"]
    ),
    Example.new(
      id: "agent_orchestration",
      path: "examples/agent_orchestration.rb",
      summary: "Current agent-node orchestration, deferred replies, and provenance.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["contract_status=pending", "lineage_reason=awaiting_review"]
    ),
    Example.new(
      id: "async_store",
      path: "examples/async_store.rb",
      summary: "Store-backed deferred execution and resume flow.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["pending_token=quote-100", "resumed_gross_total=180.0"]
    ),
    Example.new(
      id: "basic_pricing",
      path: "examples/basic_pricing.rb",
      summary: "Minimal contract with recomputation after input updates.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["gross_total=120.0", "updated_gross_total=180.0"]
    ),
    Example.new(
      id: "collection",
      path: "examples/collection.rb",
      summary: "Collection fan-out with per-item child results.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["keys=[1, 2]", ":status=>:succeeded"]
    ),
    Example.new(
      id: "collection_partial_failure",
      path: "examples/collection_partial_failure.rb",
      summary: "Partial-failure collection diagnostics and summaries.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: [
        "summary={:mode=>:collect, :total=>3, :succeeded=>2, :failed=>1, :status=>:partial_failure}",
        "failed_items={2=>{:type=>\"Igniter::ResolutionError\""
      ]
    ),
    Example.new(
      id: "composition",
      path: "examples/composition.rb",
      summary: "Nested contracts via compose.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["pricing={:pricing=>{:gross_total=>120.0}}"]
    ),
    Example.new(
      id: "contracts/aggregates",
      path: "examples/contracts/aggregates.rb",
      summary: "External lookup + aggregate packs composed in igniter-contracts.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["aggregate_total_amount=60", "aggregate_average_amount=20.0"]
    ),
    Example.new(
      id: "contracts/build_your_own_pack",
      path: "examples/contracts/build_your_own_pack.rb",
      summary: "Inline custom pack authoring over the public igniter-contracts API.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["custom_pack_slug=hello-igniter-contracts", "custom_pack_findings=missing_slug_sources"]
    ),
    Example.new(
      id: "contracts/build_effect_executor_pack",
      path: "examples/contracts/build_effect_executor_pack.rb",
      summary: "Inline custom effect/executor pack authoring over the public contracts API.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["custom_executor_output=15", "custom_result_entries=1"]
    ),
    Example.new(
      id: "contracts/compose_your_own_packs",
      path: "examples/contracts/compose_your_own_packs.rb",
      summary: "Inline pack composition with one custom pack depending on another.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["composed_pack_has_slug=true", "composed_pack_url=https://docs.example.test/hello-pack-composition"]
    ),
    Example.new(
      id: "contracts/commerce",
      path: "examples/contracts/commerce.rb",
      summary: "Applied commerce preset on top of igniter-contracts and external packs.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["commerce_grand_total=38.0", "execution_report_sections=baseline_summary,execution_report"]
    ),
    Example.new(
      id: "contracts/journal",
      path: "examples/contracts/journal.rb",
      summary: "External effect/executor operational pack on igniter-contracts.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["journal_execution_output=15", "journal_result_entries=1"]
    ),
    Example.new(
      id: "contracts/migration",
      path: "examples/contracts/migration.rb",
      summary: "Side-by-side legacy core vs igniter-contracts migration comparison.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["migration_match=true", "updated_match=true"]
    ),
    Example.new(
      id: "contracts/three_layer_migration",
      path: "examples/contracts/three_layer_migration.rb",
      summary: "Legacy core, raw contracts, and preset-based contracts compared on one use case.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["preset_grand_total=38.0", "three_layer_match=true"]
    ),
    Example.new(
      id: "consensus",
      path: "examples/consensus.rb",
      summary: "Consensus-style bid selection across competing vendors.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Igniter::Cluster::Consensus Demo", "Winner: vendor=betacor"]
    ),
    Example.new(
      id: "dataflow",
      path: "examples/dataflow.rb",
      summary: "Incremental collections and maintained aggregates.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["PART 1", "PART 2"]
    ),
    Example.new(
      id: "diagnostics",
      path: "examples/diagnostics.rb",
      summary: "Text diagnostics and machine-readable result output.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Diagnostics PriceContract", ":outputs=>{:gross_total=>120.0}"]
    ),
    Example.new(
      id: "differential",
      path: "examples/differential.rb",
      summary: "Primary-vs-shadow differential execution.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Differential Execution Demo"]
    ),
    Example.new(
      id: "distributed_server",
      path: "examples/distributed_server.rb",
      summary: "Distributed await/deliver_event workflow over a store.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["pending=true", "success=true"]
    ),
    Example.new(
      id: "distributed_workflow",
      path: "examples/distributed_workflow.rb",
      summary: "Correlated await workflow that aggregates external events.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["==> Starting execution...", "success? true"]
    ),
    Example.new(
      id: "effects",
      path: "examples/effects.rb",
      summary: "Effect nodes, registry lookup, and saga compensation.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["HAPPY PATH", "Compensations:"]
    ),
    Example.new(
      id: "incremental",
      path: "examples/incremental.rb",
      summary: "Incremental recomputation with backdating and memoization.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Igniter Incremental Computation Demo", "fully_memoized? true"]
    ),
    Example.new(
      id: "introspection",
      path: "examples/introspection.rb",
      summary: "Compiled graph text, Mermaid output, plans, and runtime explain output.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["=== Graph Text ===", "runtime_state={:status=>:succeeded, :value=>120.0}"]
    ),
    Example.new(
      id: "invariants",
      path: "examples/invariants.rb",
      summary: "Invariant checks plus property-based testing.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["HAPPY PATH", "PROPERTY TEST"]
    ),
    Example.new(
      id: "llm/research_agent",
      path: "examples/llm/research_agent.rb",
      summary: "Research flow with LLM executors and awaited search results.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Research Agent Example", "Done!"]
    ),
    Example.new(
      id: "llm/tool_use",
      path: "examples/llm/tool_use.rb",
      summary: "Offline LLM tool-use pipeline with a mock provider.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["=== Feedback Triage Pipeline ===", "response=We have logged this issue"]
    ),
    Example.new(
      id: "llm_tools",
      path: "examples/llm_tools.rb",
      summary: "Tool declarations, capability guards, and registry export.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Igniter::Tool Demo", "Done."]
    ),
    Example.new(
      id: "marketing_ergonomics",
      path: "examples/marketing_ergonomics.rb",
      summary: "Ergonomic DSL helpers on a compact domain graph.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Plan MarketingQuoteContract", "outbox=["]
    ),
    Example.new(
      id: "mesh",
      path: "examples/mesh.rb",
      summary: "Static mesh routing and remote-node behaviour.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Mesh configured with 2 peers:"]
    ),
    Example.new(
      id: "mesh_gossip",
      path: "examples/mesh_gossip.rb",
      summary: "Peer convergence through gossip without seed access.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Scenario 2", "Convergence achieved without seed: true"]
    ),
    Example.new(
      id: "order_pipeline",
      path: "examples/order_pipeline.rb",
      summary: "Guard + collection + branch + export pipeline.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["order_subtotal=199.96", "error=Order cannot be placed: items are out of stock"]
    ),
    Example.new(
      id: "provenance",
      path: "examples/provenance.rb",
      summary: "Output provenance and trace visibility.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Provenance Demo"]
    ),
    Example.new(
      id: "reactive_auditing",
      path: "examples/reactive_auditing.rb",
      summary: "Reactive hooks plus audit timeline snapshots.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["effect_values=[120.0, 180.0]", "invalidations=[:order_total]"]
    ),
    Example.new(
      id: "ringcentral_routing",
      path: "examples/ringcentral_routing.rb",
      summary: "Webhook routing via branch plus nested collection fan-out.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Plan RingcentralWebhookContract", "status_route_branch=CallConnected"]
    ),
    Example.new(
      id: "saga",
      path: "examples/saga.rb",
      summary: "Saga compensation walkthrough.",
      smoke: true,
      autonomous: true,
      runnable: true,
      timeout: 10,
      expected_fragments: ["Saga Demo"]
    ),
    Example.new(
      id: "llm/call_center_analysis",
      path: "examples/llm/call_center_analysis.rb",
      summary: "Transcription + analysis flow for a supplied audio URL.",
      smoke: false,
      autonomous: false,
      runnable: true,
      timeout: 20,
      skip_reason: "requires an <audio_url> argument"
    ),
    Example.new(
      id: "mesh_discovery",
      path: "examples/mesh_discovery.rb",
      summary: "Dynamic mesh discovery from a seed registry.",
      smoke: false,
      autonomous: false,
      runnable: false,
      timeout: 10,
      skip_reason: "needs a refresh for the current mesh router API"
    ),
    Example.new(
      id: "server/node1",
      path: "examples/server/node1.rb",
      summary: "Long-lived orchestrator server for the two-node demo.",
      smoke: false,
      autonomous: false,
      runnable: false,
      timeout: 10,
      skip_reason: "legacy server entrypoint; multi-terminal demo not wired into the runner yet"
    ),
    Example.new(
      id: "server/node2",
      path: "examples/server/node2.rb",
      summary: "Long-lived sentiment-analysis server for the two-node demo.",
      smoke: false,
      autonomous: false,
      runnable: false,
      timeout: 10,
      skip_reason: "legacy server entrypoint; multi-terminal demo not wired into the runner yet"
    ),
    Example.new(
      id: "elocal_webhook",
      path: "examples/elocal_webhook.rb",
      summary: "Placeholder stub reserved for the eLocal webhook walkthrough.",
      smoke: false,
      autonomous: false,
      runnable: false,
      timeout: 10,
      skip_reason: "placeholder stub with no executable scenario yet"
    )
  ].freeze

  def self.all
    ALL
  end

  def self.smoke
    ALL.select(&:smoke?)
  end

  def self.autonomous
    ALL.select(&:autonomous?)
  end

  def self.find(name)
    normalized = normalize(name)

    ALL.find do |example|
      normalize(example.id) == normalized ||
        normalize(example.path) == normalized ||
        normalize(example.path.sub(%r{\Aexamples/}, "")) == normalized
    end
  end

  def self.normalize(name)
    value = name.to_s
    value = value.sub(%r{\Aexamples/}, "")
    value = value.delete_prefix("./")
    value = value.sub(/\.rb\z/, "")
    value
  end
end
