# Experimental Lab Ecosystem Pressure v0

Card: S3-R236-C3-X
Skill: IDD Agent Protocol
Agent: [External Pressure Reviewer]
Role: external-pressure-reviewer
Track: experimental-lab-ecosystem-pressure-v0
Route: REVIEW
Status: complete
Date: 2026-06-02

Depends on:
- S3-R236-C1-D
- S3-R236-C2-P1

---

## Inputs Read

- `igniter-lang/docs/tracks/experimental-lab-ecosystem-pressure-map-and-intake-prioritization-v0.md` (C1-D)
- `igniter-lang/docs/tracks/experimental-lab-ecosystem-surface-facts-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round235-status-curation-v0.md`
- `igniter-lang/docs/tracks/experimental-igc-run-slice0-quickstart-docs-v0.md`
- `igniter-lang/docs/tracks/delegated-experimental-compiler-rust-candidate-intake-v0.md`

---

## Compact Risk Table

| Risk | Assessment | Source | Residual |
| --- | --- | --- | --- |
| Lab components create authority, not just evidence | Very low | C1-D binding stance: "lab components create evidence, not authority"; C2-P1 non-claims confirmed for all 7 components | Very low |
| `igniter-tbackend` README overclaims propagate into mainline | Medium | C2-P1 HIGH-severity items: "production-grade" / "incredible throughput" / "prevents PostgreSQL bloat (SparkCRM)" / "zero-dependency" (FALSE — has magnus, parking_lot, etc.); C1-D: HOLD pending wording hardening | Medium if not held — HOLD is correct |
| `igniter-tbackend` "zero-dependency" false claim enters intake | High if intaken now | C2-P1 confirms it has multiple runtime dependencies; claim is factually incorrect, not just enthusiastic | Zero if HOLD respected |
| SparkCRM product claim propagates via TBackend README | Medium | C2-P1: "Production Use Cases: Prevent PostgreSQL bloat (SparkCRM)" — specific product reference, not just vague lab language | Zero if HOLD respected |
| `igc run` Slice 1 opens before stdlib/backend intake grounds it | Low | C1-D explicitly holds Slice 1; correct because Slice 1 would pull in stdlib/operator behavior, .igbin, capability matching — exactly areas not yet grounded in mainline intake | Very low |
| benchmark-app creates public performance evidence | Very low | C2-P1: benchmark.rb targets TBackend TCP server, not language runtime; no result file emitted; no mainline track references it | Very low |
| C1-D / C2-P1 diverge on second-priority route (TBackend vs igniter-vm) | Low | C1-D: stdlib → TBackend; C2-P1: stdlib → igniter-vm; both safe; needs explicit C4-A resolution | Low — see AN-1 |
| Rust compiler hardening blocks other intakes | Zero | C1-D and C2-P1 agree GAP-1..GAP-7 are lab-internal; hardening does not block stdlib or TBackend intake | Zero |
| Public/stable/production/Reference Runtime/Spark/release/performance claims | Zero | All seven components have confirmed non-claims in C2-P1; C1-D closed-surfaces list comprehensive | Zero |

---

## Pressure-Question Answers

**Is `igniter-stdlib` the shortest path to real executable confidence?**

YES. It is the cleanest intake target across all seven components:
- `verify_stdlib.rb` PASS locally (7 assertions, OOF-TC5/DM2 correctly triggered)
- Zero overclaim wording risk
- No server, no network, no Magnus/FFI build dependency
- Directly connects to PROP-013 (decimal typing, stdlib execution kernel)
- `igniter-vm` declares it as a local path dependency — grounding stdlib in mainline intake first gives the VM evidence chain a cleaner foundation
- Does not require public runtime, package, or CLI widening

The stdlib intake is the single move that provides the most leverage with the least authority risk.

**Is `igniter-tbackend` the highest leverage substrate pressure route?**

YES for strategic leverage — it covers temporal storage, WAL/compaction, bitemporal reads, and the full backend stack that `igc run` Slice 1+ would eventually depend on.

NO for immediate intake. Two specific issues are not merely enthusiastic lab language:

1. **"zero-dependency" is factually false.** `igniter-tbackend` has runtime dependencies including `magnus 0.7`, `parking_lot 0.12`, `rmp-serde 1.3`, and others. A mainline intake that includes this claim would propagate a false technical statement.

2. **"prevents PostgreSQL bloat (SparkCRM)"** — this is a specific product reference that names `SparkCRM` as a use case, consistent with a productization claim not authorized by Main Line.

Both items must be corrected in the lab README before a clean intake packet can be produced without risk of overclaim propagation. HOLD is the correct stance.

**Is Rust compiler hardening urgent or can it stay sidecar?**

Stays sidecar. GAP-1..GAP-7 are lab-internal hardening tasks that do not block stdlib or TBackend intake. Portability comparison must wait for hardening, but hardening does not need to precede stdlib intake.

**Does `benchmark-app` create useful product pressure without public benchmark claims?**

Bounded product pressure only. `benchmark.rb` targets the TBackend TCP server — it is not a language runtime or igc run performance benchmark. No result file is emitted. No mainline track references it. AN-1 (R229-C4-A) applies: all numbers are in-playground sandbox measurements only.

