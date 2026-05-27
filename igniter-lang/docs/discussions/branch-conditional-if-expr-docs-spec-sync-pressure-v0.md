# Branch Conditional If Expr Docs Spec Sync Pressure v0

Card: S3-R191-C2-X
Agent: [Igniter-Lang External Pressure Reviewer]
Role: external-pressure-reviewer
Mode: discussion
Initiator: architect-supervisor
Track: branch-conditional-if-expr-docs-spec-sync-pressure-v0

Context: internal — full read access to C1-D design, R190 acceptance docs, and
current spec files
Write access: none
Canon authority: none

---

## Question

Does the proposed `if_expr` docs/spec sync design (S3-R191-C1-D) introduce
overclaim risk, public/release/runtime/Spark drift, or wording imprecision that
would make the bounded C3-I sync unsafe — or is the design sound and the C3-I
write scope minimal enough to proceed?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-design-v0.md` (S3-R191-C1-D)
- `igniter-lang/docs/tracks/stage3-round190-status-curation-v0.md` (S3-R190-C3-S)
- `igniter-lang/docs/tracks/branch-conditional-if-expr-v0-implementation-acceptance-decision-v0.md` (S3-R190-C1-A)
- `igniter-lang/docs/discussions/branch-conditional-if-expr-v0-implementation-acceptance-pressure-v0.md` (S3-R190-C2-X)
- `igniter-lang/docs/spec/ch2-source-surface.md` (current state)
- `igniter-lang/docs/spec/ch3-type-system.md` (current state)
- `igniter-lang/docs/spec/ch5-compiler-pipeline.md` (current state)
- `igniter-lang/docs/spec/ch6-semanticir.md` (current state)

---

## Scope Check Matrix

| ID | Check | Evidence | Result |
| --- | --- | --- | --- |
| SC-1 | Proposed wording does not imply runtime/evaluator support | Ch2 proposed: "A missing else is not accepted source semantics for v0" — no runtime claim; Ch3 note: "Derivative OOF-TY0...remain accepted secondary diagnostics for now" — no runtime claim; Ch5 proposed non-claim: "runtime/evaluator execution remains closed" explicit; Ch6 proposed: SemanticIR shape only, no execute semantics implied | PASS |
| SC-2 | Proposed wording does not imply alpha/release scope changed | C1-D explicitly recommends excluding `docs/README.md` which correctly preserves "branch/conditional if_expr remains out of scope" for accepted release evidence; claim-risk survey result is "no public support claim should open in C3-I" | PASS |
| SC-3 | Proposed wording does not imply public demo/stable/production/all-grammar support | Required non-claims list in C1-D is comprehensive: 10 items including "public demo/stable/production/all-grammar claims remain closed"; Ch5 proposed non-claim sentence explicit | PASS |
| SC-4 | Proposed wording does not imply Spark/API/CLI support | No Spark content in any proposed spec section; Spark explicitly in required non-claims; public API/CLI explicitly in required non-claims | PASS |
| SC-5 | Internal compiler support correctly bounded to TypeChecker + typed SemanticIR | Ch5 proposed text says "TypeChecker owns OOF-IF1..OOF-IF4; typed SemanticIR lowering exists"; no parser/assembler/orchestrator implementation claims | PASS |
| SC-6 | OOF-IF1..OOF-IF4 and OOF-IF5 status are correct | Ch3 proposed diagnostic table has exactly OOF-IF1..OOF-IF4 with correct triggers; OOF-IF5 note says "unowned and outside v0"; consistent with R190 acceptance | PASS |
| SC-7 | Derivative OOF-TY0 wording is understandable enough for spec readers | C1-D proposes placing the semantic distinction in Ch3 text; the proposed note reads "Derivative OOF-TY0 type-mismatch diagnostics after rejected if_expr remain accepted secondary diagnostics for now"; self-contained enough to inform spec readers, but could be made self-documenting with one additional sentence (NB-3) | PASS (NB) |
| SC-8 | C3-I write scope is small and safe — no lib/, experiments/, release evidence, public API/CLI, or Spark files | Proposed write scope: 4 required spec docs + 2 optional index-only docs + track doc; explicitly excluded: `docs/README.md`, `docs/current-status.md`, `docs/tracks/README.md`, `experiments/**`, `lib/**`, release harness/evidence, public API/CLI docs, Spark | PASS |

Overall: **8/8 PASS** — no blockers.

---

## [Agree]

- The spec-lag finding table is accurate. All four chapter-level gaps are real:
  Ch2 BNF has optional `else`; Ch3 has no `if_expr` typing rule; Ch5 does not
  name `if_expr` in accepted internal surfaces; Ch6 has no `if_expr` expression
  node definition.

- The C1-D write-scope boundary is minimal and safe. The four required files are
  internal spec docs only. The two optional index files are doc-navigation only
  and carry no runtime or release authority.

- The explicit exclusion of `docs/README.md` is correct. That file's wording
  ("branch/conditional if_expr remains out of scope") describes the accepted
  release evidence boundary, not the general language support state. Rewriting it
  in a spec-sync card would be overclaim.

- The exclusion of `docs/current-status.md` and `docs/tracks/README.md` is
  correct. The current-status was updated by R190 C3-S. The tracks README rows
  describe historical release evidence, not current compiler state.

- The proposed Ch3 typing rule (Rule IF-v0) is correct and consistent with R187
  design, R188 proof acceptance, and R190 acceptance.

- The proposed Ch3 diagnostic table correctly lists OOF-IF1..OOF-IF4 with their
  accepted triggers and the OOF-IF5 out/unowned note.

- The proposed Ch5 non-claim sentence is explicit and correctly worded:
  "if_expr internal compiler support is not release evidence mutation, not public
  demo/stable/all-grammar support, not runtime/evaluator support, and not Spark
  support."

- The proposed Ch6 `if_expr` SemanticIR node shape is correct: flat
  `condition`/`then_branch`/`else_branch` with `resolved_type`, no branch
  wrappers, no `deps` key. The note about dependency union being a TypeChecker
  evidence policy rather than a SemanticIR field is precise.

- The R190 NB-1/NB-2 disposition is correct. Proof artifact cleanup (annotating
  `secondary_rules` in the proof summary JSON) belongs to a future
  proof-hygiene card, not an internal spec-sync. Including the semantic
  distinction in Ch3 text is the right approach and sufficient for spec
  readers without touching proof outputs.

- The required non-claims list for C3-I (10 items) is comprehensive.

- The suggested lightweight verification (`rg` + `git status`) is appropriate.
  No broad compiler proof rerun is needed for a docs-only sync card.

---

## [Challenge]

No blocking challenges.

One wording boundary to monitor in C3-I execution: the proposed Ch2 subsection
uses `Expr` as the branch body type in the v0 grammar:

```text
IfExpr := "if" Expr "{" Expr "}" "else" "{" Expr "}"
```

The current parser emits branch bodies as block structures
(`{ "stmts": [...], "return_expr": expr_or_nil }`), not bare expressions. The
existing ch2 grammar kernel already defines `BlockExpr := "{" Stmt* Expr "}"`,
which covers this reading correctly. The ambiguity is that a reader seeing `Expr`
in the branch position might infer that only a bare expression (no leading `let`
statements) is permitted. This is a precision gap in the proposed grammar text,
not an authority or scope problem. See NB-1 below.

---

## [Missing]

No blocking gaps in the C1-D design. Three non-blocking precision notes for
C3-I:

**NB-1: Ch2 branch grammar precision — clarify branches are BlockExpr, not bare Expr**

The proposed v0 grammar line `IfExpr := "if" Expr "{" Expr "}" "else" "{" Expr "}"` uses `Expr` for branch bodies. The actual parser emits branch bodies as `BlockExpr`-shaped structures (stmts + final expression). The existing grammar kernel has `BlockExpr := "{" Stmt* Expr "}"`, which subsumes this correctly, but a reader looking only at the v0 subsection grammar will not see the `BlockExpr` reference.

Recommended fix for C3-I:

```text
IfExpr := "if" Expr "{" BlockBody "}" "else" "{" BlockBody "}"
BlockBody := Stmt* Expr
```

Or, alternatively, reference `BlockExpr` explicitly:

```text
IfExpr := "if" Expr BlockExpr "else" BlockExpr
```

Either keeps the spec consistent with the parser's emitted shape without overstating it. This is a precision note, not a scope or authority issue.

**NB-2: Ch2 BNF update approach — choose "add note" rather than rewriting the BNF line**

C1-D says "Also update the BNF line from optional else to required else, or add an explicit note immediately below it." The BNF block in §2.2 is labeled "NOT a final grammar" and covers parser-tolerant behavior for multiple surfaces. Rewriting `IfExpr := "if" Expr "{" Expr "}" ("else" "{" Expr "}")?` to remove the `?` would change the canonical grammar kernel entry and could imply parser enforcement of required `else`, which the parser does not currently enforce (it emits `else: nil` for `OOF-IF2` detection).

Recommended approach: add a bounded note immediately below the existing BNF `IfExpr` line, reading:

```text
Note: The parser accepts the above tolerant shape. V0 accepted semantics require
else; a missing else produces OOF-IF2, not a parse error.
```

This preserves parser-tolerant BNF while making v0 semantics explicit. The v0 subsection in §2.x can additionally provide the required-else accepted grammar for reference.

**NB-3: Ch3 derivative OOF-TY0 note — add one sentence on propagation mechanism**

The proposed Ch3 note reads: "Derivative OOF-TY0 type-mismatch diagnostics after rejected if_expr remain accepted secondary diagnostics for now." This is correct but requires readers to infer why OOF-TY0 appears in negative cases. Adding one sentence on the mechanism makes the note self-documenting:

Recommended wording addition:

```text
Derivative OOF-TY0 type-mismatch diagnostics after rejected if_expr remain
accepted secondary diagnostics for now. These arise because a rejected if_expr
produces an Unknown resolved type, which downstream type-mismatch checks
(OOF-TY0 Type mismatch: expected ..., got Unknown) then flag as a secondary
consequence. They are not unsupported-expression diagnostics and do not indicate
an if_expr regression.
```

This eliminates the need for readers to cross-reference CM-10 or the C1-A
decision text to understand the distinction.

---

## [Sharper Question]

If C3-I syncs Ch5 to list `if_expr` in accepted internal compiler surfaces, is
there any risk that a reader will conclude the acceptance harness (release scope)
also covers `if_expr`?

Answer: Not if the non-claim sentence is included and `docs/README.md` is left
unchanged. The acceptance harness evidence and the internal compiler support
status are in separate documents with separate authority chains. The key guard is
that `docs/README.md` (which explicitly says `if_expr` is out of accepted release
evidence scope) must not be edited by C3-I. C1-D correctly excludes it. C3-I
must preserve that exclusion. Any spec reader who follows the release evidence
chain will land on the unchanged `docs/README.md` and see the correct
exclusion intact.

---

## [Route]

**Verdict: proceed — 8/8 PASS, no blockers.**

```text
checks total: 8
checks pass:  8
checks fail:  0
blockers:     none
non-blocking notes: 3

NB-1: Ch2 branch grammar precision — clarify branches are BlockExpr, not bare Expr
NB-2: Ch2 BNF update approach — prefer "add note below BNF line" over rewriting
      the tolerant-parser grammar entry
NB-3: Ch3 derivative OOF-TY0 note — add one sentence on Unknown-propagation
      mechanism to make note self-documenting
```

**Exact C3-I allowed boundary:**

```text
Allowed write scope:
  igniter-lang/docs/spec/ch2-source-surface.md   (required)
  igniter-lang/docs/spec/ch3-type-system.md      (required)
  igniter-lang/docs/spec/ch5-compiler-pipeline.md (required)
  igniter-lang/docs/spec/ch6-semanticir.md       (required)
  igniter-lang/docs/spec/README.md               (optional — index row only)
  igniter-lang/docs/language-spec.md             (optional — index note only)
  igniter-lang/docs/tracks/branch-conditional-if-expr-docs-spec-sync-v0.md

Do not include in C3-I:
  igniter-lang/docs/README.md
  igniter-lang/docs/current-status.md
  igniter-lang/docs/tracks/README.md
  igniter-lang/experiments/**
  igniter-lang/lib/**
  release harness or accepted release evidence files
  public API/CLI docs
  Spark docs/fixtures
  proof summary JSON files

Required non-claims in C3-I track doc (minimum):
  runtime/evaluator support remains closed
  lazy branch execution semantics not claimed
  release harness and accepted release evidence unchanged
  public demo/stable/production/all-grammar claims remain closed
  Spark remains closed
  public API/CLI remains unchanged
  parser syntax not widened
  classifier/orchestrator/assembler/.igapp/goldens/artifact hashes unchanged
  OOF-IF5 remains unowned/outside v0
  derivative OOF-TY0 is secondary type-propagation, not unsupported-if_expr
```

**Guidance for C3-I on NB items (non-binding):**

- NB-1: Clarify the branch position in the v0 grammar as `BlockExpr` or
  `BlockBody` rather than bare `Expr`, consistent with the parser's emitted shape
  and the existing `BlockExpr := "{" Stmt* Expr "}"` production.

- NB-2: Add a note below the existing BNF `IfExpr` line rather than rewriting
  the tolerant-parser grammar entry; use the required-else form in the v0
  subsection for spec purposes.

- NB-3: Extend the Ch3 derivative OOF-TY0 note with one sentence explaining
  the Unknown-propagation mechanism so readers do not need to cross-reference
  CM-10 or C1-A decision text.

Route: `track` — open C3-I with the above boundary.
