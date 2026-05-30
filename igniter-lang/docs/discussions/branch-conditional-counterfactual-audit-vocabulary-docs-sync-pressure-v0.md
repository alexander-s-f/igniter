# Branch Conditional Counterfactual Audit Vocabulary Docs Sync Pressure v0

Card: S3-R207-C2-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-vocabulary-docs-sync-pressure-v0`

---

## Question

Did S3-R207-C1-I apply the bounded Option A docs-sync without claim drift, target
scope drift, forbidden vocabulary misuse, or accidental canonization of proof-local
branch-intention descriptors?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md` (C1-I track doc)
- `igniter-lang/docs/tracks/stage3-round206-status-curation-v0.md` (R206 status)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-spec-sync-decision-v0.md` (C4-A decision)
- `igniter-lang/docs/current-status.md` — R207 entry (live read)
- `igniter-lang/docs/dev/semantic-governance-heat-map.md` — new row (live read)
- `igniter-lang/docs/spec/README.md` — new index pointer (live read)

Verification commands run independently:

```bash
rg -n "would_result|would_output|would_fail|counterfactual result|counterfactual output|
  counterfactual failure|latent runtime value|latent runtime failure|latent execution|
  latent branch execution|simulated branch result|dry-run result|branch replay|
  replayed branch value" docs/current-status.md docs/dev/semantic-governance-heat-map.md
  docs/spec/README.md
# → CLEAR — no matches

rg -n "SemanticIR now emits branch_intention|supports counterfactual audit|
  RuntimeSmoke supports counterfactual|branch-level uses assumptions|
  dependency tracking or cache keys" docs/current-status.md
  docs/dev/semantic-governance-heat-map.md docs/spec/README.md
# → CLEAR — no matches

git show --name-only 11358925  # C1-I primary commit
# → docs/current-status.md, docs/dev/semantic-governance-heat-map.md,
#    docs/spec/README.md, docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md
```

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Edits stayed within Option A target set | PASS |
| SC-2 | `branch_intention` wording remains docs vocabulary / proof-local only | PASS |
| SC-3 | `if_expr_branch_intention` remains non-canonical | PASS |
| SC-4 | Assumptions remain premise capsule only; no PROP-032 branch syntax | PASS |
| SC-5 | No positive forbidden vocabulary in any touched file | PASS |
| SC-6 | No Level 2 dry-run wording as positive claim | PASS |
| SC-7 | No public counterfactual/runtime/API/report/receipt/schema claims | PASS |
| SC-8 | No Ch2/Ch5/Ch6/Ch7, PROP-032, language-spec.md, or code edits | PASS |
| SC-9 | No dependency/cache authority claim | PASS |
| SC-10 | No Spark/API/CLI claim | PASS |

**Result: 10/10 PASS — no blockers.**

---

## Detailed Findings

### SC-1: Option A Target Set Exact Compliance

Git history confirms exactly 4 files changed in the C1-I primary commit
(`11358925`):

```text
igniter-lang/docs/current-status.md
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-vocabulary-docs-sync-v0.md
```

This matches the C4-A / C5-S authorized write scope exactly:
- `docs/current-status.md` ✓
- `docs/dev/semantic-governance-heat-map.md` ✓
- `docs/spec/README.md` ✓
- C1-I track doc ✓

No lib/ files, no experiments/ files, no Ch2/Ch5/Ch6/Ch7, no PROP-032, and no
`language-spec.md` appear in the diff. Held files are confirmed untouched.

### SC-2: `branch_intention` Wording Correct

Three wording locations confirmed against C4-A required wording class:

**current-status.md narrative (lines 446–454):**
```text
R207 applies the bounded Option A docs-sync: current-status pointer,
semantic-governance heat-map row, and spec README index pointer; Level 1
branch-intention vocabulary is proof-local static audit vocabulary for
explaining actual and latent if_expr branches without evaluating latent
branches; not source syntax, not a SemanticIR schema field, not runtime
behavior, not public counterfactual audit support; spec-body chapter edits
remain held;
```
This is the exact wording class required by C4-A. ✓

**current-status.md log entry (line 1285–1286):**
```text
S3-R207-C1-I: Level 1 branch-intention vocabulary docs sync ✅ done;
Option A applied; current-status pointer, heat-map row, spec README pointer;
wording class confirmed; no code/grammar/runtime/report edits
```
✓

**spec/README.md row (line 77):**
```text
| — (no spec chapter; Level 1 static audit vocab, held) | — |
  experiments/branch_conditional_counterfactual_audit_concept_proof_v0/
  (46/46 PASS) | ⚙️ proof-local only — `branch_intention` Level 1 static
  audit vocabulary for explaining actual and latent if_expr branches without
  evaluating latent branches; `if_expr_branch_intention` non-canonical; not
  source syntax, not SemanticIR schema field, not runtime behavior; Level 2
  dry-run, grammar, runtime, reports/receipts closed |
