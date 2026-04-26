# Igniter Implementation Delta — All Proposals

Date: 2026-04-26.

Perspective: implementation gap analysis across all 15 proposed applications.

## Purpose

This report maps every proposed application against the current Igniter
platform maturity, names the missing pieces that block each category, assigns
priority tiers (P1–P5) by breadth of impact, and produces a ranked view of
which apps can ship soonest once the delta items land.

## Maturity Baseline

| Layer | State |
|---|---|
| Contracts kernel — model, compiler, DSL, runtime, cache | **Mature** |
| Extensions — auditing, reactive, incremental, saga, differential, provenance | **Mature** |
| Diagnostics — report builders, text/markdown/structured formatters | **Mature** |
| AI/LLM/Tool/Skill — providers, tool registry, skill feedback, transcription | **Solid** |
| Actor system — Agent, Supervisor, Registry, StreamLoop | **Solid** |
| Server / Mesh — static/dynamic/gossip mesh, Prometheus SD, K8s probes | **Solid** |
| Consensus — Raft cluster, StateMachine DSL | **Solid** |
| Web surfaces — Arbre, POC rack surfaces, MountContext | **Emerging** |
| Application::Kernel — `interactive_app` facade, profile, environment | **Emerging** |
| Flow/session model — FlowSessionSnapshot, PendingInput (prototype) | **Emerging** |
| Activation Evidence & Receipt — architecture decided, not implemented | **Design-only** |
| Enterprise orchestration — multi-tenant capsule isolation, signed receipts | **Design-only** |

---

## Delta Inventory

### P1 — Blocks All or Nearly All Applications (~10–12 weeks total)

These four items are prerequisites for every proposed app. No app can ship a
meaningful POC without at least P1.1 and P1.2.

| # | Item | What It Enables | Estimated Effort |
|---|---|---|---|
| P1.1 | `Igniter.interactive_app` facade | One-place app declaration; delegates to existing Application::Kernel primitives | 3 weeks |
| P1.2 | `flow do; step :name; end` DSL | Sequential guided workflows with step state, command results, skip/done semantics | 3 weeks |
| P1.3 | SSE endpoint as first-class primitive — `endpoint :stream, format: :sse` | Real-time push without polling; unblocks every app that has a live feed or event lane | 2 weeks |
| P1.4 | Durable session store — flow state survives restart | Converts prototype FlowSessionSnapshot into a real persistence guarantee | 2 weeks |

**P1 total: ~10 weeks**

---

### P2 — Blocks 8 or More Applications (~7 weeks total)

| # | Item | What It Enables | Estimated Effort |
|---|---|---|---|
| P2.1 | Proactive agent wakeup — `wakeup every: N` / `wakeup :schedule, cron: "..."` | Background ticks, periodic scans, scheduled digests | 1 week |
| P2.2 | `step :name, requires_approval: true` modifier | Human-in-the-loop step; approval gate before proceeding | 1 week |
| P2.3 | `step :name, produces: :receipt_type` output | Typed step output that wires into receipt/report chain | 1 week |
| P2.4 | Multi-step flow with branching — `on_result :a, goto: :b` | Conditional routing in guided workflows | 2 weeks |
| P2.5 | Real-time snapshot push to connected SSE clients | Keeps dashboard read model current without full page reload | 2 weeks |

**P2 total: ~7 weeks**

---

### P3 — Blocks 4–7 Applications (~9 weeks total)

| # | Item | What It Enables | Estimated Effort |
|---|---|---|---|
| P3.1 | `step :name, await: :event_type` — external event gate | Flow suspends until external delivery (webhook, payment, signature) | 2 weeks |
| P3.2 | `endpoint :mobile, format: :json` — mobile-first API surface | Driver apps, tech field apps, any mobile client | 1 week |
| P3.3 | `step :name, interruptible: true` — pause/resume mid-flow | Job paused on-site, resumed from call center; async handoffs | 1 week |
| P3.4 | Receipt type system — structured schema, identity, evidence refs | Typed `LenseAnalysisReceipt`, `DispatchIncidentReceipt`, `FieldJobReceipt` | 2 weeks |
| P3.5 | Artifact reference — `ArtifactReference` with file/hash/provenance | Documents, attachments, evidence blobs attached to flow steps | 1 week |
| P3.6 | Form builder DSL — `form :name do; field :x, type: :text; end` | Structured data collection inside flows; replaces raw HTML forms | 2 weeks |

