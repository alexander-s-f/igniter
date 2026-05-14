# Portable Context Mnemonics Reconstruction Proof v0

Card: Shadow-MN-R1-C2-P1
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `portable-context-mnemonics-reconstruction-proof-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Shadow status: research-only. This track does not update canon, spec, cards,
gates, or implementation policy.

## Goal

Test whether compact Portable Context Mnemonics can reconstruct useful working
context for agents and humans.

Test material:

- Architect Supervisor super-role;
- cards vs tracks vs gates vs discussions;
- PROP-036 B1/B7/B8 status;
- remaining blockers B3/B4/B5/B6/B9;
- drift self-healing protocol;
- rule: evidence satisfied != formal closure != implementation authorization.

## Current Context Baseline

Normal prose baseline:

The Architect Supervisor is a super-role. Ordinary agents may recommend cards,
gate questions, pressure reviews, status updates, and drift repair, but only the
Architect Supervisor can issue gate decisions, mark authority-dependent blockers
formally closed, authorize implementation, change protected surface status, or
apply official drift self-healing.

Cards are assigned work units. Tracks are evidence/handoff documents produced by
assigned agents. Gates are authority decisions. Discussions are pressure and are
not canon or authorization by themselves.

For PROP-036 CLI exposure, the approved future CLI route is
`--compiler-profile-source PATH.json`, but CLI implementation remains held. B1
is now closed by the standalone artifact proof. B7 and B8 are closed by public
Ruby API docs plus Architect-approved source-comment deferral. B3, B4, B5, B6,
and B9 remain open. Evidence being satisfied does not imply formal closure, and
formal closure does not imply implementation authorization.

## Reconstruction Rubric

Each packet is scored 0-2 for each question.

| Score | Meaning |
| --- | --- |
| 0 | Not recoverable or likely misleading. |
| 1 | Recoverable with local project familiarity, but ambiguous. |
| 2 | Recoverable by a fresh reader with low risk of scope drift. |

Rubric questions:

1. Can recover current goal?
2. Can recover authority boundaries?
3. Can recover next action?
4. Can avoid forbidden scope widening?

## Packet A: Ultra-Compact

Mnemonic:

```text
MN-A:
ArchSup=super-role. C/T/G/D: card=work, track=evidence, gate=authority, discussion=pressure.
PROP036 CLI: future shape --compiler-profile-source PATH.json; impl HELD.
B1+B7+B8=CLOSED; B3/B4/B5/B6/B9=OPEN.
Drift repair only ArchSup. Evidence != closure != auth.
Next: close remaining blockers, no CLI code.
```

### Prose Expansion

The Architect Supervisor is the authority-bearing super-role. Cards define work,
tracks record evidence, gates decide authority, and discussions provide pressure
without becoming canon. PROP-036 CLI work has a future shape:
`--compiler-profile-source PATH.json`, but implementation is still held. B1,
B7, and B8 are closed; B3, B4, B5, B6, and B9 remain open. Only the Architect
Supervisor can perform official drift repair. Evidence, closure, and
implementation authorization are separate. The next action is to close the
remaining blockers without adding CLI code.

### Preserved Context

- Super-role authority distinction.
- Document-type distinction.
- PROP-036 current blocker state.
- Future CLI shape and implementation hold.
- No evidence/closure/auth conflation.

### Lost Or Ambiguous

- Does not say why B1 is closed.
- Does not say B7/B8 closure evidence.
- Does not list forbidden surfaces.
- Does not identify B6 scanner self-test requirement.
- "Drift repair only ArchSup" is terse and might be read too broadly.

### Suitability

| Use | Suitability | Notes |
| --- | --- | --- |
| External agents | Medium | Enough to prevent big mistakes, but lacks evidence detail. |
| New chats | Medium-high | Good bootstrap if paired with current file paths. |
| Inline ChatGPT mode | High | Compact enough to paste into a prompt. |

### Score

| Rubric question | Score |
| --- | --- |
| Current goal | 2 |
| Authority boundaries | 2 |
| Next action | 1 |
| Avoid forbidden scope widening | 1 |

Total: **6/8**.

## Packet B: Balanced

Mnemonic:

```text
MN-B:
Roles/docs:
  Architect Supervisor = super-role; only it opens official cards/gates, marks formal closure, authorizes implementation, protected-surface changes, and drift self-healing.
  Card = assigned unit. Track = evidence/handoff. Gate = authority decision. Discussion = pressure only.

PROP036 CLI state:
  Approved future route: igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json.
  Current public surface: Ruby facade only, transport-only.
  CLI implementation/path loading/JSON parsing remain held.

Blockers:
  B1 closed: standalone compiler_profile_source.stage3_proof.json emitted + validated via finalization_and_assembler_source_contract + scan hits 0.
  B7 closed: ruby-api.md caller docs.
  B8 closed: transport-only docs + Architect source-comment deferral.
  B3/B4/B5/B6/B9 open.

Rules:
  evidence satisfied != formal closure != implementation authorization.
  Drift self-healing can repair maps/cards, not authorize or hide drift.
