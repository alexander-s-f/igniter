# Line Up Summarizer Memory Pilot Report v0

Status: done
Owner: [Org Architect Supervisor]
Date: 2026-05-17
Scope: non-authority process pilot

---

## Summary

The operational-contract memory schema was tested against the
`line-up-summarizer` role.

Verdict: useful and safe as a compact role-instance memory pattern, provided it
stays explicitly below canonical role profiles and authority docs.

---

## Read Set

```text
igniter-lang/roles/line-up-summarizer.md
igniter-lang/docs/lineups/README.md
igniter-lang/docs/org/memory-contracts/operational-contract-memory-v0.md
```

---

## Findings

### F1 - Memory captures role friction cleanly

The Line Up Summarizer has a small but important QA hazard: the exact sentence
below must remain a standalone line:

```text
source remains authoritative for exact proof logs.
```

Putting this into operational memory gives future instances a cheap self-check
without requiring broad rereads.

### F2 - Memory can preserve boundaries without changing authority

The pilot records that Line Up Summarizer may summarize and recommend
disposition labels, but must not decide canon, move documents, delete
documents, or rewrite authority indexes outside an assigned card.

### F3 - QA drift candidates exist

These Line Ups appear to contain the QA phrase inside a longer line instead of
as the standalone anchor expected by the role profile:

```text
igniter-lang/docs/lineups/stage2-compiler-package-spine.md
igniter-lang/docs/lineups/stage2-to-stage3-typed-switch-spine.md
```

No fix was applied in this org-sidecar slice. Route to a future Line Up
Summarizer cleanup card if needed.

---

## Recommendation

Continue with operational-contract memory, but keep it as a sidecar pattern.

Next safe step:

```text
Create a small role-instance memory index under docs/org/indexes/ only after
one more role pilot, preferably History Curator or Archive/Form Expert.
```

Do not promote this to all roles until at least two pilots prove that the memory
reduces rereads without creating competing authority.