**P3 total: ~9 weeks**

---

### P4 — Blocks 2–4 Applications (~10 weeks total)

| # | Item | What It Enables | Estimated Effort |
|---|---|---|---|
| P4.1 | Multi-tenant capsule model — per-tenant namespace isolation | SaaS apps where each customer is a capsule instance | 3 weeks |
| P4.2 | `step :name, await: :all_signatories` — multi-party approval | Multi-stakeholder sign-off (contracts, hiring, compliance) | 2 weeks |
| P4.3 | Chart/visualization component — time series, bar, score gauge | Dashboards showing metrics trends (Lense health, Signal performance) | 2 weeks |
| P4.4 | Webhook inbound adapter — `on_webhook :event_type, at: "/hook"` | Receiving Slack alerts, GitHub events, carrier callbacks | 1 week |
| P4.5 | Geo/location data types — `GeoPoint`, bounding box, distance | Driver positions, job sites, coverage zones | 2 weeks |

**P4 total: ~10 weeks**

---

### P5 — Enterprise / Extended (1–2 Applications, ~10 weeks total)

| # | Item | What It Enables | Estimated Effort |
|---|---|---|---|
| P5.1 | Voice webhook adapter — transcription → flow event | Inbound call → `CallConnectedEvent` → guided IVR flow (Nexus) | 2 weeks |
| P5.2 | Capsule-per-tenant deployment + isolation boundary | Each HVAC company or enterprise client gets a separate capsule instance | 3 weeks |
| P5.3 | Compliance-grade receipt chain — immutable, signed, auditable | Legal-grade evidence for Aria (hiring), Accord (contracts), Blueprint (BPMN) | 3 weeks |
| P5.4 | Map component — interactive pin/route rendering | Dispatch board, Convoy driver map, Field coverage map | 2 weeks |

**P5 total: ~10 weeks**

---

## Grand Total Delta Estimate

| Priority | Items | Effort |
|---|---|---|
| P1 | 4 | ~10 weeks |
| P2 | 5 | ~7 weeks |
| P3 | 6 | ~9 weeks |
| P4 | 5 | ~10 weeks |
| P5 | 4 | ~10 weeks |
| **Total** | **24** | **~46 weeks** |

These are parallel-capable streams after P1 lands. With two focused contributors,
P2+P3 can run in parallel (~9 weeks after P1 completes). P4+P5 are then
optional extensions driven by which apps are being actively developed.

---

## Per-Application Delta Map

Legend: ✓ already works with today's Igniter | ● required | ○ optional / deferred

### IT / Developer Apps

| Delta Item | Lense | Scout | Dispatch | Chronicle | Aria |
|---|---|---|---|---|---|
| P1.1 interactive_app | ● | ● | ● | ● | ● |
| P1.2 flow DSL | ● | ● | ● | ● | ● |
| P1.3 SSE endpoint | ○ | ● | ● | ○ | ○ |
| P1.4 durable sessions | ○ | ● | ● | ● | ● |
| P2.1 proactive wakeup | ○ | ● | ● | ○ | ○ |
| P2.2 requires_approval | ○ | ○ | ● | ● | ● |
| P2.3 produces receipt | ● | ● | ● | ● | ● |
| P2.4 flow branching | ○ | ● | ● | ● | ● |
| P2.5 SSE push | ○ | ● | ● | ○ | ○ |
| P3.1 await external event | ○ | ● | ● | ● | ● |
| P3.2 mobile endpoint | ✓ | ○ | ○ | ○ | ○ |
| P3.3 interruptible step | ○ | ● | ○ | ○ | ○ |
| P3.4 receipt type system | ● | ● | ● | ● | ● |
| P3.5 artifact refs | ○ | ● | ○ | ● | ● |
| P3.6 form builder | ○ | ○ | ○ | ○ | ○ |
| P4.1 multi-tenant | ○ | ○ | ○ | ○ | ○ |
| P4.2 await all signatories | ○ | ○ | ○ | ● | ● |
| P4.3 chart component | ○ | ○ | ○ | ○ | ○ |
| P4.4 webhook inbound | ○ | ● | ● | ○ | ○ |
| P4.5 geo types | ✓ | ○ | ○ | ○ | ○ |
| P5.1 voice webhook | ✓ | ✓ | ✓ | ✓ | ✓ |
| P5.2 capsule per-tenant | ✓ | ✓ | ✓ | ✓ | ○ |
| P5.3 compliance receipt | ✓ | ✓ | ✓ | ✓ | ● |
| P5.4 map component | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Required items** | **3** | **8** | **9** | **9** | **10** |