Next: close B3/B4/B5/B6/B9 or get Architect decision; no CLI code until auth.
```

### Prose Expansion

The Architect Supervisor is a super-role. It alone owns official cards, gate
decisions, formal authority-dependent closure, implementation authorization,
protected surface changes, and official drift self-healing. A card is assigned
work, a track is evidence and handoff, a gate is authority, and a discussion is
pressure only.

For PROP-036, the future CLI shape has been approved as
`igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json`, but
only as a design route. The current public surface is the Ruby facade, which is
transport-only. CLI implementation, path loading, and JSON parsing in CLI remain
held.

B1 is closed because a standalone
`compiler_profile_source.stage3_proof.json` artifact is emitted, validated via
`finalization_and_assembler_source_contract`, and has zero exact forbidden-token
hits. B7 is closed because `ruby-api.md` documents the caller-facing shape. B8
is closed because transport-only docs landed and source-level comment visibility
was explicitly deferred by Architect decision. B3, B4, B5, B6, and B9 remain
open. Evidence satisfaction, formal closure, and implementation authorization
are separate states. The next action is to close the remaining blockers or get a
new Architect decision; do not add CLI code yet.

### Preserved Context

- Super-role boundary and ordinary-agent limits.
- Cards/tracks/gates/discussions distinction.
- PROP-036 approved future CLI shape.
- Current public surface remains Ruby facade only.
- B1/B7/B8 closure reasons.
- Remaining blockers.
- Drift repair boundary.
- Evidence/closure/auth separation.

### Lost Or Ambiguous

- Does not list all non-authorized downstream surfaces like loader/report,
  CompatibilityReport, `.ilk`, signing, RuntimeMachine, Ledger/TBackend, cache,
  production.
- Does not explain B3/B4/B5/B6/B9 contents individually.
- Does not name the exact gate paths.

### Suitability

| Use | Suitability | Notes |
| --- | --- | --- |
| External agents | High | Enough to orient without overloading. |
| New chats | High | Best balance of density and safety. |
| Inline ChatGPT mode | Medium-high | Pasteable, but may be a little long for tight contexts. |

### Score

| Rubric question | Score |
| --- | --- |
| Current goal | 2 |
| Authority boundaries | 2 |
| Next action | 2 |
| Avoid forbidden scope widening | 2 |

Total: **8/8**.

## Packet C: Verbose But Mnemonic

Mnemonic:

```text
MN-C:
Context grammar:
  Card -> assigned slice.
  Track -> slice evidence/handoff; can recommend, not authorize.
  Gate -> Architect authority decision; can close blockers/authorize/hold.
  Discussion -> pressure; route input, not canon.
  Architect Supervisor -> super-role; owns card opening, gate authority, formal closure, implementation auth, protected status, drift self-healing.

Drift self-healing:
  Allowed only through Architect path: create missing card files from exact chat text, update indexes, repair links/receipts, record supersession.
  Must not authorize implementation, widen scope, rewrite evidence, hide drift, or delete history.

PROP-036 CLI memory:
  Future route approved: --compiler-profile-source PATH.json.
  PATH.json means standalone finalized compiler_profile_id_source object.
  Current public surface: IgniterLang.compile(..., compiler_profile_source:) Ruby facade only; transport-only.
  CLI flags/path loading/JSON parsing/finalization/discovery/defaulting/loader/report/CompatibilityReport/goldens/.ilk/receipts/signing/dispatch/RuntimeMachine/Ledger/TBackend/cache/production remain closed.

Blocker map:
  B1 CLOSED: compiler_profile_source.stage3_proof.json emitted, top-level source object, validated through finalization_and_assembler_source_contract, exact forbidden-token hits 0.
  B7 CLOSED: docs/ruby-api.md linked and documents nil + finalized Hash-like compiler_profile_id_source.
  B8 CLOSED: public transport-only wording; source-comment visibility deferred by explicit Architect gate.
  B3 OPEN: path/parse refusal shape.
  B4 OPEN: nil/no-flag legacy proof.
  B5 OPEN: invalid-source no-artifact proof.
  B6 OPEN: negative-token scan with adversarial scanner self-test.
  B9 OPEN: pressure review.

Invariant:
  evidence satisfied != formal closure != implementation authorization.
  Closed blocker != CLI implementation auth.
Next:
  Close B3/B4/B5/B6/B9, then Architect implementation decision; until then no CLI code.
