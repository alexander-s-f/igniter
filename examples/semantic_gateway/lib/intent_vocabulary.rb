# frozen_string_literal: true

module SemanticGateway
  # Human-facing vocabulary. Translates natural language signals into
  # structured agent protocol atoms.
  #
  # Unlike the LineUp vocabulary (agent↔agent), this vocabulary is tuned for
  # human natural language: informal, implicit, often ambiguous.
  # The small local LLM enriches what rule-based matching misses.

  module IntentVocabulary
    # --- What the human wants to DO ---

    # Order matters: more specific patterns first to avoid false matches.
    # "write docs" → :document (not :create). "make sure" → not :create.
    INTENTS = {
      :document => /\b(document|write docs|add docs|readme|annotate|write.*comment)\b/i,
      :review   => /\b(review|check|audit|analyze|look at|inspect|assess|verify)\b/i,
      :explain  => /\b(explain|describe|what is|how does|why is|help me understand|show me how)\b/i,
      :fix      => /\b(fix|debug|solve|repair|resolve|patch|correct|broken)\b/i,
      :deploy   => /\b(deploy|release|publish|ship|push|launch|go live)\b/i,
      :optimize => /\b(optim|speed up|faster|slow|latency|performance)\b/i,
      :test     => /\b(write.?test|add.?spec|add.?test|rspec|unit test|tdd)\b/i,
      :migrate  => /\b(migrat|upgrade|move to|convert|transition)\b/i,
      :refactor => /\b(refactor|cleanup|clean up|simplify|reorganize)\b/i,
      :create   => /\b(create|add|build|implement|set up|introduce|write|make)\b/i,
    }.freeze

    # --- Which domain ---

    DOMAINS = {
      :authentication => /\b(login|auth\w*|password|session|token|oauth|sign.?in|sign.?up|register)\b/i,
      :data_layer     => /\b(database|db|query|sql|model|schema|migration|record|table|index)\b/i,
      :frontend       => /\b(ui|page|form|button|component|view|css|html|template|layout|modal)\b/i,
      :api_layer      => /\b(api|endpoint|route|request|response|http|rest|json|webhook)\b/i,
      :infrastructure => /\b(deploy|infra|server|container|docker|k8s|kubernetes|nginx|config)\b/i,
      :ai_layer       => /\b(agent|llm|ai|model|prompt|embedding|vector|anthropic|openai)\b/i,
      :testing        => /\b(test|spec|rspec|coverage|ci|pipeline|fixture|factory)\b/i,
      :security       => /\b(security|vulnerab|injection|xss|csrf|permiss|access|role)\b/i,
    }.freeze

    # --- Implicit quality/style constraints in human language ---

    STYLE_SIGNALS = {
      :keep_simple             => /\b(simple|minimal|basic|nothing fancy|lightweight|straightforward|clean)\b/i,
      :production_grade        => /\b(production|robust|proper|solid|correct|reliable|enterprise)\b/i,
      :no_external_deps        => /\b(no external|no.?dependen|built-in|pure ruby|standard lib|no.?gem)\b/i,
      :follow_existing_pattern => /\b(like the other|same as|existing pattern|consistent|similar to|as we do)\b/i,
      :expedite                => /\b(quick|fast|asap|urgent|need it today|immediately|right now)\b/i,
      :no_breaking_changes     => /\b(no breaking|backward compat|don.?t break|keep working|without breaking)\b/i,
      :with_tests              => /\b(with test|add spec|include test|test.?covered|tdd)\b/i,
    }.freeze

    # --- Urgency ---

    URGENCY = {
      :high   => /\b(urgent|asap|immediately|critical|blocking|emergency|now)\b/i,
      :low    => /\b(when you can|no rush|eventually|sometime|low priority|whenever)\b/i,
      :normal => /./,   # default — matches everything
    }.freeze

    # --- Agent routing map ---
    # domain → which agents in the Igniter network handle it

    ROUTING = {
      :authentication => %i[agent_backend agent_application],
      :data_layer     => %i[agent_backend],
      :frontend       => %i[agent_web agent_frontend],
      :api_layer      => %i[agent_backend agent_application],
      :infrastructure => %i[agent_cluster],
      :ai_layer       => %i[agent_application agent_web],
      :testing        => %i[agent_backend agent_web],
      :security       => %i[agent_backend agent_application],
    }.freeze

    # Intents that fan out to all available agents
    BROADCAST_INTENTS = %i[review explain audit].freeze

    # --- Public API ---

    def self.extract_intent(text)
      INTENTS.each { |atom, pat| return atom if text.match?(pat) }
      :unknown
    end

    def self.extract_domains(text)
      DOMAINS.filter_map { |atom, pat| atom if text.match?(pat) }
    end

    def self.extract_style(text)
      STYLE_SIGNALS.filter_map { |atom, pat| atom if text.match?(pat) }
    end

    def self.extract_urgency(text)
      %i[high low normal].each { |level| return level if text.match?(URGENCY[level]) && level != :normal }
      :normal
    end

    def self.routing_for(domains, intent)
      return :broadcast if BROADCAST_INTENTS.include?(intent)

      agents = domains.flat_map { |d| ROUTING[d] }.compact.uniq
      agents.empty? ? %i[agent_application] : agents
    end
  end
end