### Non-Technical Apps

| Delta Item | Forma | Meridian | Studio | Signal | Blueprint | Accord |
|---|---|---|---|---|---|---|
| P1.1 interactive_app | ● | ● | ● | ● | ● | ● |
| P1.2 flow DSL | ● | ● | ● | ● | ● | ● |
| P1.3 SSE endpoint | ○ | ● | ● | ● | ● | ○ |
| P1.4 durable sessions | ● | ● | ● | ● | ● | ● |
| P2.1 proactive wakeup | ○ | ● | ● | ● | ○ | ○ |
| P2.2 requires_approval | ○ | ○ | ○ | ○ | ● | ● |
| P2.3 produces receipt | ● | ● | ● | ● | ● | ● |
| P2.4 flow branching | ● | ● | ● | ● | ● | ● |
| P2.5 SSE push | ○ | ● | ○ | ● | ● | ○ |
| P3.1 await external event | ○ | ○ | ● | ● | ● | ● |
| P3.2 mobile endpoint | ✓ | ○ | ○ | ○ | ○ | ○ |
| P3.3 interruptible step | ○ | ○ | ● | ○ | ● | ○ |
| P3.4 receipt type system | ● | ● | ● | ● | ● | ● |
| P3.5 artifact refs | ● | ○ | ● | ● | ● | ● |
| P3.6 form builder | ● | ● | ○ | ○ | ● | ● |
| P4.1 multi-tenant | ○ | ○ | ○ | ○ | ● | ○ |
| P4.2 await all signatories | ○ | ○ | ○ | ○ | ● | ● |
| P4.3 chart component | ○ | ● | ● | ● | ○ | ○ |
| P4.4 webhook inbound | ○ | ○ | ● | ● | ● | ○ |
| P4.5 geo types | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| P5.1 voice webhook | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| P5.2 capsule per-tenant | ✓ | ✓ | ✓ | ✓ | ● | ✓ |
| P5.3 compliance receipt | ✓ | ✓ | ✓ | ✓ | ● | ● |
| P5.4 map component | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Required items** | **7** | **9** | **10** | **10** | **14** | **11** |

### Logistics & Field Service Apps

| Delta Item | Convoy | Freight | Field | Nexus |
|---|---|---|---|---|
| P1.1 interactive_app | ● | ● | ● | ● |
| P1.2 flow DSL | ● | ● | ● | ● |
| P1.3 SSE endpoint | ● | ● | ○ | ● |
| P1.4 durable sessions | ● | ● | ● | ● |
| P2.1 proactive wakeup | ● | ● | ● | ● |
| P2.2 requires_approval | ○ | ● | ● | ● |
| P2.3 produces receipt | ● | ● | ● | ● |
| P2.4 flow branching | ● | ● | ● | ● |
| P2.5 SSE push | ● | ● | ○ | ● |
| P3.1 await external event | ● | ● | ● | ● |
| P3.2 mobile endpoint | ● | ● | ● | ● |
| P3.3 interruptible step | ● | ○ | ● | ● |
| P3.4 receipt type system | ● | ● | ● | ● |
| P3.5 artifact refs | ● | ● | ● | ● |
| P3.6 form builder | ○ | ○ | ● | ● |
| P4.1 multi-tenant | ○ | ○ | ○ | ● |
| P4.2 await all signatories | ○ | ○ | ○ | ○ |
| P4.3 chart component | ○ | ○ | ○ | ● |
| P4.4 webhook inbound | ● | ● | ○ | ● |
| P4.5 geo types | ● | ○ | ● | ○ |
| P5.1 voice webhook | ✓ | ✓ | ✓ | ● |
| P5.2 capsule per-tenant | ✓ | ✓ | ✓ | ● |
| P5.3 compliance receipt | ✓ | ✓ | ✓ | ● |
| P5.4 map component | ● | ✓ | ○ | ✓ |
| **Required items** | **13** | **12** | **12** | **17** |

