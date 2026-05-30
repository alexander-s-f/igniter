# Branch Conditional Counterfactual Audit Level 2 Source-Backed Vocabulary Docs Sync Pressure v0

Card: S3-R213-C3-X  
Agent: `[Igniter-Lang External Pressure Reviewer]`  
Role: `external-pressure-reviewer`  
Mode: discussion  
Initiator: user  
Track: `branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-pressure-v0`

---

## Question

Did S3-R213-C2-I apply the bounded Option A-min docs sync without claim drift,
target drift, forbidden vocabulary misuse, or accidental canonization of
proof-local source-backed Level 2 evidence?

---

## Inputs Read

- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md` (C2-I track doc)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-authorization-review-v0.md` (C1-A)
- `igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-spec-decision-v0.md` (R212-C4-A)
- `igniter-lang/docs/tracks/stage3-round212-status-curation-v0.md`
- `igniter-lang/docs/dev/semantic-governance-heat-map.md` — new row (live read)
- `igniter-lang/docs/spec/README.md` — new index row (live read)

Independent verification commands run:

```bash
git show --name-only 4d79264c ec97e787
# → 3 files: heat-map, spec README, track doc (all authorized)

rg -n "would_result|...|alternate_actual_output" heat-map.md spec/README.md
# → CLEAR — no matches

rg -n "counterfactual audit support|...|PROP-032 branch syntax" heat-map.md spec/README.md
# → 3 matches: lines 88, 96, 97 of heat-map.md
# → All in block-quote footnote § in "not X" / "are not Y" negative constructions

grep -n "current-status" <<< "$(git show --name-only 4d79264c ec97e787)"
# → current-status.md: NOT IN DIFF

grep -E "lib/|PROP-032|language-spec|ch2-|ch5-|ch6-|ch7-" <<< "$git diff"
# → CLEAR — none of the held files in diff
```

---

## Scope-Check Matrix

| ID | Check | Verdict |
|----|-------|---------|
| SC-1 | Exact allowed file compliance (3 files matching C1-A scope) | PASS |
| SC-2 | No body spec chapter edit | PASS |
| SC-3 | No public doc edit | PASS |
| SC-4 | PROP-032 untouched | PASS |
| SC-5 | `docs/current-status.md` not touched (closed for C2-I per C1-A) | PASS |
| SC-6 | Accepted vocabulary preserved as proof-local/non-canonical | PASS |
| SC-7 | Forbidden claim set absent except when listed as negative/non-claim | PASS |
| SC-8 | No report/result/receipt/cache/API/CLI/Spark/runtime/public authority wording | PASS |
| SC-9 | No implementation or live-surface changes | PASS |
| SC-10 | No machine-readable authority/result-field drift | PASS |

**Result: 10/10 PASS — no blockers, no non-blocking notes.**

---

## Explicit Required Answers

**1. Is wording safe enough to accept?**

Yes. Both touched files carry the correct proof-local/non-canonical wording:

*Heat-map row:* all pipeline stages gated (🚫), ⚙️ symbol, "(proof-local)§" label. The `§` footnote reads: "`source_backed_dry_run_projection` is not a SemanticIR node kind or field, not emitted by compiler surfaces, not a spec chapter, not a PROP, not parser/grammar/runtime/schema, not a report/receipt/CompatibilityReport field."

*Spec README row:* "no spec chapter; source-backed Level 2 evidence, held" in chapter column; "non-canonical" in coverage cell; "body spec chapters, PROP-032, runtime/report/API, and public claims remain closed."

Both placements are structurally consistent with the R207/R211 precedents (Level 1 `branch_intention` row, Level 1 spec README pointer). The wording class matches C1-A requirements.

**2. Does any forbidden phrase appear as a claim?**

No. Scan 1 (17-term forbidden vocabulary): **CLEAR** — independently confirmed, zero matches.

