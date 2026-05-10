# History-S17: Forms / Effects / Contracts Research Snapshot

Date: 2026-05-10  
Stage: History-S17  
Agent: [Igniter-Lang History Curator]  
Status: compact archive report; not canon; not a proposal  

## Compact Claim

The private `playgrounds/docs/external/Agent-C/` line has evolved from "forms as
syntax aliases" into a broader research bundle:

- forms expose contract meaning, but do not create meaning;
- effects are declared consequences, not hidden side effects;
- profiles are compile-time policy contracts, not runtime config;
- contract bodies are dependency graphs, not imperative scripts;
- loops and recursion must be managed by explicit control regimes;
- the compiler is the trust boundary where meaning is admitted, checked, and
  frozen into artifacts.

This is valuable pressure, but it is still private external research. It must
not be promoted directly into current canon, public docs, or active proposals
without Meta Expert / Architect routing.

## Source Set

Primary:

- `playgrounds/docs/external/README.md`
- `playgrounds/docs/external/Agent-C/README.md`
- `playgrounds/docs/external/Agent-C/C0-Form-Concept.md`
- `playgrounds/docs/external/Agent-C/C1-Stdlib-Forms.md`
- `playgrounds/docs/external/Agent-C/C5-Compiler-Interface.md`
- `playgrounds/docs/external/Agent-C/C6-Artifact-Model.md`
- `playgrounds/docs/external/Agent-C/C7-Covenant.md`
- `playgrounds/docs/external/Agent-C/PROP-External-Effects-v0.md`
- `playgrounds/docs/external/Agent-C/PROP-Forms-v0.md`
- `playgrounds/docs/external/Agent-C/PROP-Contract-v0.md`
- `playgrounds/docs/external/Agent-C/PROP-Profile-v0.md`
- `playgrounds/docs/external/Agent-C/PROP-Loop-v0.md`
- `playgrounds/docs/external/Agent-C/GAPS-Agent-D-Programs.md`
- `playgrounds/docs/external/Agent-C/GAPS-Impl-vs-Spec-v0.md`
- `playgrounds/docs/external/Agent-C/TRANSITION-PLAN-v0.md`
- `playgrounds/docs/external/interview/interview-agent-D-1-analysis.md`

Context:

- `igniter-lang/docs/archive/history/history-s13-external-pressure-corpus-map.md`
- `igniter-lang/docs/archive/history/history-s14-external-pressure-fixture-backlog.md`
- `igniter-lang/docs/archive/history/history-s15-syntax-pressure-backlog-map.md`
- `igniter-lang/docs/archive/history/history-s16-playgrounds-rotation-1-approval-packet.md`

## Classification Table

| Signal | Category | Status | Curator Note |
| --- | --- | --- | --- |
| Forms as typed aliases over contracts | value_preserved | Strong | Keep as principle: form exposes meaning, contract defines meaning. |
| User syntax admitted, not trusted | value_preserved | Strong | Useful governance boundary for any future grammar work. |
| Compiler as trust boundary | value_preserved | Strong | Aligns with current proof/gate culture. |
| Runtime executes frozen artifacts | value_preserved | Strong | Good long-term artifact doctrine; not implemented as described. |
| `FormKind` taxonomy | research_unrealized | Live | Promising constraint against arbitrary grammar; exact set is not canon. |
| `.ifh`, `.iri`, `.ilk` artifacts | research_unrealized | Live | Valuable artifact model; filenames and pipeline are private research only. |
| `pure/observed/effect/privileged/irreversible contract` modifiers | research_unrealized | Live | Strong pressure from external programs, but not accepted canon here. |
| Effect Surface fields | research_unrealized | Live | Useful accountability schema; must be sliced before proposal work. |
| Profile as compile-time policy contract | research_unrealized | Live | High-value direction, likely larger than parser work. |
| Contract body as DAG | value_preserved | Strong | Compatible with Igniter roots; exact language semantics still proposal-only. |
| Evidence and receipts as first-class accountability | value_preserved | Strong | Preserve even if syntax changes. |
| Managed recursion / ServiceLoop | research_unrealized | Live | Important but Stage-4-scale; do not smuggle into current tracks. |
| `view`, `placement`, `write store <-`, `observes` shorthand | parked | Pressure-only | Useful gaps from programs; not ready for canon. |
| Direct "spec -> impl" migration | rejected_for_now | Do not do | Transition plan itself says route through existing PROP governance. |
| Exact Agent-C syntax | rejected_as_canon | Do not promote | Syntax is specimen, not public language contract. |
| Universal `external pure` style | superseded_history | Do not return | Superseded by declared effect taxonomy in private research. |

## Accepted / Implemented Signals

No Agent-C `PROP-*` document should be treated as accepted or implemented in
current `igniter-lang` just because it exists in `playgrounds/docs/external`.

Durable signals already compatible with the broader Igniter line:

- contracts-first thinking;
- compile-time validation before runtime execution;
- explicit evidence / trace / receipt orientation;
- no ambient magic;
- boundary between user-facing form and executable meaning;
- current-process respect: external pressure must become proposal work before
  canon changes.

The impl gap file explicitly marks current implementation as already having
some adjacent pieces: contracts, types, temporal helpers, invariants, modules,
imports, escape capability, `pipeline`, `fold_stream`, window semantics, OOF
classification, traits, and impls. Those are not proof that the new research
spec is implemented; they are bridge points.

## Values Preserved

### Meaning Before Convenience

Forms are valuable only when they expose already-declared contract meaning.
They must not become macros, runtime grammar mutation, or implicit global
syntax injection.

