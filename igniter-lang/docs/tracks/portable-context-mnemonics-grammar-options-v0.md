# Track: Portable Context Mnemonics Grammar Options v0

Card: Shadow-MN-R1-C1-P1
Agent: `[Igniter-Lang Compiler/Grammar Expert]`
Role: compiler-grammar-expert
Track: `portable-context-mnemonics-grammar-options-v0`
Route: UPDATE
Status: done
Date: 2026-05-14

Affected neighbor roles: `[Igniter-Lang Research Agent]`,
`[Igniter-Lang Meta Expert]`, `[Igniter-Lang Bridge Agent]`

---

## Boundary

Portable Context Mnemonics are explored here as a shadow-language for agent
orchestration memory.

They are not Igniter-Lang syntax.

This track does not propose parser implementation, modify accepted spec, create
new language semantics, or canonize mnemonic notation.

---

## Goal

Explore a compact, guessable grammar for mnemonic memory lines such as:

```text
Dispatch: R49 = C1-A -> C2-X -> C3-S
AUTH:PROP036
B1 = evidence_satisfied -> needs ArchitectFormalClosure
Gate > TrackClaim
Done != Accepted
```

The design target is not mathematical completeness. It is portable compression:
an agent should be able to read a line, recover the intended shape, and ask a
good follow-up question without a manual.

---

## Symbol Vocabulary

| Symbol | Mnemonic role | Reading |
| --- | --- | --- |
| `:` | namespace / frame | "inside this topic" |
| `=` | assertion / current state | "is currently" |
| `->` | sequence / transition | "then / leads to" |
| `+` | conjunction / package | "and, bundled with" |
| `|` | alternatives | "or / one of" |
| `>` | precedence / authority | "outranks / gates" |
| `!` | prohibition / alert | "not allowed / blocked" |
| `!=` | distinction | "not the same as" |
| `[]` | set / list / parallel group | "these items together" |
| `{}` | scoped fields / object-like memory | "details for this thing" |
| `()` | parameters / guards | "under this condition" |
| `(())` | higher-order / meta constraint | "rule about rules" |
| `@` | authority / source reference | "according to this source" |
| `#` | tag / status | "status marker" |

Recommended recovery rule:

```text
When unsure, read left to right, expand the symbol into its English role, and
prefer authority/precedence before state claims.
```

---

## Variant 1: Minimal Readable Grammar

### Shape

This variant keeps lines close to English notes.

```text
Line        := Frame ":" Claim
Frame       := Word | Word "." Word | Word "/" Word
Claim       := Assertion | Sequence | Precedence | Distinction | Package
Assertion   := Term "=" State
Sequence    := Term "=" Step ("->" Step)+
Precedence  := Term ">" Term
Distinction := Term "!=" Term
Package     := Term "=" "[" Item ("," Item)* "]"
Source      := Claim "@" SourceRef
Tagged      := Claim "#" Tag
```

Informal grammar only. It is for humans, not parsers.

### Examples

Observed dispatch:

```text
Dispatch: R49 = C1-A -> C2-X -> C3-S
```

Authority:

```text
AUTH:PROP036 = accepted + bounded_partial
```

Blocker state:

```text
PROP036.CLI:B1 = evidence_satisfied -> needs ArchitectFormalClosure
```

Authority precedence:

```text
PROP036: Gate > TrackClaim
```

State distinction:

```text
PROP036: Done != Accepted
```

Current Stage 3 / PROP-036 memory:

```text
Stage3: status = open
PROP036: state = accepted + bounded_partial
PROP036: landed = [source_finalization, assembler_field, orchestrator_transport, ruby_facade, ruby_api_docs]
PROP036.CLI: route = design_approved -> implementation_held
PROP036.CLI: B7+B8 = closed
PROP036.CLI: B1 = evidence_satisfied -> needs ArchitectFormalClosure
PROP036.CLI: blocked = [cli_impl, path_loading, loader_report, compatibility_report, goldens, receipts, ilk, signing, dispatch, runtime, production]
PROP036: Gate > TrackClaim
```

### Strengths

- Most guessable for new agents.
- Easy to write in handoffs.
- Handles observed mnemonics without new punctuation.
- Good for status maps and pressure reviews.

### Weaknesses

- Ambiguous when multiple `=` claims appear in one line.
- No strong distinction between state, route, and evidence unless the frame
  names it.
