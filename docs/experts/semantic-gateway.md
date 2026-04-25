# Semantic Gateway — Human↔Agent Interaction via Local SAE-Inspired Pre-processing

**Type:** Experimental architecture [R]  
**Track:** Independent — does not touch agent-to-agent tracks  
**Status:** Design complete, prototype in `examples/semantic_gateway/`

---

## The Shift in Focus

Previous LineUp work modelled **Agent↔Agent** compression:
both sides share vocabulary, input is semi-structured, residue is technical.

This document models **Human↔Agent**:

```
Agent↔Agent:   structured handoff → structured response
Human↔Agent:   natural language → intent → agent network → UI response
```

The difference is the prompt residue:

| Aspect | Agent↔Agent | Human↔Agent |
|--------|-------------|-------------|
| Input structure | Handoff format | Unstructured prose |
| Vocabulary | Shared by both | Unknown to human |
| Intent | Explicit (task:/status:) | Implicit, often partial |
| Ambiguity | Low | High |
| Residue | Technical edge cases | Emotional tone, implicit preferences |
| Compression target | Token cost | Latency + relevance + routing |

**Key insight:** In Human↔Agent, the small local LLM is not a compressor —
it is an **interpreter** that bridges two fundamentally different languages:
human natural language and the Igniter agent protocol.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  HUMAN                                                           │
│  "I want to add a login page, keep it simple, email+password"   │
└─────────────────────────┬────────────────────────────────────────┘
                          │ natural language
              ┌───────────▼───────────┐
              │   SEMANTIC GATEWAY    │  LOCAL — RPi 5 / edge node
              │                       │
              │  1. Rule-based scan   │  instant, free
              │     ↓ partial intent  │
              │  2. Local LLM enrich  │  ~0.5s, free (Phi-3 Mini)
              │     ↓ full intent     │
              │  3. Vocabulary fold   │  deterministic
              │     ↓ compact form    │
              │  4. Route decision    │  which agent(s)?
              └───────────┬───────────┘
                          │ compact intent packet
          ┌───────────────▼───────────────────────┐
          │   IGNITER AGENT NETWORK               │
          │                                       │
          │   ┌──────────┐  ┌──────────┐         │
          │   │  Agent   │  │  Agent   │  ...    │
          │   │ frontend │  │ backend  │         │
          │   └──────────┘  └──────────┘         │
          │   Distributed, decentralized          │
          │   Each agent gets only its slice      │
          └───────────────┬───────────────────────┘
                          │ structured response
              ┌───────────▼───────────┐
              │   PROGRESSIVE UI      │  The new interaction layer
              │                       │
              │  • Shows intent parse │  "Did I understand correctly?"
              │  • Live agent status  │  which agents are working
              │  • Incremental output │  stream results as they arrive
              │  • Correction point   │  human can fix before expensive call
              └───────────────────────┘
```

---

## The Intent Vocabulary

Different from the handoff vocabulary. Human intents map to agent tasks:

```ruby
# What the human wants to DO
INTENTS = {
  create:   /\b(create|add|build|make|implement)\b/i,
  fix:      /\b(fix|debug|solve|repair|resolve)\b/i,
  explain:  /\b(explain|describe|what is|how does)\b/i,
  review:   /\b(review|check|audit|analyze)\b/i,
  deploy:   /\b(deploy|release|publish|ship)\b/i,
  refactor: /\b(remove|delete|cleanup|refactor|simplify)\b/i,
  test:     /\b(test|verify|validate|spec)\b/i,
  optimize: /\b(optimize|improve|speed up|faster)\b/i,
}

# Which domain
DOMAINS = {
  authentication: /\b(login|auth|password|session|token)\b/i,
  data_layer:     /\b(database|query|sql|model|schema)\b/i,
  frontend:       /\b(ui|page|form|button|component|view)\b/i,
  api_layer:      /\b(api|endpoint|route|request|response)\b/i,
  infrastructure: /\b(deploy|infra|server|container|k8s)\b/i,
  ai_layer:       /\b(agent|llm|ai|model|prompt)\b/i,
}