---

## Ranked Summary Table

Sorted by required delta items (fewest first = ships soonest). Delta score
weights P1 items at ×2, P2 at ×1.5, P3 at ×1, P4 at ×0.75, P5 at ×0.5 to
reflect blast-radius of each priority tier.

| Rank | App | Audience | Required Items | Delta Score | Audience Size | Revenue Potential | Showcase Value | Weeks to POC after P1¹ |
|---|---|---|---|---|---|---|---|---|
| 1 | **Lense** | IT / Developer | 3 | 7 | M | Low → Medium | ★★★★★ | 0–1 |
| 2 | **Forma** | End User | 7 | 14.5 | XL | Medium | ★★★★ | 3–5 |
| 3 | **Scout** | IT / Developer | 8 | 17.5 | M | Medium | ★★★★ | 4–6 |
| 4 | **Chronicle** | IT / Developer | 9 | 19 | M | Medium | ★★★ | 5–7 |
| 5 | **Dispatch** | IT / Developer | 9 | 19.5 | M | Medium → High | ★★★★ | 5–7 |
| 6 | **Meridian** | End User | 9 | 19.5 | XL | Medium | ★★★ | 4–6 |
| 7 | **Studio** | Creators / Media | 10 | 21 | L | Medium → High | ★★★★ | 6–8 |
| 8 | **Signal** | Creators / Marketing | 10 | 21.5 | L | High | ★★★★ | 6–8 |
| 9 | **Aria** | IT / Developer | 10 | 22 | M | High | ★★★★ | 7–9 |
| 10 | **Freight** | Logistics / 3PL | 12 | 26 | M | High | ★★★ | 8–11 |
| 11 | **Field** | HVAC / Field Service | 12 | 26.5 | M | High | ★★★ | 8–11 |
| 12 | **Convoy** | Logistics / Delivery | 13 | 27.5 | L | High | ★★★★ | 9–12 |
| 13 | **Accord** | Enterprise | 11 | 27 | S | Very High | ★★★★ | 9–12 |
| 14 | **Blueprint** | Enterprise | 14 | 31 | S | Very High | ★★★ | 12–16 |
| 15 | **Nexus** | SaaS / Call Centers | 17 | 37.5 | L | Very High | ★★★★★ | 16–22 |

¹ "Weeks to POC after P1" = additional weeks of app-specific work once P1 (10
weeks) is complete. Assumes P2/P3 items relevant to that app land in parallel.

**Audience Size:** S = startup-scale (<1 000 orgs), M = mid-market (1 000–50 000),
L = broad vertical (50 000+), XL = consumer/prosumer (100 000+).

**Revenue Potential:** reflects typical SaaS ACV range for the vertical once the
platform is productized.

**Showcase Value:** how effectively the app demonstrates Igniter's differentiating
primitives (contracts graph, receipt chain, guided flow, agent-native
architecture) to a first-time observer.

---

## Strategic Sequence

### Phase 0 — Already underway

Lense POC selected and scoped. Runs without any P1 facade change: one runnable
script, one Rack surface, no network/LLM/DB. Pressures `igniter-application`,
`igniter-contracts`, `igniter-extensions`, `igniter-web`. Completion proves the
app composition seam and receipt-shaped report output.

### Phase 1 — Ship P1 (weeks 1–10)