```
The chapter-column reads "— (no spec chapter; Level 1 static audit vocab, held)"
with `held` label — correctly signals no canonical spec home exists yet. ✓

### SC-3: `if_expr_branch_intention` Non-Canonical

Three independent signals confirm non-canonical status:
1. Spec README chapter column: "no spec chapter; ... held"
2. Heat-map footnote: "Proof-local and non-canonical: `if_expr_branch_intention`
   is not a SemanticIR node kind or field, not a spec chapter, not a PROP,
   not parser/grammar/runtime/schema."
3. Spec README coverage cell: "`if_expr_branch_intention` non-canonical"

None of these placements imply canonical schema, compiler object, or report field.
The descriptor is presented as proof evidence only, pointing to the R205
experiment directory.

### SC-4: Assumptions / PROP-032 Boundary

Two PROP-032-related strings were found in touched files; both are negative
disclaimers, not positive claims:

**heat-map footnote:**
```text
Proof-local branch premise refs may be assumptions-shaped but are not PROP-032
branch syntax and are not PROP-032 receipt assumption_refs.
```

**current-status.md (line 3753):**
```text
proof-local `assumption_refs` must be disclaimed from PROP-032 receipt fields,
assumptions-shaped metadata is non-canonical unless a separate PROP/PROP-032
amendment accepts it
```

Both are boundary enforcement statements. `PROP-032-assumptions-block-v0.md` was
not touched (git diff confirms). No branch-level `uses assumptions` syntax is
mentioned or implied.

### SC-5 / SC-6 / SC-7: Forbidden Vocabulary and Claims Absent

Both rg scans returned CLEAR against all three touched files:

- 14 forbidden vocabulary terms (would_result, would_output, would_fail,
  counterfactual result/output/failure, latent runtime value/failure,
  latent execution, latent branch execution, simulated branch result, dry-run
  result, branch replay, replayed branch value): **all absent**
- 5 forbidden positive sentence patterns: **all absent**

The Level 2 dry-run firewall is maintained. The heat-map footnote mentions
"Level 2 dry-run" only in a closure statement: "Level 2 dry-run, dependency/cache
authority, reports/receipts/CompatibilityReport, and public counterfactual claims
remain closed." This is a permitted closed-surface reference, not a positive claim.

### SC-8: Held Files Untouched

Git diff confirms no spec-body chapter files:
- No `ch2-source-surface.md`
- No `ch5-compiler-pipeline.md`
- No `ch6-semanticir.md`
- No `ch7-runtime.md`
- No `docs/proposals/PROP-032-assumptions-block-v0.md`
- No `docs/language-spec.md`
- No `lib/**` code files
- No `experiments/**` code files

The "Held Files" table in the C1-I track doc explicitly names all held targets
and their reason.

### SC-9 / SC-10: No Dependency/Cache or Spark/API/CLI Claims

The heat-map footnote names "dependency/cache authority" only as closed: "Level 2
dry-run, dependency/cache authority, reports/receipts/CompatibilityReport, and
public counterfactual claims remain closed." The scan confirmed no positive
dependency/cache or Spark/API/CLI wording in any of the three touched files.

---

## Heat-Map Row Quality

The new heat-map row deserves a brief quality note. The row uses:

```
| `branch_intention` / `if_expr_branch_intention` (Level 1 static audit, proof-local)‡ | — | — | — | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | ⚙️ | sem |
```

All pipeline-stage columns are gated (🚫). The ⚙️ symbol marks it as
work-in-progress / proof-local. The footnote carries:
- evidence anchor (R205 BIA-1..BIA-10 46/46 PASS)
- non-canonical disclaimer
- full closure list (Level 2, dep/cache, reports/receipts/CompatibilityReport,
  public counterfactual)
- PROP-032 disclaimer

This is the most authoritative placement in the doc suite for governance-level
drift prevention. It is the correct first point of reference for any future card
that tries to promote branch_intention vocabulary beyond its current proof-local
status.

---

## Non-Blocking Notes

None. The implementation is tightly scoped, the wording matches C4-A requirements,
and the verification scans are clean.

---

## Verdict

```text
PASS — 10/10 PASS, no blockers, no non-blocking notes
```

S3-R207-C1-I applies the bounded Option A docs-sync correctly. The write scope
is exactly the C4-A / C5-S authorized target set. The wording class matches C4-A
requirements across all three touched documents. Forbidden vocabulary is absent
from all files (independently verified by live rg scans). `if_expr_branch_intention`
remains non-canonical across three independent signal points. PROP-032 references
are negative disclaimers. Held files are untouched.

---

## C3-A Recommendation

**Accept S3-R207-C1-I.**

Required acceptance decisions for C3-A:

1. **Accept the Option A docs-sync** as correctly applied within the authorized
   write scope.

2. **Accept the heat-map row** as the governance-level anchor for Level 1
   branch-intention vocabulary. All pipeline stages are gated. The footnote
   carries the required evidence anchor, non-canonical disclaimer, PROP-032
   disclaimer, and full closure list.

3. **Accept the spec README index pointer** as correctly labeled `proof-local only`
   and `non-canonical`, with `held` in the chapter column to signal no canonical
   spec chapter exists yet.

4. **Accept the current-status.md wording** as matching the C4-A required wording
   class exactly.

5. **Record the summary SHA** as anchor:
   The concept proof evidence anchor remains:
   `sha256:0fc1b8005833478a22abc816ed3bf74364ef7b21c263ea1a57450676d81a8a9a` (R205).
   R207 adds no new proof evidence; it records the existing evidence in the
   governance and discoverability surfaces only.

6. **Confirm held files remain held:** `language-spec.md`, Ch2/Ch5/Ch6/Ch7,
   PROP-032, public API/CLI docs, release docs, runtime/report/receipt/
   CompatibilityReport docs all require a later explicit gate before editing.

7. **Confirm Level 2 dry-run, runtime/report/API/public claims, and Spark/API/CLI
   remain closed.** The Option A sync is discoverability and anti-drift only,
   not schema or runtime canonization.

---

[Agree]
- Write scope is exactly Option A: 4 files changed, matching C4-A / C5-S
  authorization precisely.
- All three touched documents carry the C4-A required wording class.
- `if_expr_branch_intention` is non-canonical in all three touched documents,
  with independent signal points in the chapter column, heat-map footnote, and
  coverage cell.
- Forbidden vocabulary is confirmed absent by live rg scans across all touched files.
- PROP-032 references are negative disclaimers, not positive grammar claims.
- The heat-map row is the appropriate governance anchor; all pipeline stages gated.

[Challenge]
- None.

[Missing]
- Nothing. The implementation is complete and clean.

[Sharper Question]
- The spec README row points to the experiments/ directory as the only evidence
  base; if a future card tries to add `branch_intention` to a spec chapter, what
  is the minimum evidence package (beyond R205) required to justify that move?

[Route]
- accept — C3-A should accept S3-R207-C1-I unconditionally.
