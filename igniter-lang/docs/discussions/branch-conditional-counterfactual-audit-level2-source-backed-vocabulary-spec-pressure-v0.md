# Branch Conditional Counterfactual Audit Level 2 Source-Backed Vocabulary Spec Pressure v0

Card: S3-R212-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-pressure-v0`

---

## Question

Do the S3-R212-C1-D vocabulary/spec boundary design and S3-R212-C2-P1 source-backed
doc target survey correctly fence the source-backed Level 2 vocabulary against
claim inflation, keep forbidden terms controlled, prevent "source-backed" from
implying canonical SemanticIR schema, prevent "Level 2" from implying live runtime
evaluation, close PROP-032 and report/receipt/API surfaces, and propose only a
minimal safe docs-sync target set?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-boundary-v0.md` (C1-D)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-source-backed-doc-target-survey-v0.md` (C2-P1)
- `igniter-lang/docs/tracks/stage3-round211-status-curation-v0.md` (R211 status)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-proof-acceptance-decision-v0.md` (R211-C4-A)

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Accepted vocabulary stays internal/proof-local | PASS |
| SC-2 | Forbidden positive claim vocabulary fenced (17 terms + over-broad list) | PASS |
| SC-3 | "source-backed" does not imply canonical SemanticIR schema | PASS |
| SC-4 | "Level 2" does not imply live runtime non-selected branch evaluation | PASS |
| SC-5 | "counterfactual audit support" not used as public support claim | PASS |
| SC-6 | "dry-run result" remains forbidden | PASS |
| SC-7 | PROP-032 remains unamended; premise-capsule-only | PASS |
| SC-8 | Report/result/receipt/cache/API authority remains closed | PASS |
| SC-9 | Spark/API/CLI remain closed | PASS |
| SC-10 | Proposed docs-sync target set is minimal and safe | PASS |

**Result: 10/10 PASS — no blockers. PASS with 2 non-blocking notes.**

---

## Compact PASS/HOLD Table

| Surface | Verdict | Evidence |
|---------|---------|----------|
| Internal/proof-local vocabulary scope | PASS | C1-D table: all terms marked "Accepted proof-local" or "Accepted internal"; no public/canonical label |
| 17-term forbidden vocabulary | PASS | Both cards carry identical list; C1-D: "Does dry-run result remain forbidden? Yes" |
| Over-broad claims list (new) | PASS | C1-D adds: `counterfactual audit support`, `runtime counterfactual support`, `public counterfactual support`, `counterfactual runtime` |
| "source-backed" ≠ canonical SemanticIR | PASS | C1-D: "source artifacts are proof-owned SemanticIR-shaped JSON, not canonical SemanticIR schema"; Ch6 held |
| "Level 2" ≠ live runtime evaluation | PASS | C1-D: closed surfaces; C2-P1: Ch7 "Held/highest-risk"; scan includes "runtime can evaluate latent branches" |
| "counterfactual audit support" blocked | PASS | C1-D over-broad list; allowed replacement: "proof-local source-backed Level 2 counterfactual dry-run evidence" |
| `dry-run result` forbidden | PASS | In 17-term list in both cards; C1-D explicit answer |
| PROP-032 unamended | PASS | C1-D dedicated section; C2-P1 holds PROP-032; extended scan includes "branch-level uses assumptions", "PROP-032 branch syntax" |
| Report/result/receipt/cache/API closed | PASS | Closed surfaces; scan includes "receipt contains counterfactual", "source_branch_intention_ref is a CompilationReport field" |
| Spark/API/CLI closed | PASS | Both cards; scan includes "public API supports counterfactual dry-run", "CLI supports counterfactual dry-run" |
| Docs-sync target set | PASS | Both cards converge on A-min: heat map + spec README + track doc; ch2/ch5/ch6/ch7/language-spec held |

---

## Detailed Findings

### SC-1: Internal/Proof-Local Vocabulary Scope

C1-D organizes vocabulary into three tiers:
- **Level 1** (from R207): `branch_intention`, `actual_branch`, `latent_branch`, `non_execution_guarantee` — accepted low-authority docs vocabulary
- **Level 2** (from R208/R209): `counterfactual_dry_run`, `dry_run_projection`, `projected_value`, `projected_failure`, `premise_set` — proof-local field vocabulary
- **Source-Backed Level 2** (new from R211): `source-backed proof-local Level 2 counterfactual dry-run evidence`, `source_branch_intention_ref`, `source_branch_intention_evidence_packet`, `input_snapshot_ref`, `premise_set_ref`, `execution_summary_citation`, `sha256:<hex>` — all marked "Accepted proof-local ref vocabulary" or "Accepted internal vocabulary"

None carry "public", "canonical", "runtime", or "schema" status. This is correct.

### SC-2: Forbidden Vocabulary Fencing

