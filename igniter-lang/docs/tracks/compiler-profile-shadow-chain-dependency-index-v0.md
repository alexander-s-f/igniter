# Track: Compiler Profile Shadow Chain Dependency Index v0

Card: S3-R33-C4-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: compiler-profile-shadow-chain-dependency-index-v0
Status: done
Date: 2026-05-11

---

## Goal

Make the compiler-profile shadow proof chain navigable and regeneration-safe.

This is curation/indexing only. It creates no new semantics, assigns no PROP
number, opens no implementation card, and authorizes no compiler migration.

---

## Source Docs Read

| Doc | Role in this index |
|-----|--------------------|
| `compiler-profile-chain-closure-index-v0.md` | Canonical 28-step shadow proof chain |
| `compiler-profile-r32-shadow-chain-backreference-v0.md` | R32 M-3 backreference proving why the dependency map exists |
| `compiler-profile-authority-boundary-v0.md` | Authority firewall: compiler understanding only, no runtime execution authority |
| `compiler-profile-spec-and-rule-profile-unification-v0.md` | Unified compiler profile id from slots + ordered rules |
| `compiler-profile-manifest-prop-draft-v0.md` | Draft candidate for future `compiler_profile_id` manifest field |
| `compiler-profile-manifest-prop-promotion-v0.md` | Promotion packet ready for Architect numbering/routing, without claiming a PROP number |

---

## Proof Chain Order

Use `compiler-profile-chain-closure-index-v0.md` as the canonical order:

```text
1 shadow baseline
2 ContractModifiersPack boundary
3 kernel registry spike
4 ordered rule precedence
5 compiler_profile_id manifest boundary
6 profile slots model
7 spec/rule profile unification
8 authority boundary
9 CompatibilityReport fields
10 preflight chain index
11 auditable build receipt
12 receipt authority/storage
13 self-assembly profile sketch
14 bootstrap descriptor kernel
15 descriptor schema
16 profile-source lowering target
17 manifest PROP draft
18 profile-source syntax pressure
19 manifest PROP review-ready
20 manifest PROP promotion
21 PROP numbering decision request
22 descriptor error taxonomy
23 profile syntax compiler review
24 profile syntax grammar boundary
25 validator implementation plan
26 manifest PROP Architect routing
27 ProgressionPack shadow boundary
28 R32 shadow-chain backreference
```

---

## Compact Dependency / Regeneration Table

| Node | Direct summary inputs | If input changes, regenerate |
|------|-----------------------|------------------------------|
| #1 shadow baseline | none | #1, then all dependent shadow/profile rows |
| #2 ContractModifiersPack boundary | #1 | #2 -> #3 -> #10 and any closure rerun |
| #3 kernel registry | #2 | #3 -> #10 |
| #4 ordered rules | none | #4 -> #5/#7/#22 -> downstream profile, manifest, validator rows |
| #5 manifest boundary | #4 | #5 -> #8/#17/#19/#20/#21/#26 |
| #6 slots model | #1 | #6 -> #7/#19/#22/#25 |
| #7 unified profile | #6, #4 | #7 -> #8/#11/#19 |
| #8 authority boundary | #7, #5 | #8 -> #9/#10/#17/#19 |
| #9 report fields | #8 | #9 -> #10/#17/#19 |
| #10 preflight chain | #1-#9 | #10 -> #11/#13 |
| #11 build receipt | #10, #7, compiler CLI summary | #11 -> #12 |
| #12 receipt storage | #11 | #12 -> #13/#17/#19 |
| #13 self assembly | #10, #12 | #13 -> #14 |
| #14 bootstrap kernel | #13 | #14 -> #15/#19 |
| #15 descriptor schema | #14 | #15 -> #16/#22/#25 |
| #16 lowering target | #15 | #16 -> #18 |
| #17 manifest draft | #5, #9, #12 | #17 -> #19 |
| #18 syntax pressure | #16 | #18 -> #19/#23 |
| #19 review-ready packet | #17, #6, #7, #9, #12, #14, #18 | #19 -> #20 |
| #20 promotion packet | #19 | #20 -> #21/#26 |
| #21 numbering decision request | #20 | #21 -> #26 |
| #22 descriptor taxonomy | #15, #6, #4 | #22 -> #23/#25 |
| #23 compiler syntax review | #18, #22 | #23 -> #24 |
| #24 grammar boundary | #23 | #24 -> #25 |
| #25 validator plan | #15, #22, #24 | #25 only, then closure rerun |
| #26 Architect routing packet | #21, #20 | #26 only, then closure rerun |
| #27 ProgressionPack boundary | external progression summary, #1 | #27 only, then closure rerun |
| #28 R32 backreference | R32 discussion + closure index | #28 only, then closure rerun |