# Implicit quality constraints in human language
STYLE_SIGNALS = {
  keep_simple:            /\b(simple|minimal|basic|nothing fancy|lightweight)\b/i,
  production_grade:       /\b(production|robust|proper|solid|correct)\b/i,
  no_external_deps:       /\b(no external|no dependency|built-in|pure)\b/i,
  follow_existing_pattern:/\b(like the other|same as|existing pattern|consistent)\b/i,
  expedite:               /\b(quick|fast|asap|urgent|need it today)\b/i,
}
```

---

## The Intent Packet

What arrives at the large LLM and at each agent — not the original prose:

```ruby
intent(
  action:     :create,
  domain:     :authentication,
  subject:    "login_page",
  style:      [:keep_simple, :no_external_deps],
  urgency:    :normal,
  context:    { app_type: :web, framework: :igniter },
  route:      [:agent_frontend, :agent_backend],
  confidence: 0.89,
  residue:    nil   # nothing lost
)
```

vs. original: "I want to add a login page to my app but keep it simple,
nothing fancy, just email and password" — 26 tokens → 8 tokens in compact form.

---

## The Three-Stage Gateway

```
Stage 1: Rule-based scan (0ms, always runs)
  → Vocabulary pattern matching
  → Covers ~60% of common requests
  → If confidence > 0.85: done, skip LLM

Stage 2: Local LLM enrichment (200-800ms, RPi 5)
  → Phi-3 Mini / Qwen2.5-3B via ollama
  → Handles ambiguity, implicit context, novel phrasing
  → If confidence > 0.72: done

Stage 3: Transparency gate (before expensive API call)
  → Show parsed intent to human in UI
  → "I understood: create a simple login form with email+password. Correct?"
  → Human confirms or corrects — ZERO tokens wasted on misunderstanding
```

Stage 3 is the key UX innovation: the progressive UI shows the intent parse
before the expensive call. This is the **semantic preview** — human sees what
the agent network will receive, and can correct it before tokens are spent.

---

## Routing — Decentralized Agent Selection

The gateway also decides which agents receive the intent:

```ruby
ROUTING_RULES = {
  # domain → agents that handle it
  authentication: [:agent_backend, :agent_security],
  frontend:       [:agent_frontend],
  data_layer:     [:agent_backend, :agent_database],
  ai_layer:       [:agent_application, :agent_web],
  infrastructure: [:agent_cluster, :agent_deploy],
}

# Broadcast rules: some intents go to all agents
BROADCAST_INTENTS = %i[review explain audit]
```

Each agent receives only the **slice of the intent packet relevant to its domain**:

```ruby
# agent_frontend receives:
intent(action: :create, domain: :frontend, subject: "login_page",
       style: [:keep_simple], confidence: 0.89)

# agent_backend receives:
intent(action: :create, domain: :authentication, subject: "login_form_handler",
       style: [:keep_simple, :no_external_deps], confidence: 0.89)
```

This is decentralized by design — no central orchestrator sees the full picture.
The gateway routes; agents act independently with their slice.

---

## Progressive UI as Transparency Layer

The existing `igniter-plane` / `igniter-ui-kit` work becomes the rendering surface:

```
Human types:  "fix the slow query in orders"
              ↓ (real-time, 50ms)
UI shows:     ┌──────────────────────────────────────────┐
              │ Intent parsed:                           │
              │  action:  fix                            │
              │  domain:  data_layer                     │
              │  subject: orders query performance       │
              │  routing: → agent_backend                │
              │  confidence: 0.82                        │
              │                                          │
              │  [Confirm ✓]  [Clarify...]  [Edit]       │
              └──────────────────────────────────────────┘
              ↓ human confirms
              Sends 9 tokens to agent_backend
              (instead of 8-token original — but structured)