### Declared Consequences

The research line replaces "side effects" with "undeclared effects." This value
is worth preserving even if future syntax is completely different: every
external consequence should have authority, reversibility, idempotency, failure
shape, and receipt obligations appropriate to its risk.

### Evidence Over Trust

Evidence and receipts are not commentary. They are the durable memory of why a
result was allowed to exist and why an effect was trusted.

### Compiler As Security Boundary

User syntax, external effects, profiles, and loops all converge on the same
doctrine: the compiler admits and freezes meaning; runtime should not invent or
reinterpret it.

### Managed Liveness

Long-running work does not always halt, but it must be observable, cancellable,
checkpointable, bounded per step, and honest about exhaustion or suspension.

## Superseded / Rejected Signals

Do not revive these as canon without a new explicit decision:

- arbitrary grammar extension by users;
- runtime form injection or runtime grammar mutation;
- exact `.ifh/.iri/.ilk` filenames as accepted artifacts;
- exact Agent-C grammar for `form`, `profile`, `service contract`, or
  `recursive_group`;
- universal `external pure` terminology;
- hidden recursion through normal self-calls;
- unbounded service loops without heartbeat/checkpoint/cancellation semantics;
- direct publication of private external research as current documentation.

## Research Still Alive

High-value future tracks, in conservative order:

1. **Contract modifiers slice**: evaluate whether `pure`, `observed`, `effect`,
   `privileged`, and `irreversible` can be introduced as additive parser /
   classifier pressure, independent from full profile/effect runtime semantics.
2. **Evidence/receipt slice**: define the smallest useful `output ... evidence`
   or receipt-surface primitive.
3. **Forms boundary slice**: decide whether FormKind-like constraints are the
   right way to keep syntax extensibility non-chaotic.
4. **Profile policy slice**: treat profiles as a compiler pass, not syntax
   sugar.
5. **Service/loop slice**: defer to a later stage; it touches runtime liveness,
   cancellation, checkpointing, and audit receipts.
6. **View / placement / store-write slice**: keep as pressure specimens until
   more programs demonstrate the same need.

## Duplicate / Rotation Recommendations

No files should be moved or deleted in this stage.

Recommended read temperatures:

| Area | Temperature | Recommendation |
| --- | --- | --- |
| `playgrounds/docs/external/README.md` | Hot | Keep as the private external workbench entrypoint. |
| `playgrounds/docs/external/Agent-C/README.md` | Hot | Keep as Agent-C line index. |
| `Agent-C/PROP-*.md` | Warm | Read by topic when preparing proposals; do not bulk-import. |
| `Agent-C/C0`, `C1`, `C5`, `C6`, `C7` | Warm | Useful for origin/value context; superseded by PROP docs for details. |
| `Agent-C/GAPS-*`, `TRANSITION-PLAN-v0` | Warm | Useful for routing external pressure into current process. |
| `external/interview/*-analysis.md` | Warm | Prefer analyses over raw transcripts. |
| `external/interview/*` raw transcripts | Cold | Keep as evidence; skip by default. |

Future rotation, after approval:

- Keep the external workbench private and indexed.
- Add a small topic index for Agent-C proposal families if the directory keeps
  growing.
- Do not link these documents from public docs until a proposal or accepted
  canon document exists.

## Unresolved Questions

- Is `FormKind` the right long-term constraint, or only a useful research
  placeholder?
- Which effect fields are essential for the first accepted slice?
- Should contract modifiers be parser-only first, or must they immediately carry
  typechecker/runtime obligations?
- Can profiles be introduced without creating a new stage lane?
- Are service loops part of Igniter-Lang's near-term scope, or a later runtime
  layer?
- Should `view` and `placement` belong to language canon, dev tooling, or an
  application layer?

## Stage-Close Handoff

Compact claim:

- Agent-C private research now forms a coherent language-pressure bundle:
  forms, declared effects, profiles, contract bodies, artifacts, and managed
  recursion all point toward accountable compilation.

Source set:

- `playgrounds/docs/external/Agent-C/`
- `playgrounds/docs/external/interview/`
- S13-S16 archive reports.

Categories applied:

- `value_preserved`
- `research_unrealized`
- `parked`
- `superseded_history`
- `rejected_as_canon`
- `rejected_for_now`

Values preserved:

- meaning before convenience;
- declared consequences;
- evidence over trust;
- compiler as trust boundary;
- managed liveness;
- proposal governance before canon.

Accepted / implemented signals:

- No new accepted canon from Agent-C private research.
- Current implementation has adjacent bridge points but not the Agent-C spec.

Superseded / rejected signals:

- exact Agent-C syntax as canon;
- universal `external pure`;
- arbitrary runtime grammar;
- unbounded hidden recursion;
- direct spec migration.

Research still alive:

- contract modifiers;
- evidence/receipt syntax;
- constrained forms;
- profile policy pass;
- managed recursion / service loops;
- views, placement, observed shorthands, store writes as later pressure.

Duplicate / rotation recommendations:

- Keep external README and Agent-C README hot.
- Prefer analyses and compact reports before raw transcripts.
- Do not rotate or publish without approval.

Unresolved questions:

- first accepted slice boundaries;
- profile lane ownership;
- effect field minimality;
- service-loop stage timing.

Changed files:

- `igniter-lang/docs/archive/history/history-s17-forms-research-snapshot.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

- **History-S18: External Effects Minimal Slice Map** — compress effect and
  contract-modifier pressure into a proposal-readiness map, separating values,
  additive parser candidates, typechecker obligations, and Stage-4 runtime
  obligations.