Final step after any regeneration: rerun
`compiler_profile_chain_closure_index` so the current index summary sees the new
PASS/FAIL state.

---

## Shadow / Pre-POC Boundary

All files in this chain are shadow/pre-POC or proposal-packet evidence unless a
later gate explicitly says otherwise.

| File family | Status |
|-------------|--------|
| `experiments/compiler_profile_*` | proof-local / shadow evidence |
| `experiments/compiler_kernel_*` | proof-local registry/order model |
| `experiments/profile_source_*` | syntax pressure / review boundary; no parser work |
| `experiments/progression_pack_shadow_boundary` | external progression mapping only |
| `docs/tracks/compiler-profile-*.md` | track evidence / proposal packets, not accepted implementation |
| `docs/tracks/profile-source-*.md` | research/compiler-review boundary, not grammar acceptance |

Explicitly not authorized:

```text
CompilerKernel production implementation
CompilerPack migration
compiler dispatch rewrite
profile source parser implementation
.igapp / .ilk format change
assembler/loader implementation
runtime execution authority
official PROP number assignment
```

---

## Archive Candidates After Consolidation

Archive only after a consolidated compiler-profile manifest/proof packet exists
and the current tracks index points to it.

| Candidate docs | Archive condition |
|----------------|-------------------|
| Early shadow foundation tracks `compiler-pack-shadow-profile-proof`, `contract-modifiers-pack-native-boundary`, `compiler-kernel-pack-registry-spike` | Consolidated profile foundation packet preserves their proof claims and summaries |
| `compiler-profile-slots-model` + `compiler-profile-spec-and-rule-profile-unification` | Unified profile spec is promoted into a single active design/proposal doc |
| Manifest draft/review/promotion packet tracks | Architect numbering/routing decision lands and official proposal file exists |
| Profile-source syntax pressure/review/boundary tracks | Compiler/Grammar emits a canonical grammar decision or defers syntax formally |
| Descriptor taxonomy + validator implementation plan | A validator proposal or implementation card supersedes the no-code plan |

Keep active until then:

```text
compiler-profile-chain-closure-index-v0.md
compiler-profile-shadow-chain-dependency-index-v0.md
compiler-profile-authority-boundary-v0.md
compiler-profile-manifest-prop-architect-routing-v0.md
compiler-profile-validator-implementation-plan-v0.md
```

---

## Updates Applied

| File | Update |
|------|--------|
| `compiler-profile-chain-closure-index-v0.md` | Added dependency/regeneration index with direct input summaries and high-impact upstream change rules |
| `README.md` | Added this track to Background Compiler Profile Foundation |

---

## Handoff

[D] Decisions:
- The closure index remains the canonical chain order.
- The dependency map is direct-input based: summary change -> rerun dependent proof -> closure index last.
- All compiler-profile chain files remain shadow/pre-POC unless an explicit gate promotes them.

[S] Signals:
- Manifest PROP promotion/routing remains ready for Architect numbering, but no number is claimed.
- Authority boundary remains intact: compiler profile proves understanding, never runtime execution.

[R] Risks:
- Upstream descriptor changes can silently stale multiple packet summaries unless the regeneration order is followed.
- Archive should wait for consolidation, not merely PASS status.

[Next]
- Route Architect/Compiler-Expert decision for compiler_profile_id manifest PROP numbering if this lane is next priority.