With Lense giving live feedback, build the four universal prerequisites in
parallel streams:
- Stream A: `interactive_app` facade + Application::Kernel profile/environment
- Stream B: `flow` DSL + step state + skip/done/note semantics
- Stream C: SSE endpoint primitive + real-time snapshot push
- Stream D: Durable session store (pluggable backend, memory default)

### Phase 2 — First batch of apps (weeks 11–20, P1 + P2/P3)

Forma, Scout, Chronicle, Dispatch, and Meridian can all reach POC-quality
within 4–8 weeks of P1 landing. Choose two to three to build in parallel as
reference implementations; each one will stress-test a different corner of the
platform.

Recommended pair after Lense:

1. **Forma** — highest audience size, stresses form builder and
   receipt-from-wizard flow without needing SSE or proactive agents.
2. **Dispatch** — highest showcase drama, stresses proactive wakeup, SSE push,
   and incident-receipt semantics. Good conference demo.

### Phase 3 — Showcase vertical (weeks 21–35, P3 complete)

Once P3 items land (mobile endpoint, interruptible step, artifact refs,
receipt type system), the logistics and HVAC vertical becomes reachable.
Convoy or Field makes the strongest showcase here: concrete domain,
clear operational receipts, visible real-time updates.

### Phase 4 — Enterprise track (weeks 36+, P4/P5)

Blueprint, Accord, and Nexus require multi-party approval, compliance-grade
receipts, and multi-tenant capsule isolation. These are high-revenue targets
but need the platform to be field-tested first. Build them as productized
reference apps after the showcase vertical proves operational reliability.

---

## Key Architectural Risks

**1. `interactive_app` facade scope creep.**
Every team will want to add DSL keywords. Define the facade as a thin
delegation layer first; resist adding package-level UI DSL, layout builders,
or component systems in the first pass.

**2. Durable session store coupling.**
If FlowSessionSnapshot couples tightly to one storage backend the test
surface explodes. Design a Null/Memory default so the whole flow stack is
testable without a real store.

**3. SSE + multi-process deployment.**
SSE push needs a shared pub/sub channel when Rack workers are in separate
processes. Avoid designing SSE as an in-process broadcast; abstract the
channel behind the mesh event bus from day one.

**4. Receipt type proliferation.**
Each app will want a custom receipt schema. Without a shared base, receipts
diverge and the transfer/activation doctrine loses coherence. Define a
`Igniter::Receipt::Base` with mandatory identity, generated_at, and
evidence_refs fields; let apps extend it.

**5. Multi-tenant isolation surface.**
Nexus and Blueprint need capsule-per-tenant boundaries. Do not retrofit
multi-tenancy into the application composition layer after the fact;
design the `interactive_app` namespace from the start to carry a tenant key.

---

## One-Sentence Verdict per App

| App | Verdict |
|---|---|
| **Lense** | Ship now — zero external deps, strongest showcase per delta invested. |
| **Forma** | Ship after P1.2 + P3.6 — form-builder flow is the next most universal demo. |
| **Scout** | Ship after P1 complete — durable sessions and interruptible step are the gate. |
| **Chronicle** | Ship alongside Scout — multi-party sign-off pressures a P4.2 preview. |
| **Dispatch** | Ship after P2 complete — proactive wakeup + SSE push make it dramatic and real. |
| **Meridian** | Ship after Dispatch proves real-time pattern — same primitives, consumer angle. |
| **Studio** | Ship after P3 complete — artifact refs and interruptible step are critical. |
| **Signal** | Ship after Studio — shares most P3 requirements and adds analytics layer. |
| **Aria** | Ship after P5.3 compliance receipt lands — hiring workflow demands it. |
| **Freight** | Ship after logistics vertical is scoped — shares Convoy's P3 requirements. |
| **Field** | Ship alongside Freight — mobile endpoint + interruptible step are the gate. |
| **Convoy** | Ship after Field proves mobile pattern — adds real-time driver tracking. |
| **Accord** | Ship after Aria proves compliance receipt — contracts domain follows. |
| **Blueprint** | Enterprise track after showcase vertical proves reliability. |
| **Nexus** | Last to ship — most delta, highest revenue; requires entire P5 stack. |
