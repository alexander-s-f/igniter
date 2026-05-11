# Track: Compiler Profile R32 Shadow Chain Backreference v0

Card: background-foundation
Agent: `[Igniter-Lang Research Agent]`
Role: research-agent
Track: `compiler-profile-r32-shadow-chain-backreference-v0`
Status: done
Date: 2026-05-11

---

## Goal

Record the backreference from the R32 external pressure discussion to the
current compiler profile closure index, so the shadow proof dependency-map
request is visible in the track index.

This is a curation / research evidence slice. It does not authorize production
compiler profile adoption, production pack migration, compiler dispatch rewrite,
profile source parser work, `.igapp` / `.ilk` migration, or runtime execution
authority.

---

## Source Pressure

Source:

```text
docs/discussions/r32-durable-audit-prop032-and-compiler-profile-pressure-v0.md
```

The R32 pressure review called out:

```text
M-3: A dependency map (or index entry) for the shadow proof chain.
```

It observed that the background-foundation tracks form a tree, and that if an
upstream node changes, the regeneration order must be known. It also named
`compiler-profile-chain-closure-index-v0.md` as the likely place to address the
gap.

---

## Disposition

Disposition: `addressed-by-closure-index`

Current answering artifact:

```text
docs/tracks/compiler-profile-chain-closure-index-v0.md
```

The closure index now records the background compiler profile / pack chain from
the shadow profile proof through the ProgressionPack shadow boundary and this
R32 backreference. It functions as the current dependency-map answer for the
M-3 request.

---

## Boundary

This backreference confirms only that the shadow chain now has a visible index
and regeneration map.

It does not close the separate R32 pressure items:

```text
M-1: restart rebuild implementation card
M-2: PROP number decision for compiler_profile_id manifest feature
```

Those remain outside this curation slice.

---

## Guard

Added:

```text
experiments/compiler_profile_r32_shadow_chain_backreference/compiler_profile_r32_shadow_chain_backreference.rb
experiments/compiler_profile_r32_shadow_chain_backreference/out/compiler_profile_r32_shadow_chain_backreference_summary.json
```

Command:

```bash
ruby igniter-lang/experiments/compiler_profile_r32_shadow_chain_backreference/compiler_profile_r32_shadow_chain_backreference.rb
```

Result:

```text
PASS compiler_profile_r32_shadow_chain_backreference
```

Checks:

```text
discussion.names_m3_shadow_dependency_map
discussion.points_to_closure_index
track_records_m3_disposition
track_links_pressure_and_index
track_preserves_shadow_scope
closure_index_includes_backreference
```

---

## Explicit Non-Authorization

```text
No production CompilerKernel implementation
No CompilerPack migration
No compiler dispatch rewrite
No profile source parser implementation
No `.igapp` or `.ilk` format change
No runtime execution authority
No signed production audit claim
```

---

## Handoff

```text
Card: background-foundation
Agent: [Igniter-Lang Research Agent]
Role: research-agent
Track: compiler-profile-r32-shadow-chain-backreference-v0
Status: done

[D] Decisions:
- Recorded R32 M-3 as addressed by the compiler profile closure index.
- Kept M-1 and M-2 open; this slice only answers the shadow dependency-map ask.
- Preserved shadow-only authority boundaries.

[S] Signals:
- The R32 external pressure review already expected the closure index to answer M-3.
- The current closure index is the canonical navigation point for the background profile/pack proof chain.

[T] Tests:
- ruby igniter-lang/experiments/compiler_profile_r32_shadow_chain_backreference/compiler_profile_r32_shadow_chain_backreference.rb -> PASS
- ruby igniter-lang/experiments/compiler_profile_chain_closure_index/compiler_profile_chain_closure_index.rb -> PASS

[R] Risks:
- M-2 remains the important governance pressure: the manifest feature still needs an Architect-owned PROP number decision before acceptance.
- This backreference is not a replacement for production migration planning.

[Next]
- Continue with compiler-profile-manifest-prop-architect-decision-v0 if manifest governance is the next priority.
```
