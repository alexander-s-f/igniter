# Two Worlds: SparkCRM and Igniter

Status: active guiding reference
Date: 2026-05-24
Scope: all lanes and agents working at the Spark x Igniter boundary

---

## Why This Document Exists

SparkCRM and Igniter are moving toward each other. That movement can either
**close the delta** (convergence) or **widen it** (divergence). Without a
shared map, agents tend to drift:

- Building Igniter APIs in isolation without SparkCRM domain pressure → abstract
  shapes that don't fit real data when integration arrives.
- Pulling SparkCRM closer to Igniter vocabulary before a shadow proof exists →
  premature coupling that destabilizes production behavior.
- Designing cross-project ceremony (letters, portfolio reports, fixture updates)
  as a substitute for working code → process churn that looks like progress.

This document is the guiding rail. When work at the boundary starts, read this
first.

---

## The Two Worlds

### World 1 — SparkCRM

**What it is:** A production Rails multi-tenant SaaS for service businesses
(HVAC, etc.). Real customers, real transactions, real data.

**Authority:** SparkCRM legacy behavior is authoritative. It does not change to
match Igniter. It adopts Igniter only after proof.

**Stack:** Rails 7, Hotwire/Turbo/Stimulus, Arbre + Tailwind (UI), Sidekiq
(jobs), dual PostgreSQL (primary + analytics), MCP server at production
endpoint, `acts_as_tenant` multi-tenancy.

**Domain gravity:** The domain models that matter for convergence:
- `Vendor` / `TradeVendor` → future `LeadChannel` / `ChannelConfig`
- Availability/scheduling ledgers → future `igniter-ledger` substrate
- Service call price ledger → future `igniter-ledger` + durable model
- Background services in `app/services/` → future contractable wrappers
- MCP tools returning production reads → future Ledger Open Protocol reads

**Current convergence posture:** `primary_observed_only`. No shadow candidates.
No Igniter-backed authority surfaces yet.

---

### World 2 — Igniter

**What it is:** A Ruby framework (pre-v1) for declaring and executing business
logic as validated dependency graphs. Separate research ecosystem
(`igniter-lang`) for a contract-native language.

**Authority:** Igniter shapes its APIs using SparkCRM as applied pressure, not
as production truth. Igniter does not take production dependency on SparkCRM.

**Stack:** Pure Ruby gem (zero production deps), RSpec, Rust FFI backend in
progress for the ledger layer.

**Key packages and their SparkCRM relevance:**

| Package | SparkCRM relevance |
|---|---|
| `igniter-ledger` | Future substrate replacing ActiveRecord ledgers |
| `igniter-durable-model` | App-facing Record/History DSL above the ledger |
| `igniter-embed` | The integration seam: contractable wrappers for SparkCRM services |
| `igniter-ledger-client` | Protocol boundary for receipt sinks — preferred over direct store coupling |
| `igniter-mcp-adapter` | Will carry Ledger reads onto SparkCRM's MCP surface |
| `igniter-lang` | Research language; `.ig` fixtures already use SparkCRM domain vocabulary |

**igniter-lang fixtures already derived from SparkCRM reality:**
- `source/vendor_lead_pipeline.ig` — `SparkCRM.Marketing`, vendor lead intake pipeline
- `source/tenant_availability_projection.ig` — `SparkCRM.Availability`, multi-tenant availability contract
- `source/availability_projection.ig` — simpler availability projection

These fixtures are domain pressure artifacts. They do not authorize Igniter-Lang
runtime execution of SparkCRM decisions.

---

## The Convergence Model

Convergence is **incremental and proof-gated**. The shape:

```
SparkCRM primary service (authoritative, unchanged)
  -> igniter-embed contractable wrapper (primary-only observed mode)
  -> redacted observation receipt emitted
  -> durable receipt sink (local proof first, then Ledger sidecar)
  -> evidence of parity accumulates
  -> shadow candidate tested against primary result
  -> normalized comparison proves equivalence
  -> authority transferred only after explicit gate decision
```

Each step is a separate gate. No step skips ahead.

The current approved boundary is `primary_observed_only`. See:

```
.agents/ruby-framework/current-status.md
igniter-lang/docs/org/portfolio-guidance-log-v0.md (PG-2026-05-20-01)
```

---

## Convergence Moves (close the delta)

Do these. They bring the worlds closer without breaking either one.

**From Igniter side:**

- Use SparkCRM domain scenarios (vendor lead intake, availability projection,
  service call pricing) as acceptance tests for Igniter API shape. If the API
  can't express a real SparkCRM scenario cleanly, the API has a problem.
- Keep `igniter-lang` fixtures synchronized with real SparkCRM domain
  vocabulary. When SparkCRM renames `Vendor` → `LeadChannel`, update the
  fixture language.