```

The UI displays:
- **Intent parse** — what was understood
- **Routing** — which agents will handle it
- **Confidence** — how sure the gateway is
- **Correction** — inline editing before sending

---

## Igniter Contract Design

```ruby
module SemanticGateway
  class Pipeline < Igniter::Contract
    define do
      input :human_text
      input :session_context, default: -> { SessionContext.new }
      input :vocabulary,      default: -> { IntentVocabulary }

      # Stage 1: Rule-based (instant)
      compute :rule_intent,  with: [:human_text, :vocabulary], call: RuleExtractor
      compute :needs_llm,    with: [:rule_intent],             call: ConfidenceGate

      # Stage 2: Local LLM enrichment (conditional)
      compute :llm_intent,   with: [:human_text, :rule_intent],
                             call: LocalLLMExtractor
      compute :merged_intent, with: [:rule_intent, :llm_intent, :needs_llm],
                              call: IntentMerger

      # Vocabulary fold + routing
      compute :folded,       with: [:merged_intent, :vocabulary], call: IntentFolder
      compute :route,        with: [:folded, :session_context],   call: Router

      # Output
      output :intent_packet, from: :folded
      output :agent_routes,  from: :route
      output :ui_preview,    from: :folded   # for the transparency gate
    end
  end
end
```

---

## Comparison: Old vs. New Model

```
OLD (Agent↔Agent):
  Agent A writes handoff → Agent B reads handoff
  Shared vocabulary, structured format, low ambiguity
  Local LLM: compress the handoff
  Value: token cost reduction

NEW (Human↔Agent):
  Human writes natural language → Gateway interprets → Agent network acts
  No shared vocabulary (human doesn't know agent atoms)
  Local LLM: interpret human intent + translate to agent protocol
  Value: token cost + latency + misunderstanding prevention + routing
```

The remaining residue is different:

```
Agent↔Agent residue: technical details that don't fit vocabulary atoms
Human↔Agent residue: emotional context, implicit assumptions, domain jargon
                      that the small model couldn't resolve → goes to large LLM
```

---

## What the Prompt Looks Like (Before vs. After)

**Before (raw human text → large LLM):**
```
User: "Hey, I want to add a login page to my app but keep it simple,
       nothing fancy, just email and password, I don't want to deal
       with OAuth or any third party stuff, just basic auth should work"
→ 52 tokens, ambiguous, no routing info, no structure
```

**After (intent packet → large LLM):**
```
intent(action: :create, domain: :authentication, subject: "login_page",
       style: [:keep_simple, :no_external_deps, :no_oauth],
       context: :web_app, confidence: 0.91)

Task: implement authentication.login_page
Constraints: email+password only, no third-party deps
```
→ 18 tokens, structured, routable, unambiguous

**The large LLM now spends zero tokens understanding intent — only reasoning about implementation.**

---

## Implementation Plan

| Step | File | Status |
|------|------|--------|
| Intent vocabulary | `examples/semantic_gateway/lib/intent_vocabulary.rb` | ✓ |
| Rule-based extractor | `examples/semantic_gateway/lib/rule_extractor.rb` | ✓ |
| Local LLM interface | `examples/semantic_gateway/lib/local_llm_extractor.rb` | ✓ |
| Intent packet struct | `examples/semantic_gateway/lib/intent_packet.rb` | ✓ |
| Gateway pipeline | `examples/semantic_gateway/lib/gateway.rb` | ✓ |
| Router | `examples/semantic_gateway/lib/router.rb` | ✓ |
| Demo | `examples/semantic_gateway/demo.rb` | ✓ |

The demo runs without an actual local LLM — uses a mock that shows
the structured output the LLM would produce. Plug in ollama to activate Stage 2.

---

## Open Questions

1. **What is the optimal model size for intent extraction on RPi 5?**
   Hypothesis: 3B parameters is the sweet spot — large enough for implicit intent,
   small enough for <500ms latency.

2. **Should the vocabulary be static or session-learned?**
   First sessions: static vocabulary. Later: the gateway learns user-specific
   atoms ("`simple` for this user always means `no_external_deps + no_new_package`").

3. **How does the UI correction feedback loop into the vocabulary?**
   Every human correction at the transparency gate is a vocabulary signal —
   the gateway misclassified something. Over N corrections → new atom candidate.

4. **Multi-agent routing consensus**
   When multiple agents receive sliced intents — how do they coordinate
   without a central orchestrator? Igniter's distributed contract model
   with `correlate_by` is the answer, but needs experiment.