**Should `acts-as-tbackend` become a Chronicle-style route or stay parked?**

Stay parked. `demo.rb` requires `bundler/inline` with network access (`source "https://rubygems.org"`), and the adapter depends on TBackend being intaken first. Any Chronicle-style framing would be premature until TBackend itself has an accepted intake packet. Park until after TBackend wording hardening and intake.

---

## Assessment Summary

**C1-D:** The pressure map is well-calibrated. The 8-tier hierarchy vocabulary is correct and complete. The binding stance ("lab components create evidence, not authority; lab overclaim wording may remain tolerated inside lab while mainline records strict non-claims") is the right policy for managing the ecosystem without freezing it.

The only design gap is that C1-D prioritizes TBackend second while C2-P1 prioritizes igniter-vm second. Both rationales are sound; neither is a blocker. See AN-1.

**C2-P1:** The facts are source-grounded and honest about what was run vs not run. The distinction between "confirmed locally" (stdlib/vm/compiler verifiers) and "not run" (TBackend server scripts, acts-as-tbackend network scripts) is correctly maintained. The overclaim register is the most valuable artifact in the packet — it quantifies the TBackend wording risk in a way that makes the HOLD decision obvious.

The `igniter-vm` recommendation to route second (after stdlib) is technically justified by the direct path dependency. The 12 Cargo tests covering Decimal arithmetic, temporal reads, branch semantics, and map-reduce are real evidence of a broader execution scope than the current Ruby IVM.

---

## Explicit Answers

| Question | Answer |
| --- | --- |
| Verdict | PASS |
| Strongest next route | `igniter-stdlib` candidate intake (C1-D and C2-P1 both agree) |
| Biggest overclaim risk | `igniter-tbackend` README: "zero-dependency" (false), "prevents PostgreSQL bloat (SparkCRM)" (product claim), "incredible throughput" (unproven public performance claim). These three items make clean TBackend intake impossible today. |
| Biggest time-to-market risk | Not opening stdlib intake. The stdlib→vm→tbackend evidence chain strengthens every future runtime/productization move. Every round spent on Slice 1 without stdlib intake builds on a weaker foundation. |
| Exact blocker list | None for PASS verdict. TBackend HOLD is a routing decision, not a blocker for the map acceptance. |

---

## Non-Blocking Acceptance Note

**AN-1 — C1-D proposes stdlib → TBackend; C2-P1 proposes stdlib → igniter-vm; C4-A must choose.**

C1-D's argument: TBackend has higher strategic backend/substrate leverage and should receive its own intake once wording hardening completes.

C2-P1's argument: `igniter-vm` depends on `igniter-stdlib` as a local path dependency; VM intake immediately after stdlib gives the evidence chain a cleaner foundation without waiting for TBackend wording hardening.

Both orderings are safe. The recommended synthesis: open stdlib intake next; open igniter-vm intake track in parallel or immediately after; open TBackend wording hardening as a sidecar lab task that converges into TBackend intake when ready. This allows stdlib→vm progress on the evidence chain while TBackend catches up on wording.

---

## Verdict

```text
PASS

C1-D Lab Ecosystem Pressure Map: accept
C2-P1 Surface Facts: accept as accurate facts basis
C4-A HOLD: release; proceed to final acceptance

No blockers.
1 non-blocking acceptance note (AN-1: C4-A must resolve stdlib-first
  sequencing — igniter-vm second vs TBackend second).
```

---

## Recommendation for S3-R236-C4-A

```text
Card: S3-R236-C4-A (final acceptance)
Route: UPDATE
Mode: accept ecosystem map / open next intake route

Accept:
- C1-D lab ecosystem pressure map and intake prioritization
- C2-P1 surface facts as accurate and source-grounded facts basis
- 8-tier hierarchy vocabulary as routing standard
- Binding stance: lab evidence ≠ authority; mainline must translate
  lab language to strict non-claim vocabulary

Resolve AN-1 — name one sequencing explicitly:
  Recommended: stdlib → igniter-vm → TBackend (after wording hardening)
  Alternative: stdlib → TBackend (after wording hardening) [C1-D preference]

Open next Main Line route:
  experimental-stdlib-candidate-intake-and-prop013-pressure-v0
  (or equivalent stdlib intake authorization review)

Sidecar route (parallel, non-blocking):
  igniter-tbackend lab README wording hardening
  (lab-internal task; required before TBackend intake can open)

Hold routes:
  igc run Slice 1 — held until at least stdlib intake closes
  TBackend candidate intake — held until README wording hardened
    (zero-dependency claim must be corrected; SparkCRM reference must
    be scoped to lab-assertion-only; performance claims must be labeled
    informational/research-signal)
  acts-as-tbackend — parked; depends on TBackend intake first

Keep closed:
  public runtime / stable API / production / Spark / release claims
  benchmark-app as public performance evidence
  Rust compiler portability comparison (GAP-1..GAP-7 first)
  igc run Slice 1 implementation
  Reference Runtime / Official Reference Implementation claims
  certified alternative implementation
```