Scan 2 (over-broad positive claims): 3 matches found, all in the `§` footnote block-quote prose:

| Location | Text | Classification |
|----------|------|----------------|
| heat-map line 88 | `are not PROP-032 branch syntax` | Negative — existing ‡ footnote; carries "are not" |
| heat-map line 96 | `not PROP-032 branch syntax` | Negative — new § footnote; carries "not" |
| heat-map line 97 | `not public counterfactual audit support` | Negative — new § footnote; carries "not" |

All three are in "not X" / "are not Y" constructions in block-quote footnote text. C1-A permits this: "forbidden terms may appear only in explicit 'forbidden', 'non-claim', 'negative-disambiguation', or 'closed-surface' sections." All three qualify. No forbidden phrase appears as a positive feature label, projection field name, or public claim.

**3. Does negative disambiguation stay outside machine-readable authority or result fields?**

Yes. All three Scan 2 matches appear in Markdown block-quote footnote prose (lines prefixed `>`). These are human-readable annotation text, not machine-readable JSON fields. C1-D's formalized policy requires negative disambiguation to be "excluded from machine-readable authority fields." The heat-map footnote is prose, not a structured data field. No JSON artifact or authority-carrying data structure contains the forbidden terms. The C1-D policy is satisfied.

**4. Does the sync create pressure to amend PROP-032 or body spec chapters now?**

No. The opposite: the wording explicitly forecloses such pressure. The § footnote says "not a spec chapter, not a PROP." The spec README row says "body spec chapters, PROP-032, runtime/report/API, and public claims remain closed." These statements make the closure visible at the exact points where future readers might otherwise infer it: the governance map (where authority claims are typically registered) and the spec coverage index (where chapter assignments are listed).

The sync does not introduce any new vocabulary into spec-body chapters. It adds only a low-authority discoverability row and a footnote, both labeled non-canonical and proof-local.

---

## Detailed Findings

### SC-1: File Compliance

