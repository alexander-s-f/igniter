# Portable Context Mnemonics Shadow Round Synthesis v0

Card: Shadow-MN-R1-C4-S
Agent: [Igniter-Lang Meta Expert]
Role: meta-expert
Track: portable-context-mnemonics-shadow-round-synthesis-v0
Route: UPDATE
Status: done
Date: 2026-05-14

Shadow status: research-only. This track does not promote Portable Context
Mnemonics to a PROP, does not update canonical spec, and does not authorize
parser/tooling implementation.

---

## Inputs Read

- `docs/tracks/portable-context-mnemonics-grammar-options-v0.md`
- `docs/tracks/portable-context-mnemonics-reconstruction-proof-v0.md`
- `docs/discussions/portable-context-mnemonics-comprehension-pressure-v0.md`

## Shadow-Round Synthesis

Portable Context Mnemonics are compact, human-writable memory packets for agent
handoff across sessions, models, and systems. Their purpose is not to encode a
formal language; it is to preserve enough context for a fresh agent to recover:

- what is being worked on;
- who or what has authority;
- what is safe to do next;
- what must not be widened or implemented.

Round 1 produced a coherent result:

- C1 sketched three variants and recommended Variant 1, Minimal Readable
  Grammar, for first pressure testing.
- C2 showed that balanced packets are the best default. Ultra-compact packets
  lose safety detail; verbose packets are useful when authority drift is likely.
- C3 agreed the concept is promising, but identified five priority risks:
  invariant dropout, `:` ambiguity, `->` dual semantics, `@`/`#` prior collision,
  and Variant 3 canonization gravity.

## Decisions

| Question | Decision | Reason |
|----------|----------|--------|
| Does this remain shadow research? | yes | No external validation yet; notation can be mistaken for canon if promoted early. |
| Continue as Agent Orchestra DNA feature? | continue as candidate | The packets directly solve cross-agent context bootstrapping and authority preservation. |
| Bridge into Igniter-Lang later? | later only | Possible future bridge is into orchestration/handoff practice first, not language syntax. Any Igniter-Lang bridge needs separate evidence and authority. |
| Which variant should be externally tested? | Variant 1 Minimal Readable, using balanced MN-B style | It is most guessable, least canon-looking, and already scored best for fresh handoff. |
| Should Variant 2 be tested? | not first | Useful compression layer after V1 passes. |
| Should Variant 3 be tested? | no | Typed/contract-like shape creates parser/spec/canonization pressure. |

## External Validation Prompt v0

Use this prompt with two external agents on different models/systems. Do not
give them C1/C2/C3, current-status, project docs, or prior chat context.

```text
You are reviewing a compact project context format called Portable Context
Mnemonics.

Portable Context Mnemonics are shadow orchestration-memory notes. They are not
Igniter-Lang syntax, not a spec, not a parser target, and not implementation
authority. Their job is to compress context so a fresh agent can reconstruct:
- the current work;
- authority boundaries;
- the next safe action;
- risks, blockers, and forbidden scope widening.

Reading guide:
- `[MN]` marks a mnemonic packet.
- `:` frames a topic.
- `=` states current state.
- `->` means sequence when both sides look like card IDs; otherwise read it as
  state transition.
- `+` means a bundled set of facts.
- `[]` is a list or set.
- `>` means authority/precedence.
- `!=` means "must not be conflated with".
- `!` means blocked, prohibited, or not authorized.
- `@` means source reference and `#` means tag/status, but note if either symbol
  feels ambiguous.
- `Rule:` lines are safety invariants and should override compact state claims.

Packet 1:
[MN] PROP036.CLI:
  goal = validate future compiler-profile-source route without implementation
  future_route = igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
  current_public_surface = Ruby facade only + transport-only
  closed = [B1,B7,B8]
  open = [B3,B4,B5,B6,B9]
  Rule: Evidence != Closure != Auth
  Rule: ClosedBlocker != CLIImplementationAuth
  next = close open blockers -> Architect implementation decision
  !implement = [CLI flags,path loading,JSON parsing,loader report,goldens,receipts,ilk,signing,dispatch,runtime,production]

Packet 2:
[MN] AuthorityDocs:
  Card = assigned work
  Track = evidence + handoff
  Discussion = pressure only
  Gate = authority decision
  ArchitectSupervisor > TrackClaim
  TrackDone != ProposalAccepted
  next = ask gate if authority or protected surface changes

Packet 3:
[MN] ShadowMN:
  status = shadow research #shadow
  continue = AgentOrchestraDNA candidate
  bridge_to_IgniterLang = later only(after external validation + authority)
  test_variant = V1 Minimal Readable + balanced packet
  hold = [V2 compression,V3 typed_contract_like]
  !promote = [PROP,spec,parser,tooling]
  source = @C1_C2_C3

Tasks:
1. Reconstruct the prose context for each packet.
2. Identify all authority boundaries.
3. Identify the next safe action.
4. Identify what is not authorized.
5. Identify risks or ambiguities in the notation itself.
6. Suggest syntax improvements that would make the packets safer or clearer.

Required yes/no answers:
- Is CLI implementation currently authorized?
- Are Portable Context Mnemonics Igniter-Lang syntax?
- Should the mnemonic notation be promoted to a PROP now?

Report every symbol you found ambiguous, especially `:`, `->`, `@`, and `#`.
```

## Evaluation Notes

Pass bar for this shadow round:

- Both external agents reconstruct the key authority boundary: only an Architect
  gate can authorize implementation or protected-surface change.
- Both answer "no" to CLI implementation authorization.
- Both answer "no" to Portable Context Mnemonics being Igniter-Lang syntax.
- Both answer "no" to immediate PROP promotion.
- Each agent scores at least 7/8 on the C2 rubric: current goal, authority
  boundaries, next action, forbidden-scope avoidance.
- Symbol misreads are recorded, especially for `:`, `->`, `@`, and `#`.

Failure route:

- If either agent says implementation is authorized, strengthen the invariant
  line and retest before broader adoption.
- If either agent treats `[MN]` as canon/spec, make the shadow-register marker
  louder and remove Variant 3 from all public packets.
- If `@`/`#` are misread, avoid them in default packets and keep source/tag
  labels as words: `source = ...`, `status = ...`.

## Recommendation

Continue, but keep it shadow. Treat Portable Context Mnemonics as an Agent
Orchestra DNA candidate for cross-agent handoff, not as Igniter-Lang language
work.

Formalize later only if the two-model validation passes and the notation proves
that it preserves authority boundaries better than prose handoff under model
switching. The likely first formalization target would be operating practice or
agent handoff templates, not Ch2 grammar, PROP text, parser work, SemanticIR, or
runtime tooling.
