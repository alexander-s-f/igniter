# Semantic Gateway — Prototype

Standalone experiment. Does not modify the `igniter` gem.  
The original design note is private working material under `playgrounds/docs/`.

## What This Is

A local pre-processor that intercepts human natural language before it reaches
an expensive large LLM API. Inspired by Sparse Autoencoders (SAE) — extracts a
**sparse structured intent** from dense ambiguous prose, exactly as SAE extracts
sparse interpretable features from dense LLM activations.

**Focus shift vs. LineUp:** LineUp compressed Agent↔Agent handoffs (both sides share
vocabulary). This compresses **Human↔Agent** interaction — the human doesn't know
the agent vocabulary, and their input is unstructured, implicit, often ambiguous.

## Run

```bash
ruby examples/semantic_gateway/demo.rb         # all cases + session economics
ruby examples/semantic_gateway/demo.rb live    # interactive mode — type requests
ruby examples/semantic_gateway/demo.rb compare # side-by-side table only
```

No dependencies. Pure Ruby. Works without ollama (Stage 1 only).  
With ollama: `brew install ollama && ollama pull phi3:mini` — activates Stage 2.

## What We Found

Running against 6 real human request types:

| Case | Input | Packet | Ratio | Confidence |
|------|-------|--------|-------|------------|
| A — Clear, single domain | 32 tok | 31 tok | 1.03x | 100% |
| B — Vague but urgent | 20 tok | 17 tok | 1.18x | 90% |
| C — Multi-domain, technical | 32 tok | 17 tok | 1.88x | 90% |
| D — Ambiguous / minimal | 6 tok | 12 tok | 0.5x | 90% |
| E — Documentation request | 26 tok | 18 tok | 1.44x | 90% |
| F — AI-layer, complex | 33 tok | 17 tok | 1.94x | 65% |

Session economics (100 messages, 35% clarification rate without gateway):
- **Without gateway:** 5,283 tokens (including disambiguation back-and-forth)
- **With gateway:** 1,917 tokens (structured packets + shared vocabulary once)
- **Net saving:** 3,367 tokens/session (~64%)

### Three Key Findings

**1. The raw token count comparison understates the gain.**  
Case D (0.5x) looks worse. But "can you check the api?" → the agent still needs to
ask what "check" means and which API. The packet routes it immediately to the right
agents with action `:review` and domain `:api_layer` — no clarification needed.
Token count alone doesn't capture routing precision and eliminated ambiguity.

**2. Implicit style signals are the highest-value extraction.**  
"nothing fancy, just email and password" → `[:keep_simple, :no_external_deps]`.
These constraints are invisible to the large LLM in raw text — it has to infer them
from tone. The packet makes them explicit atoms, identical to how agents communicate
constraints in handoff documents.

**3. The SAE analogy holds empirically.**  
The small rule-based extractor acts like a sparse autoencoder encoder:
- Input: dense superposed human text (many concepts mixed together)
- Output: sparse concept list (only non-default features: action, domain, style)
- Property: universal constraints (like `normal` urgency) are suppressed — zero-marked

## Architecture

```
lib/
  intent_vocabulary.rb  — Human-facing vocabulary: intents, domains, style signals, routing
  intent_packet.rb      — IntentPacket struct with to_compact / to_report / token_count
  rule_extractor.rb     — Stage 1: rule-based extraction (instant, no LLM)
  local_llm_extractor.rb — Stage 2: local LLM enrichment via ollama (optional)
  gateway.rb            — Three-stage adaptive pipeline with confidence gate
demo.rb                 — 6 test cases + comparison + interactive mode
```

## The Three-Stage Pipeline

```
Stage 1: Rule-based (0ms, always runs)
  → Pattern matching on intents, domains, style signals
  → If confidence > 0.75: done

Stage 2: Local LLM enrichment (200-800ms, free — RPi 5 / edge node)
  → Phi-3 Mini / Qwen2.5-3B via ollama
  → Handles implicit intent, novel phrasing, multi-signal inference
  → If confidence > 0.72: done

Stage 3: Residue fallback
  → Low-confidence input preserved verbatim as residue
  → Large LLM sees the original text — zero information lost
```

## What the Packet Looks Like

```
# Raw human input (32 tokens):
"I want to add a login page to my app but keep it simple,
 nothing fancy, just email and password, no OAuth or third party stuff"

# Intent packet (compact form, 31 tokens, but fully structured):
intent(:create,auth+fron,login_page [simple],→backend,app_application,web_web,frontend,1.0)

# What each agent receives (sliced):
agent_frontend → intent(:create, frontend, "login_page", [keep_simple])
agent_backend  → intent(:create, authentication, "login_page", [keep_simple, no_external_deps])
```

The large LLM receives the packet, not the original prose.  
It spends zero tokens understanding intent — only reasoning about implementation.

## Progressive UI Integration

The gateway is designed for use with a transparency gate in the UI:

```
Human types: "fix the slow orders query asap"
             ↓ (50ms, before any API call)
UI shows:    Intent: fix | Domain: data_layer | Subject: orders
             Urgency: high | Route: → agent_backend
             [Confirm ✓] [Clarify...] [Edit]
             ↓ human confirms
             17 tokens sent to agent_backend (not 20 ambiguous tokens)
```

Every correction at the transparency gate = a vocabulary training signal.

## What Would Improve This

**Activate Stage 2 (local LLM):** Install ollama and pull `phi3:mini` or `qwen2.5:3b`.
The extractor prompt is in `local_llm_extractor.rb:EXTRACTION_PROMPT`. Tune it for
your specific vocabulary and use-case domain.

**Session-learned vocabulary:** After N user corrections, persist what "`simple`
means in context of this user/team" as a local vocabulary extension. The gateway
becomes more accurate per session.

**Igniter contract integration:** The gateway pipeline maps directly to an Igniter
Contract with `compute` nodes for each stage.

## Proposal for Igniter Integration

```
Proposal: igniter-gateway (or igniter-lineup stage 2)
Goal: first-class Human↔Agent semantic pre-processing

Requires:
  - IntentVocabulary (human-facing, complements agent-facing LineUp vocabulary)
  - LocalLLMExecutor (ollama/llama.cpp Igniter executor node)
  - GatewayContract (3-stage pipeline as Igniter dependency graph)
  - ConfidenceGate (guard node that decides stage escalation)
  - UIPreview output (for progressive UI transparency layer)

Not requires:
  - External LLM API for extraction (only for reasoning)
  - Changes to igniter-contracts or igniter-runtime
  - A parser or grammar validator
```