Git history confirms exactly 3 files across the two C2-I commits (`4d79264c`, `ec97e787`):
```text
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

C1-A authorized scope:
```text
igniter-lang/docs/dev/semantic-governance-heat-map.md
igniter-lang/docs/spec/README.md
igniter-lang/docs/tracks/branch-conditional-counterfactual-audit-level2-source-backed-vocabulary-docs-sync-v0.md
```

Exact match. `docs/current-status.md` is confirmed absent from diff (closed for C2-I per C1-A explicit decision).

### SC-2 / SC-3 / SC-4 / SC-5: Held Files Absent

Independent grep confirms:
- Ch2/Ch5/Ch6/Ch7 body chapters: **absent**
- `docs/language-spec.md`: **absent**
- `docs/proposals/PROP-032-assumptions-block-v0.md`: **absent**
- `lib/**` code files: **absent**
- Public API/CLI/release/runtime/report docs: **absent**
- `docs/current-status.md`: **absent**

### SC-6: Vocabulary Preserved as Proof-Local/Non-Canonical

**Heat-map:** The new row uses `source_backed_dry_run_projection` as the term label, with `(proof-local)§` inline qualifier, all pipeline stage columns gated to `🚫`, and the ⚙️ (work-in-progress/proof-local) symbol. The `§` footnote explicitly states non-canonical status at the level of individual facts: not a SemanticIR node, not emitted, not a schema, not a report field.

**Spec README:** Row uses "no spec chapter; source-backed Level 2 evidence, held" in the chapter column — "held" signals to future readers that no spec chapter exists yet and none is implied. Coverage cell: "⚙️ proof-local only." Both signals are consistent with the Level 1 precedent row immediately above.

### SC-7: Forbidden Vocabulary Only in Negative Context

Three Scan 2 matches at lines 88, 96, 97. All are in the `§` footnote block-quote. The surrounding context makes the negative framing unambiguous:

```
...not PROP-032 branch syntax and are not PROP-032 receipt assumption_refs.
Level 2 projection is not public counterfactual audit support, not runtime
behavior, not public API/CLI, and not Spark/production support.
```

This pattern matches the precedent established by the Level 1 `‡` footnote (line 88 is already in that footnote): "Level 2 dry-run, dependency/cache authority, reports/receipts/CompatibilityReport, and public counterfactual claims remain closed."

### SC-8: No Authority Wording

The spec README row explicitly lists closures: "body spec chapters, PROP-032, runtime/report/API, and public claims remain closed." The heat-map footnote lists eight distinct non-claims in "not X" form. No sentence in either file asserts a positive authority or runtime capability.

### SC-10: No Machine-Readable Field Drift

The only new machine-readable additions are the heat-map table row (a pipe-delimited Markdown row) and the spec README table row. Neither contains forbidden terms. The block-quote footnotes are human-readable annotation; they are not parsed as authority data. No JSON was modified.

---

## Verdict

```text
PASS — 10/10 PASS, no blockers, no non-blocking notes
C4-A may accept S3-R213-C2-I unconditionally
```

The Option A-min sync is cleanly executed. Exactly 3 authorized files changed.
Both touched documents carry proof-local/non-canonical labels with all pipeline
stages gated. Scan 1 (17-term) returns CLEAR. Scan 2 returns 3 negative-
disambiguation matches in footnote prose, all acceptable per C1-A policy and
C1-D formalized negative disambiguation rule. No machine-readable field contains
forbidden terms. No body spec chapter, PROP-032, language-spec, current-status,
lib/, or public doc was touched. The sync does not create pressure to amend
PROP-032 or body chapters — it explicitly forecloses such pressure at both target
surfaces.

---

## C4-A Recommendation

**Accept S3-R213-C2-I unconditionally.**

Required acceptance decisions for C4-A:

1. **Accept the heat-map row** (`source_backed_dry_run_projection` / proof-local §)
   as the governance-level discoverability anchor for source-backed Level 2 evidence.
   All pipeline stages gated; footnote carries complete non-claim list.

2. **Accept the spec README row** as an index pointer labeled proof-local / held.
   Chapter column "held" correctly signals no body chapter promotion.

3. **Confirm negative disambiguation placement is correct:** The three Scan 2
   matches in the `§` footnote prose are acceptable under C1-D's formalized
   negative disambiguation policy (human-readable footnote prose; visibly negative
   "not X" constructions; absent from machine-readable authority fields).

4. **Confirm all closed surfaces remain closed:** `docs/current-status.md`,
   Ch2/Ch5/Ch6/Ch7, `language-spec.md`, PROP-032, lib/, public/API/CLI/release
   docs — all absent from the diff.

5. **Confirm no pressure on PROP-032 or spec chapters:** The wording explicitly
   forecloses both at the governance map and spec index level.

---

[Agree]
- Write scope exactly matches C1-A: 3 files, all authorized, none held.
- Scan 1 CLEAR; Scan 2 matches are all visibly-negative footnote prose.
- Negative disambiguation placement in block-quote footnote prose (not JSON)
  satisfies C1-D formalized policy.
- Heat-map row and spec README row are structurally consistent with the R207/R211
  Level 1 precedents.
- The sync explicitly forecloses spec-chapter and PROP-032 pressure in the exact
  surfaces where future readers would look for it.
- `docs/current-status.md` correctly not touched per C1-A decision.

[Challenge]
- None.

[Missing]
- Nothing. The implementation is complete and clean.

[Sharper Question]
- The heat-map now has three proof-local rows in Domain 2 (PROP-032 assumptions,
  Level 1 branch_intention, source-backed Level 2). When is the right moment to
  consolidate these into a structured "counterfactual audit lane" row, and does
  that consolidation require a new C4-A or just a Status Curator card?

[Route]
- accept — C4-A should accept S3-R213-C2-I unconditionally.