- Harder to mechanically lint.

---

## Variant 2: Dense Operational Grammar

### Shape

This variant compresses route, authority, blockers, and status into one or two
lines.

```text
OpLine      := Subject "{" Field (";" Field)* "}" Tags?
Field       := Key "=" Value
Value       := Atom | List | Transition | Choice | Package | Guarded
List        := "[" Value ("," Value)* "]"
Transition  := Atom "->" Atom ("->" Atom)*
Choice      := Atom "|" Atom
Package     := Atom "+" Atom
Guarded     := Atom "(" Guard ")"
Authority   := Subject "@" Source
Rule        := Subject ">" Subject | Subject "!=" Subject | "!" Subject
Tags        := "#" Tag ("#" Tag)*
```

### Examples

Dispatch:

```text
Dispatch{R49=C1-A->C2-X->C3-S} #route
```

PROP-036 memory:

```text
PROP036{
  auth=accepted;
  impl=bounded_partial;
  landed=[finalize,assembler,orchestrator,facade,ruby_api_docs];
  CLI=design_approved->held;
  blockers=[B1:formal_gate,B3/B6,B4,B5,B9];
  closed=[B7,B8];
  blocked=[cli_impl,path_loading,loader_report,compat_report,goldens,receipts,ilk,signing,dispatch,runtime,production]
} @current-status #stage3
```

Authority and distinction rules:

```text
Rule{Gate>TrackClaim; Done!=Accepted; !CLIImpl(without=B1+B3+B4+B5+B6+B9)}
```

Blocker:

```text
PROP036.CLI{B1=evidence_satisfied->ArchitectFormalClosure}
```

### Strengths

- Very compact for round maps.
- Good for copy/paste into status capsules.
- Makes scoped fields obvious.
- Easy to compare two states visually.

### Weaknesses

- Less friendly to humans who dislike punctuation-heavy notes.
- Nested objects can become mini-JSON without JSON's precision.
- `:` inside fields can conflict with namespace reading unless style is
  disciplined.

### Style Rules For Recovery

Use this convention if pressure-testing Variant 2:

```text
Subject{field=value; field=value}
Frame.Subframe{...}
field=[a,b,c]
blocked=[surface1,surface2]
closed=[B7,B8]
held means approved design but no implementation
```

---

## Variant 3: Typed / Contract-Like Grammar

### Shape

This variant is more explicit about what kind of memory is being asserted.

```text
Memory<Type>: Name {
  field: Value
  relation: A > B
  distinction: A != B
  transition: A -> B
  guard: Action(condition)
  source: @SourceRef
  status: #Tag
}
```

Type names are descriptive only:

```text
Route
Authority
Blocker
State
NonAuth
Dispatch
```

No parser or typechecker is implied.

### Examples

Dispatch:

```text
Memory<Route>: Dispatch.R49 {
  sequence: C1-A -> C2-X -> C3-S
  status: #planned
}
```

PROP-036 state:

```text
Memory<State>: PROP036 {
  authority: accepted
  implementation: bounded_partial
  landed: [source_finalization, assembler_field, orchestrator_transport, ruby_facade, ruby_api_docs]
  cli_route: design_approved -> implementation_held
  source: @current-status
}
```

CLI blockers:

```text
Memory<Blocker>: PROP036.CLI {
  closed: [B7, B8]
  pending: [B1_formal_closure, B3_B6, B4, B5, B9]
  B1: evidence_satisfied -> needs ArchitectFormalClosure
}
```

Authority contract:

```text
Memory<Authority>: PROP036.CLI {
  relation: Gate > TrackClaim
  distinction: Done != Accepted
  prohibition: !CLIImplementation(until=[B1,B3,B4,B5,B6,B9,ArchitectGate])
  source: @prop036-cli-blocker-closure-criteria-decision-v0
}
```

Higher-order constraint:

```text
Memory<MetaRule>: Closure {
  rule: ((TrackDone != GateAccepted))
  rule: ((EvidenceSatisfied -> NeedsFormalClosure))
}
```

### Strengths

- Best for high-stakes authority distinctions.
- Makes source and type of claim visible.
- Good bridge to future documentation/governance tools.

### Weaknesses

- Too verbose for quick handoff mnemonics.
- Looks more canonical than it is, which is dangerous.
- The `<Type>` and `{}` style may tempt parser/spec work prematurely.