The 17-term forbidden list is identical to R206/R207/R208/R209/R210/R211. C1-D adds an important new "over-broad" class:

```text
counterfactual audit support
runtime counterfactual support
public counterfactual support
counterfactual runtime
```

This is a positive development — it closes the drift channel where someone might
write "counterfactual audit support is now proof-local" thinking the word
"proof-local" makes the phrase safe. The allowed replacement is precisely worded:
`proof-local source-backed Level 2 counterfactual dry-run evidence`.

C2-P1 extends the scan set further, adding semantic drift patterns:
```text
runtime can evaluate latent branches
runtime can dry-run latent branches
SemanticIR emits branch_intention
SemanticIR emits source_branch_intention_ref
source-backed branch intentions are SemanticIR
source_branch_intention_ref is a CompilationReport field
dry_run_projection is a CompatibilityReport field
receipt contains counterfactual
public API supports counterfactual dry-run
CLI supports counterfactual dry-run
```

This is the most comprehensive forbidden-phrase scan set established in this
lane. It correctly anticipates future drift vectors from schema promotion and
runtime capability claims.

### SC-3: "source-backed" ≠ Canonical SemanticIR Schema

C1-D spec-body stance: "source artifacts are proof-owned SemanticIR-shaped JSON,
not canonical SemanticIR schema." Ch6 is explicitly held. The forbidden scan
pattern `"SemanticIR emits source_branch_intention_ref"` in C2-P1 directly
closes this drift channel.

C2-P1 unsafe table: "Ch6 — Held/high-risk — Source artifacts are SemanticIR-
shaped proof artifacts, not canonical SemanticIR schema." The distinction is
maintained: "shaped like" ≠ "emitted by" ≠ "part of."

### SC-4: "Level 2" ≠ Live Runtime Non-Selected Branch Evaluation

C1-D closed surfaces: "Live non-selected branch evaluation." Ch7 is explicitly
held "for no runtime support authority." The governing principle is repeated:
"Runtime is lazy. Audit is aware. Dry-run, if ever accepted, must be isolated."

C2-P1 rates Ch7 as "Held/highest-risk" — the same risk rating from R206-C2-P1
for the original Level 1 sync. The forbidden scan includes both "runtime can
evaluate latent branches" and "runtime can dry-run latent branches" — correctly
distinguishing live runtime from proof-local dry-run.

### SC-5: "counterfactual audit support" Blocked

C1-D explicitly addresses this: "Is 'counterfactual audit support' still too
broad? Yes. It implies public/runtime support unless heavily qualified; avoid
it as a positive claim." It is in the "over-broad" list in C1-D and in C2-P1's
extended scan ("counterfactual audit support landed").

Both cards provide safe replacement wording at multiple granularities:
- Long: "proof-local source-backed Level 2 counterfactual dry-run evidence: ..."
- Short: "source-backed proof-local Level 2 evidence; non-canonical; no runtime/report/API authority"
- Index: "No spec chapter: source-backed Level 2 counterfactual dry-run evidence is proof-local and non-canonical"

### SC-6: "dry-run result" Remains Forbidden

Both cards: in the 17-term list. C1-D explicit answer: "Yes." The accepted guarded
replacement (`dry_run_projection`, `projected_value`, `projected_failure`) is
consistently used throughout the vocabulary tables.

### SC-7: PROP-032 Unamended

C1-D dedicated PROP-032 section with a comprehensive forbidden implications list:
- no branch-level `uses assumptions`
- no PROP-032 grammar extension
- no receipt `assumption_refs` change
- no runtime assumption injection
- no cross-module assumption sharing
- no evidence-list validation expansion

C2-P1: "Should PROP-032 remain untouched? Yes." PROP-032 is in the unsafe/held
table. The extended scan explicitly includes "branch-level uses assumptions" and
"PROP-032 branch syntax." The PROP-032-safe wording provided is precise and
covers the key ambiguities.

### SC-8 / SC-9: Report/API/Spark Closure

C1-D closed surfaces covers all report/result/receipt/CompatibilityReport/cache
dependency/public API/CLI/Spark surfaces. C2-P1 puts all corresponding docs in
the unsafe/held table. The extended scan explicitly closes schema promotion
channels: "source_branch_intention_ref is a CompilationReport field", "receipt
contains counterfactual", "public API supports counterfactual dry-run", "CLI
supports counterfactual dry-run."

### SC-10: Docs-Sync Target Set Minimal and Safe

