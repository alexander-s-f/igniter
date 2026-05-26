# Igniter-Lang Release Notes

## 0.1.0.alpha.1 (alpha prerelease candidate — not yet published)

**Status:** alpha / prerelease candidate  
**Package:** `igniter_lang`  
**Executable:** `igc`  
**Tag candidate:** `igniter-lang-v0.1.0.alpha.1` (candidate only — no tag created)

---

### What This Is

This is the first public prerelease candidate for the `igniter_lang` package.
It is an alpha release of the bounded compiler CLI for the Igniter contract-native
language research workspace.

This is **not** a stable release, **not** a production release, and **not** a
public demo claim.

---

### Accepted Local Evidence (pre-publish)

The following local evidence was accepted for the prior internal version
(`0.1.0.pre.stage2`). Fresh smoke is required for `0.1.0.alpha.1` before any
publish authorization can be reconsidered.

| Evidence | Status |
|---|---|
| Repo-local compiler RC evidence | PASS (`0.1.0.pre.stage2`) |
| Local package install smoke | PASS (`0.1.0.pre.stage2`) |
| Bounded installed profile-source smoke | PASS (`0.1.0.pre.stage2`) |

The prior accepted gem SHA256 (`sha256:dba3f0044535e8c05ad913a02c08ab06bab1602fb085290f225de206505ba46a`)
is **invalidated** by this version change. It no longer applies.

---

### Required Fresh Smoke Before Publish Authorization

Because the version changed from `0.1.0.pre.stage2` to `0.1.0.alpha.1`, the
following fresh smoke must be run and accepted before any publish authorization
can open:

| Smoke | Required |
|---|---|
| Post-prep package/install smoke for `igniter_lang 0.1.0.alpha.1` | **yes** |
| Post-prep profile-source installed smoke for `igniter_lang 0.1.0.alpha.1` | **yes** |

Minimum checks required in each smoke run:

- gemspec syntax check
- `gem build` → `igniter_lang-0.1.0.alpha.1.gem`
- isolated gem install (no repo-relative `-I`)
- installed `igc` present at `$BIN_DIR/igc`
- `require "igniter_lang"` without repo path leak
- positive corpus compile via installed `igc`
- negative corpus refusal via installed `igc`
- valid finalized profile-source success
- malformed JSON profile-source preflight refusal
- semantic wrong-kind profile-source refusal
- artifact SHA256 captured for the new gem

---

### Bounded CLI

The installed `igc` CLI supports bounded contract compilation:

```text
igc compile SOURCE --out OUT.igapp
igc compile SOURCE --out OUT.igapp --compiler-profile-source PATH.json
```

`PATH.json` must be an already-finalized `compiler_profile_id_source` JSON object.
The CLI does not discover, default, finalize, or infer compiler profile sources.

---

### Exclusions

The following are **explicitly excluded** from this release:

| Surface | Status |
|---|---|
| Stable release | Not this version |
| Production-ready | No claim |
| Public demo-ready | No claim |
| All grammar support | No claim — bounded accepted corpus only |
| Branch/conditional `if_expr` | **Excluded** from first RC scope |
| Profile finalization | Closed — explicit finalized path transport only |
| Profile discovery | Closed |
| Profile defaulting | Closed |
| Named/generated profile lookup | Closed |
| Inline JSON profile source | Closed |
| Env/config/sidecar profile lookup | Closed |
| Spark integration | Out of scope |
| Ruby Framework compatibility | Not claimed |
| Runtime / Ledger / TBackend / BiHistory | Not claimed |
| Public API/CLI widening | No widening beyond accepted `--compiler-profile-source PATH.json` |
| RubyGems availability | Not yet — publish not authorized |
| Release execution | Closed pending fresh smoke and explicit authorization |
| Tag/push/sign/deploy | Closed |

---

### What Remains Closed

Release execution, RubyGems publish, git tag creation, git push, signing,
and deployment remain closed until:

1. Fresh package/install smoke passes for `igniter_lang 0.1.0.alpha.1`
2. Fresh profile-source installed smoke passes for `igniter_lang 0.1.0.alpha.1`
3. RubyGems version-collision check is run for `0.1.0.alpha.1`
4. Tag collision check is run for `igniter-lang-v0.1.0.alpha.1`
5. Explicit release-execution authorization is granted by a separate card

---

### Non-Claims

```text
not_stable:                              true
not_production_ready:                    true
not_public_demo_ready:                   true
not_all_grammar_support:                 true
branch_conditional_if_expr_excluded:     true
profile_finalization_closed:             true
profile_discovery_closed:                true
profile_defaulting_closed:               true
spark_out_of_scope:                      true
ruby_framework_compatibility_not_claimed: true
rubygems_available_claim:                false
release_execution_authorized:            false
tag_push_sign_deploy_authorized:         false
```