---

## Ambiguity Risks

| Risk | Example | Recovery rule |
| --- | --- | --- |
| `:` can mean namespace or field separator | `AUTH:PROP036` vs `B1:formal_gate` | If before `{}` or before a full claim, read as frame. Inside `{}`, prefer field label. |
| `=` can mean identity or current state | `B1 = evidence_satisfied` | Read as current-state assertion unless the frame says `alias` or `id`. |
| `->` can mean sequence or causal transition | `C1-A -> C2-X` vs `evidence -> closure` | If terms are cards, read as sequence. If terms are states, read as transition. |
| `+` can hide dependency order | `accepted + bounded_partial` | Treat `+` as unordered package; use `->` when order matters. |
| `>` can mean authority or numeric greater-than | `Gate > TrackClaim` | In mnemonic context, read as precedence/authority unless numeric terms appear. |
| `!` can mean alert or prohibition | `!CLIImpl` | Read as "not allowed" when attached to an action/surface. |
| `[]` can mean list or parallel work | `[B7,B8]` | Treat as set unless paired with `->`. |
| `{}` can look like JSON | `PROP036{...}` | Treat as memory fields, not data interchange. |
| `@` can mean source or user mention | `@current-status` | In mnemonics, read as source authority. |
| `#` can mean markdown header | `#stage3` | Inside a line, read as tag/status. |

General recovery protocol:

1. Expand symbols into their mnemonic role.
2. Identify the frame before trusting the claim.
3. Prefer explicit authority lines over implicit state lines.
4. Treat track docs as evidence and gate docs as authority when `>` conflicts.
5. If a mnemonic would affect implementation authority, ask for the source path.

---

## Recommendation

Pressure-test Variant 1 first:

```text
Minimal Readable Grammar
```

Reason:

- It is closest to the observed mnemonics.
- It is readable without a manual.
- It has the lowest chance of being mistaken for Igniter-Lang syntax.
- It supports quick handoffs and external pressure reviews.

Use Variant 2 as a compression layer only after Variant 1 proves useful in
real handoffs.

Hold Variant 3 for governance-heavy cards where authority, closure, and
non-authorization need to be explicit. Do not use Variant 3 broadly yet; it
looks too much like a formal contract language and could invite premature
canonization.

Suggested pressure-test packet:

```text
AUTH:PROP036 = accepted + bounded_partial
Dispatch:R49 = C1-A -> C2-X -> C3-S
PROP036.CLI:B1 = evidence_satisfied -> needs ArchitectFormalClosure
PROP036.CLI:B7+B8 = closed @S3-R47-C3-A
PROP036.CLI:implementation = held
PROP036: Gate > TrackClaim
PROP036: Done != Accepted
PROP036: blocked = [cli_impl,path_loading,loader_report,compat_report,goldens,receipts,ilk,signing,dispatch,runtime,production]
```

Expected external-review question:

```text
Can a reviewer recover the state, authority, and open blockers from those lines
without reading this track first?
```

---

## Non-Authorization

This track does not authorize:

- Igniter-Lang syntax;
- parser implementation;
- source grammar changes;
- accepted spec changes;
- SemanticIR changes;
- runtime behavior;
- CLI behavior;
- canonical mnemonic standardization;
- machine-readable governance tooling.

---

## Handoff

```text
Card: Shadow-MN-R1-C1-P1
Agent: [Igniter-Lang Compiler/Grammar Expert]
Role: compiler-grammar-expert
Track: portable-context-mnemonics-grammar-options-v0
Status: done

[D] Decisions
- Treat Portable Context Mnemonics as shadow orchestration-memory notation only.
- Sketch three variants: minimal readable, dense operational, typed/contract-like.
- Recommend pressure-testing the minimal readable grammar first.

[S] Shipped / Signals
- Added symbol vocabulary, grammar sketches, Stage 3 / PROP-036 examples,
  ambiguity risks, and recovery rules.

[T] Tests / Proofs
- Documentation-only shadow research; no implementation or spec changes.

[R] Risks / Recommendations
- Avoid Variant 3 as a default because it looks canonical.
- Use authority/source refs whenever a mnemonic could be mistaken for a gate.

[Next]
- External pressure-test the minimal readable packet against new reviewers.
```