Both cards converge on the same "Option A-min":
```text
docs/dev/semantic-governance-heat-map.md
docs/spec/README.md
docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

`current-status.md` is optional/no-op in both cards. All spec-body chapters,
`language-spec.md`, PROP-032, public docs, and runtime/report/API docs are held.
C2-P1 adds a conservative "hold" option: "if the sole goal is status awareness,
hold." This is a valid alternative that C4-A should explicitly address.

---

## New Contributions Analysis

**C1-D key addition — Negative Disambiguation Policy (formalized)**

C1-D formalizes what was ad hoc practice (R209 harness comment, R211
`execution_summary_citation.note`):

```text
allowed only in explanatory metadata notes, pressure docs, or track docs;
must be visibly negative or contrastive;
must not appear as projection field names or projection values;
must not appear as feature labels;
should be excluded from machine-readable authority fields.
```

The scan rule is also formalized: "forbidden terms may appear only in explicit
'forbidden', 'non-claim', 'negative disambiguation', or 'closed surface' sections."

This is a positive and overdue formalization. It provides a principled basis for
the NB-1 informational note from S3-R211-C3-X (the `"note"` field in the JSON).

**C2-P1 key addition — Extended Semantic Drift Scan Set**

C2-P1 provides two rg commands covering both the 17-term list and 17 additional
over-broad positive claim patterns. This is the most comprehensive vocabulary
guard specification in this lane and is directly actionable for the future
docs-sync implementation.

---

## Non-Blocking Notes

**NB-1 (C4-A choice required — hold or proceed with A-min):**

Both cards present "hold" as a valid option if discoverability is the sole goal.
C2-P1 states: "`current-status.md` already carries enough detail after R211 and
the R212-C1 design boundary." C4-A must make an explicit positive selection
between:

- **Option A-min:** heat map + spec README + track doc (C1-D and C2-P1 recommended)
- **Hold:** no docs-sync; status awareness via current-status.md already sufficient

Unlike R206, where the target-set choice was needed to unblock an implementation
card, here both options are independently valid. C4-A's decision should be driven
by whether external discoverability on the heat map is needed at this point in
the lane.

**NB-2 (precision — "machine-readable authority fields" boundary):**

C1-D's negative disambiguation policy says forbidden terms in notes "should be
excluded from machine-readable authority fields." This is a forward-looking policy
note, but the R211 summary JSON's `execution_summary_citation.note` field — which
contained "not latent execution evidence" — is a JSON field, which is arguably
machine-readable. C1-D's policy now establishes the forward standard: such notes
should appear in human-readable doc sections or prose disclaimers rather than
JSON metadata fields.

C4-A should note that future proof routes (from R212+) must place negative
disambiguation text outside machine-readable JSON result fields, consistent with
C1-D's formalized policy. The R211 case is grandfathered as the policy-motivating
precedent.

---

## Verdict

```text
PASS with 2 non-blocking notes
10/10 PASS, no blockers
C4-A may accept C1-D and C2-P1 and choose Option A-min or Hold
```

The vocabulary/spec boundary is correctly designed. The over-broad claim list
expansion in C1-D closes drift channels that the 17-term list alone does not
cover. The negative disambiguation policy formalization is a genuine improvement.
The extended scan set in C2-P1 is the most comprehensive guard specification in
this lane. Both cards converge on the same minimal safe target set. All required
surfaces remain closed.

---

## Mandatory Notes for C4-A

| Note | Required C4-A action |
|------|---------------------|
| NB-1 | Choose Option A-min (heat map + spec README + track doc) or Hold explicitly; both are valid |
| NB-2 | Record that future proof routes must place negative disambiguation text outside machine-readable JSON fields, per C1-D formalized policy |

---

[Agree]
- The over-broad claims list in C1-D (adding `counterfactual audit support`,
  `runtime counterfactual support`, `public counterfactual support`,
  `counterfactual runtime`) is a necessary extension that closes drift channels
  the 17-term list alone does not cover.
- The negative disambiguation policy formalization in C1-D resolves the
  uncertainty raised by R211-C3-X NB-1 in a principled, forward-compatible way.
- C2-P1's extended scan set (two rg commands, 17+17 patterns) is directly
  actionable and provides the most comprehensive implementation guide yet for
  a docs-sync acceptance check.
- Both cards converge on the same minimal A-min target set without C4-A needing
  to break a tie between different recommendations.
- "counterfactual audit support" correctly prohibited; allowed replacement is
  sufficiently precise to be unambiguous in practice.

[Challenge]
- None.

[Missing]
- NB-1: C4-A must make an explicit choice between A-min and Hold.
- NB-2: Future proof routes need explicit awareness of C1-D's
  machine-readable boundary for negative disambiguation notes.

[Sharper Question]
- The NB-1 "hold vs proceed" question reduces to: is heat-map discoverability
  valuable before a public wording gate for Level 2 exists? If the answer is
  "only internal teams read the heat map," then holding is fine. If there are
  external readers (onboarding agents, cross-team users) who benefit from the
  heat-map row, A-min is worth the small effort.

[Route]
- accept — C4-A should accept C1-D and C2-P1, then choose explicitly between
  Option A-min and Hold, with NB-2 recorded as a forward constraint on future
  proof routes.
