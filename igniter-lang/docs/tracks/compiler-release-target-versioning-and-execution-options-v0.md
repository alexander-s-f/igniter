# Compiler Release Target Versioning And Execution Options v0

Card: S3-R170-C1-P1
Agent: [Igniter-Lang Release Target Analyst]
Role: release-readiness-agent
Track: compiler-release-target-versioning-and-execution-options-v0
Route: UPDATE
Status: done
Date: 2026-05-24

---

## Summary

Recommended stance:

```text
authorize no irreversible release execution yet
prefer repo-local RC marker if movement is desired now
run local package/install smoke before any installed-gem or public release claim
```

The accepted official evidence proves:

```text
repo_local_compiler_rc
```

It does not establish installed-gem readiness for the current first-RC scope,
does not select a version/tag, and does not justify a public gem release.

Public gem release is premature.

---

## Evidence Read

- `igniter-lang/docs/tracks/compiler-release-readiness-package-acceptance-decision-v0.md`
- `igniter-lang/docs/tracks/compiler-release-readiness-summary-package-v0.md`
- `igniter-lang/docs/discussions/compiler-release-readiness-summary-package-pressure-v0.md`
- `igniter-lang/docs/tracks/official-first-rc-evidence-acceptance-and-next-release-vector-decision-v0.md`
- `igniter-lang/experiments/compiler_release_official_first_rc_evidence_v0/out/official_first_rc_evidence_summary.json`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/lib/igniter_lang/version.rb`
- `igniter-lang/bin/release-gate`
- `igniter-lang/docs/tracks/gem-release-policy-v0.md`
- `igniter-lang/docs/tracks/gem-release-automation-v0.md`
- `igniter-lang/docs/tracks/gem-native-package-boundary-specs-v0.md`
- `igniter-lang/experiments/release_gate/release_gate.json`
- `rg "VERSION|version|release|gemspec|tag" igniter-lang`

---

## Current Package / Version Facts

| Surface | Current fact |
| --- | --- |
| Gemspec | `igniter-lang/igniter_lang.gemspec` exists |
| Gem name | `igniter_lang` |
| Version source | `igniter-lang/lib/igniter_lang/version.rb` |
| Current version | `0.1.0.pre.stage2` |
| Gem executable | `igc` |
| Repo compatibility executable | `bin/igniter-lang` exists but is not listed as gem executable |
| Release gate | `igniter-lang/bin/release-gate` exists |
| Release gate publish behavior | builds local gem/checksum and stops; `gem push` forbidden |
| Historical release gate status | PASS in `experiments/release_gate/release_gate.json` |
| Historical local artifact | `/private/tmp/igniter_lang_release_gate/igniter_lang-0.1.0.pre.stage2.gem` |
| Historical package/install proof | gem-native package boundary proof exists and has PASS history |

Important distinction:

```text
Historical package/install proof exists for the current package skeleton, but
the accepted official first-RC evidence scope remains repo_local_compiler_rc.
Installed-gem readiness for the current first-RC release target is not
established until a fresh package/install smoke is explicitly authorized and
accepted.
```

---

## Explicit Answers

### Is installed-gem readiness currently established?

```text
No, not for the accepted official first-RC release scope.
```

There is historical local package/install evidence and release-gate evidence
for `igniter_lang-0.1.0.pre.stage2`, but the official first-RC evidence
accepted in R168 is `repo_local_compiler_rc` only. Installed-gem readiness must
be re-established if the release target includes installability or public gem
claims.

### Can any version/tagging decision be made from current evidence?

```text
Only a non-irreversible repo-local marker decision can be made safely.
```

Current evidence can support a docs/status marker such as "first official
repo-local compiler RC evidence accepted." It does not select a publishable gem
version, a public tag, or a pushed release tag.

### Is public gem release premature?

```text
Yes.
```

Reasons:

- accepted official evidence is repo-local, not installed package evidence;
- version/tagging policy is not decided;
- public docs/non-claims are not prepared;
- package/install matrix for current target is not freshly accepted;
- RubyGems publish requires explicit approval and human MFA action.

### Safest target if movement is desired now

```text
repo-local RC marker only
```

This is reversible, matches accepted evidence, and avoids version/tag/publish
side effects.

---

## Options Table

| Option | Version/tagging stance | Reversible actions | Irreversible actions | Required command/proof matrix | User approval boundary | Risk | Recommendation |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A. Repo-local RC marker only | No version file change; no git tag; record marker by docs/status/decision only | docs/status marker, release-readiness note, optional internal packet | none if no tag/push/publish | none beyond accepted official evidence; optional independent hash check | User confirms this is a marker, not release execution | Low | Recommended if movement desired now |
| B. Local package/install smoke first | Keep current version for smoke unless review decides otherwise; no tag | run local package/install proof in temp, rebuild local gem/checksum, record smoke packet | none if no tag/push/publish | release gate or package/install matrix with PASS criteria; no public claims | User approves smoke commands and temp artifacts | Low-medium | Recommended before any installed-gem claim |
| C. Private/internal tag | Decide tag name before execution; no version file change unless separately approved | local tag before push can be deleted | pushed tag is sticky/socially visible | accepted evidence + hash verification + status docs; optional package smoke | User explicitly approves tag name and push/no-push boundary | Medium | Only after target/tag policy review |
| D. Public gem/public release later | Requires explicit version decision and likely version file change; tag required | local prep before publish | gem push is effectively irreversible for a version; public claims visible | fresh package/install matrix, release gate, docs/non-claims, hash/checksum, RubyGems owner MFA | User + Portfolio + human RubyGems owner approval | High | Premature now |
| E. Hold/no release | No version/tag decision | no-op | none | none | User/Portfolio chooses hold | Lowest immediate risk, no movement | Valid if release target remains unclear |

---

## Option Details

### Option A: Repo-Local RC Marker Only

Target:

```text
repo_local_compiler_rc_marker
```

Version/tagging stance:

- do not edit `IgniterLang::VERSION`;
- do not create a git tag;
- do not build or publish a gem;
- record the accepted first-RC evidence as a repo-local RC marker in docs/status
  only.

Reversibility:

- fully reversible as documentation/status if no tag is created;
- does not affect package consumers.

Required proof matrix:

- accepted official first-RC evidence is sufficient;
- optional independent hash verification may be added before marking the packet
  audit-ready.

User approval boundary:

- user approves a docs/status marker only;
- no release execution, tag, push, publish, sign, or deploy.

Risk:

- low;
- main risk is wording drift into public release/demo claims.

Recommendation:

```text
best immediate movement
```

---

### Option B: Local Package / Install Smoke First

Target:

```text
local_package_install_smoke
```

Version/tagging stance:

- default: keep `0.1.0.pre.stage2` for smoke;
- do not edit version files unless a separate version decision explicitly
  authorizes it;
- no git tag.

Reversibility:

- local `/private/tmp` artifacts are disposable;
- generated smoke report can be reviewed before any release target changes.

Required command/proof matrix:

Minimum:

```text
ruby -c igniter-lang/igniter_lang.gemspec
ruby igniter-lang/experiments/gem_native_package_boundary_specs/gem_native_package_boundary_specs.rb
igniter-lang/bin/release-gate --out /private/tmp/igniter_lang_release_gate_r170
require "igniter_lang" from isolated installed gem without repo-relative -I
installed igc positive compile
installed igc refusal case
```

Pass criteria:

- all commands PASS;
- local gem artifact exists;
- checksum exists;
- installed require works without repo-relative `-I`;
- installed `igc` compiles a positive corpus source;
- installed `igc` refuses a negative source without `.igapp`;
- publish status remains `not_attempted`;
- no public claims are generated.

User approval boundary:

- user approves local smoke execution only;
- no tag, push, publish, sign, deploy, or version edit.

Risk:

- low-medium;
- risk is confusing local package smoke with public gem readiness.

Recommendation:

```text
recommended before any installed-gem/package target
```

---

### Option C: Private / Internal Tag

Target:

```text
private_internal_tag
```

Version/tagging stance:

- must decide exact tag before execution;
- possible tag families:
  - `igniter-lang-compiler-rc-2026-05-24`;
  - `igniter-lang-v0.1.0.pre.stage2-rc-evidence`;
  - `igniter-lang-repo-local-rc-r168`;
- avoid semver-looking public release tags unless a version policy is accepted.

Reversibility:

- local unpushed tag can be deleted;
- pushed tag is visible and socially sticky even if technically deletable.

Required command/proof matrix:

- accepted official first-RC evidence;
- independent hash verification or explicit deferral;
- docs/status marker naming tag intent;
- `git status` clean-enough review for intended tag scope;
- no package/public claims unless separately authorized.

User approval boundary:

- user explicitly approves tag name;
- user explicitly approves whether tag remains local or may be pushed.

Risk:

- medium;
- tag can be misread as public release even without gem publish.

Recommendation:

```text
not first choice; consider after repo-local marker or package smoke
```

---

### Option D: Public Gem / Public Release Later

Target:

```text
public_gem_public_release
```

Version/tagging stance:

- requires explicit version decision;
- current version is `0.1.0.pre.stage2`, which may not reflect the accepted
  Stage 3 first-RC evidence;
- any version file edit must be separately authorized;
- public tag must match the selected version/release policy.

Reversibility:

- gem publish is not safely reversible for a version;
- yanking is possible only for severe issues and requires approval;
- public release notes/tags may remain visible.

Required command/proof matrix:

- fresh package/install matrix;
- `bin/release-gate` PASS;
- gem artifact + checksum retained/rebuilt from exact commit;
- independent hash verification;
- public release docs/non-claims;
- user approval;
- Portfolio approval;
- human RubyGems owner MFA publish step;
- rollback/yank policy acknowledged.

User approval boundary:

- explicit user approval for public release target;
- explicit user approval for version;
- explicit human RubyGems owner action.

Risk:

- high right now.

Recommendation:

```text
premature
```

---

### Option E: Hold / No Release

Target:

```text
hold_no_release
```

Version/tagging stance:

- no version decision;
- no tag.

Reversibility:

- fully reversible by opening a later review.

Required command/proof matrix:

- none.

User approval boundary:

- user/Portfolio chooses to hold.

Risk:

- low operational risk;
- product/research momentum risk if the accepted evidence is not marked or
  packaged.

Recommendation:

```text
valid fallback if target remains unclear
```

---

## Versioning Stance

Current version:

```text
IgniterLang::VERSION = "0.1.0.pre.stage2"
```

Current evidence cannot choose a publishable version by itself.

Recommended policy:

- Option A: no version change.
- Option B: no version change for smoke; record current version in smoke output.
- Option C: avoid semver release tag unless a version policy is accepted.
- Option D: require explicit version policy before any version edit, tag, or
  publish.

Open versioning question for a future review:

```text
Should first public/compiler RC use the existing 0.1.0.pre.stage2 package
version, a Stage 3 prerelease version, or a new RC-specific version?
```

Do not answer this inside execution. It must be answered before execution.

---

## Recommended Next Authorization Stance

Recommended next stance:

```text
authorize repo-local RC marker only
optionally authorize local package/install smoke as a separate next card
do not authorize tag, push, publish, sign, deploy, or version edits
```

Exact next route recommendation:

```text
compiler-release-target-selection-authorization-decision-v0
Mode: authorization decision
```

Decision should choose one:

- mark repo-local RC in docs/status only;
- run local package/install smoke first;
- hold;
- route private tag review;
- keep public gem release closed.

Default recommendation:

```text
Option A now; Option B next if installed-gem readiness becomes desired.
```

---

## Closed Surfaces

This packet does not authorize:

- release execution;
- version file edits;
- git tag creation;
- git push;
- gem build as release execution;
- gem publish;
- signing;
- deployment;
- public release or demo claims;
- implementation;
- parser, TypeChecker, SemanticIR, assembler, or compiler/library behavior
  changes;
- public API/CLI widening;
- loader/report, `CompilationReport`, `CompilerResult`, or CompatibilityReport
  widening;
- Spark access, fixtures, specs, integration, or production pressure;
- Ruby Framework release, gem publish, production benchmark, production
  readiness, or Spark production binding.

---

## Compact Target / Versioning Options Table

| Option | Target | Version/tag | Action class | Recommendation |
| --- | --- | --- | --- | --- |
| A | Repo-local RC marker | no version change, no tag | reversible docs/status | choose now if movement desired |
| B | Local package/install smoke | no version change by default, no tag | reversible local proof | choose before installed-gem claim |
| C | Private/internal tag | tag policy required | reversible only before push | defer |
| D | Public gem/release | version + tag policy required | irreversible/public | premature |
| E | Hold | none | no-op | valid fallback |

---

## Compact Handoff

```text
card: S3-R170-C1-P1
track: compiler-release-target-versioning-and-execution-options-v0
status: done
current_version: 0.1.0.pre.stage2
gemspec_present: yes
release_gate_present: yes
official_evidence_scope: repo_local_compiler_rc
installed_gem_readiness_currently_established: no_for_current_first_rc_scope
public_gem_release_status: premature
safest_movement_now: repo_local_rc_marker_only
recommended_next_stance: Option A now; Option B before any installed-gem claim
release_execution_authorized: no
tag_push_publish_authorized: no
version_edit_authorized: no
```