- Design `igniter-ledger` compaction, retention, and scope semantics with
  SparkCRM's multi-tenant isolation requirements in mind.
- When adding MCP adapter surfaces, design for the read patterns that
  SparkCRM's MCP tools already surface.

**From SparkCRM side:**

- Use `igniter-embed` contractable wrapper for one narrow SparkCRM service
  (primary-only observed mode) before any shadow candidate work.
- Use SparkCRM domain models as the source of truth when designing
  `LeadChannel` / `ChannelConfig` — do not reverse-engineer the schema from
  Igniter primitives.
- When a new ledger surface is designed in SparkCRM, record the pressure in
  `.agents/docs/domains/` so the Igniter ledger lane can see real shape
  requirements.

**At the boundary:**

- A domain model that exists in both worlds (e.g., availability, lead pipeline)
  must have a single canonical vocabulary. If SparkCRM and Igniter use different
  names for the same concept, record the mapping explicitly — do not silently
  diverge.
- Receipts and observations are evidence, not authority. A receipt proving
  parity does not authorize a production behavior change by itself.

---

## Anti-Drift Rules (do not widen the delta)

These behaviors produce the appearance of convergence while actually widening
the gap. Do not do them.

1. **Do not implement Igniter APIs without SparkCRM domain pressure.**
   Generic abstractions designed without a real host scenario tend to mis-fit
   the actual integration. Wait for a concrete SparkCRM use case to drive
   the API shape.

2. **Do not change SparkCRM behavior to accommodate Igniter.**
   SparkCRM is production. Igniter adapts to SparkCRM, not the other way around.
   If an Igniter API cannot wrap a SparkCRM service cleanly, fix the Igniter API.

3. **Do not open shadow candidate mode before primary-observed is proven.**
   Shadow requires a working redaction plan, a durable receipt path, and at
   least one end-to-end observation receipt. Skipping to shadow increases risk
   and obscures what is actually proven.

4. **Do not add Igniter vocabulary to SparkCRM production code without a
   shadow/comparison proof.**
   Renaming `Vendor` to `LeadChannel` in production routing before
   the `LeadChannel` domain model is stable creates orphaned terminology that
   has to be cleaned up later.

5. **Do not build cross-project ceremony as a substitute for code.**
   Portfolio reports, letters, and lane governance documents exist to
   coordinate decisions. They are not evidence of progress. A working
   end-to-end proof of one observed-service receipt is worth more than ten
   planning documents.

6. **Do not use Igniter-Lang runtime to execute SparkCRM decisions.**
   `igniter-lang` is a research ecosystem. Its fixtures describe domain intent;
   they do not authorize execution, routing, or billing decisions in SparkCRM.

7. **Do not treat sidecar receipts as a source of truth.**
   Until an explicit authority transfer gate is passed, SparkCRM's primary
   service result is truth. Receipts are side-channel evidence.

8. **Do not encode real SparkCRM customer data, credentials, phone numbers,
   emails, or provider tokens in Igniter fixtures, examples, or docs.**
   Use anonymized scenarios, abstract identifiers, and enum values only.

---

## Current Delta Map

Where things stand as of 2026-05-24:

| Domain | SparkCRM state | Igniter state | Gap |
|---|---|---|---|
| Lead pipeline | `Vendor`/`TradeVendor` legacy, `LeadChannel` seed review in training | `vendor_lead_pipeline.ig` fixture, no schema yet | Vocabulary mapped, no authority transfer |
| Availability | ActiveRecord slots/ledger | `tenant_availability_projection.ig` fixture | Shape proven in lang, no Igniter-backed runtime |
| Service call pricing | ActiveRecord ledger + shadow comparison | `igniter-ledger` substrate ready (pre-v1) | Ledger API shape not yet validated against Spark |
| Contractable wrapping | No Igniter wrappers in production | `igniter-embed` contractable recipe proven in isolation | One pilot integration card pending Architect gate |
| MCP surface | Production MCP server active | `igniter-mcp-adapter` exists | Not connected |
| Durable model | ActiveRecord primary | `igniter-durable-model` pre-v1 | No cross-project proof yet |

---

## Reading Order for New Agents

Before starting any work at the Spark x Igniter boundary:

1. This document.
2. `.agents/ruby-framework/current-status.md` — current Ruby Framework lane
   state and approved boundaries.
3. `igniter-lang/docs/org/portfolio-guidance-log-v0.md` — active Portfolio
   directives (especially PG-2026-05-20-01).
4. SparkCRM `.agents/operating-model.md` — SparkCRM's working rules.
5. The relevant domain doc in SparkCRM `.agents/docs/domains/` for the specific
   area of work.
6. The relevant Igniter package README for the specific package in scope.

Do not start implementation work without reading steps 1–3.