```

### Prose Expansion

The project has a document and authority grammar. A card is assigned work. A
track records evidence and handoff, but cannot authorize protected behavior by
itself. A gate is an Architect authority decision. A discussion is pressure and
must be routed before becoming canon or work. The Architect Supervisor is a
super-role and owns official card opening, gate decisions, formal closure,
implementation authorization, protected surface status, and official drift
self-healing.

Drift self-healing is limited. It may create missing card files from exact chat
text, repair indexes and links, and record supersession. It must not authorize
implementation, widen scope, rewrite evidence, hide drift, or delete history.

For PROP-036 CLI exposure, the future route is
`--compiler-profile-source PATH.json`, where the path points to a standalone
finalized `compiler_profile_id_source` object. The current public surface is
only the Ruby facade `IgniterLang.compile(..., compiler_profile_source:)`, and
that facade is transport-only. CLI flags, path loading, JSON parsing,
finalization, discovery, defaulting, loader/report, CompatibilityReport,
goldens, `.ilk`, receipts, signing, dispatch, RuntimeMachine, Ledger/TBackend,
cache, and production behavior remain closed.

B1 is closed because the standalone artifact exists, is a top-level source
object, validates through `finalization_and_assembler_source_contract`, and has
zero exact forbidden-token hits. B7 is closed because `docs/ruby-api.md` is
linked and documents the caller-facing Ruby API. B8 is closed because
transport-only wording exists and source-level comment visibility is deferred by
an explicit Architect gate. B3, B4, B5, B6, and B9 remain open. The next action
is to close those remaining blockers and then seek an Architect implementation
decision. Until then, no CLI code should be added.

### Preserved Context

- Full document grammar.
- Super-role boundary.
- Drift self-healing limits.
- PROP-036 future route and current public surface.
- All major non-authorized surfaces.
- B1/B7/B8 exact closure reasons.
- B3/B4/B5/B6/B9 meanings.
- Evidence/closure/auth invariant.
- Next action.

### Lost Or Ambiguous

- Still does not include exact file paths for every gate/doc.
- Does not include command matrix for B1.
- Does not explain all details of B3 hybrid refusal model.
- Longer packet may be less mnemonic for humans under stress.

### Suitability

| Use | Suitability | Notes |
| --- | --- | --- |
| External agents | Very high | Strong scope guard and enough detail to avoid drift. |
| New chats | High | Good bootstrap; may be paired with exact file links. |
| Inline ChatGPT mode | Medium | Useful but a little large for repeated pasting. |

### Score

| Rubric question | Score |
| --- | --- |
| Current goal | 2 |
| Authority boundaries | 2 |
| Next action | 2 |
| Avoid forbidden scope widening | 2 |

Total: **8/8**.

## Cross-Packet Findings

[D] Ultra-compact packets are good for reminding an already-oriented agent, but
they lose closure evidence and blocker meaning.

[D] Balanced packets are the best default for new chats and external agents.
They preserve enough evidence and authority boundaries without becoming a mini
track document.

[D] Verbose mnemonic packets are best when the risk is forbidden scope widening
or authority confusion.

[D] Mnemonics should include at least one hard invariant:

```text
evidence satisfied != formal closure != implementation authorization
```

Without that invariant, agents may treat a PASS proof as permission to build.

## Recommendation

Use the balanced packet as the default external validation prompt seed. Include
the verbose packet only when testing high-risk scope discipline.

Recommended external validation prompt:

```text
You are reviewing this compact Igniter-Lang context packet. Reconstruct:
1. current goal;
2. authority boundaries;
3. next safe action;
4. forbidden scope widenings.

Then answer:
- What is formally closed?
- What is evidence-satisfied but not implementation-authorized?
- What must not be implemented yet?

Packet:
<paste MN-B here>
```

Scoring expected from a competent external reviewer:

```text
Current goal: recover PROP-036 CLI blocker context and remaining safe work.
Authority: Architect Supervisor gates/closure/auth; tracks/discussions do not authorize.
Next action: close B3/B4/B5/B6/B9 or seek Architect decision; no CLI code.
Forbidden widening: CLI flags/path loading/JSON parsing/runtime/report/production.
```

## Handoff

```text
Card: Shadow-MN-R1-C2-P1
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: igniter-lang/portable-context-mnemonics-reconstruction-proof-v0
Status: done

[D] Decisions
- Balanced mnemonic packet is the best default.
- Ultra-compact packet is useful only as a reminder for already-oriented agents.
- Verbose mnemonic is best for high-risk authority/scope tests.
- Every packet should preserve the invariant: evidence satisfied != formal closure != implementation authorization.

[S] Signals
- Mnemonics can preserve useful working context if they encode authority state, blocker state, and next action.
- PROP-036 state is especially compressible because B1/B7/B8 and B3/B4/B5/B6/B9 form a compact status axis.

[T] Tests / Proofs
- Shadow reconstruction proof only; no parser/tooling/canon/spec updates.
- Three packets produced, expanded, and scored.

[R] Recommendation
- Use MN-B as the external validation prompt seed.
- Use MN-C for high-risk tests where forbidden scope widening is likely.

[Files] Changed
- `igniter-lang/docs/tracks/portable-context-mnemonics-reconstruction-proof-v0.md`

[Q] Open Questions
- Should future mnemonic packets include source file paths by default, or should paths be a separate attachment?
- Should mnemonic quality be evaluated by fresh agents who have not read current-status?

[X] Rejected
- Treating mnemonics as canon/spec.
- Implementing parser/tooling for mnemonics in this slice.
- Updating current-status or gate docs from shadow research.

[Next] Proposed next slice
- Run an external/fresh-agent validation prompt using MN-B and score reconstruction quality.
```
