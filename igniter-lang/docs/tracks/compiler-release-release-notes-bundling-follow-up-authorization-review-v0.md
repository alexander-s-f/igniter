# Compiler Release Release Notes Bundling Follow-Up Authorization Review v0

Card: S3-R182-C1-A
Agent: [Portfolio Architect Supervisor]
Role: portfolio-architect-supervisor
Track: compiler-release-release-notes-bundling-follow-up-authorization-review-v0
Route: UPDATE
Status: done / authorized tiny packaging follow-up
Date: 2026-05-26

Depends on:
- S3-R181-C4-A

---

## Inputs Read

- `igniter-lang/docs/tracks/compiler-release-version-metadata-and-notes-prep-acceptance-decision-v0.md`
- `igniter-lang/docs/discussions/compiler-release-version-metadata-and-notes-prep-pressure-v0.md`
- `igniter-lang/igniter_lang.gemspec`
- `igniter-lang/README.md`
- `igniter-lang/RELEASE_NOTES.md`

---

## Decision

Decision:

```text
authorize tiny release-notes packaging follow-up
require RELEASE_NOTES.md in gemspec packaged files
authorize optional README version qualifier
authorize follow-up track doc
do not authorize post-prep smoke in this card
do not authorize release execution
do not authorize RubyGems publish
do not authorize tag creation
do not authorize git push
do not authorize signing/deployment
do not authorize public release/demo claims
keep branch/conditional if_expr excluded
keep profile finalization/discovery/defaulting closed
keep Spark out of scope
```

S3-R182-C2-I may perform the tiny implementation defined below.

---

## Required Packaging Decision

`RELEASE_NOTES.md` must be bundled in the gem.

Reason:

- `README.md` is currently packaged into the gem.
- `README.md` links to `RELEASE_NOTES.md`.
- A packaged README should not point at a missing packaged file.
- `RELEASE_NOTES.md` is the strongest package-local non-claims and exclusions
  record for `0.1.0.alpha.1`.

Required gemspec change:

```ruby
Dir["lib/**/*.rb", "bin/igc", "README.md", "RELEASE_NOTES.md"]
```

Equivalent exact inclusion is acceptable if it keeps the file list simple and
does not broaden the package glob.

---

## Authorized Write Scope

Only these files may be edited or created:

```text
igniter-lang/igniter_lang.gemspec
igniter-lang/README.md
igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-v0.md
```

No other files are authorized.

---

## Optional README Version Qualifier

C2-I may add a narrow version qualifier to the existing README accepted local
evidence PASS lines if it can do so without widening public claims.

Allowed meaning:

```text
the prior local package/profile-source smoke evidence was for 0.1.0.pre.stage2
fresh smoke is required for 0.1.0.alpha.1
```

Do not add:

- RubyGems availability wording;
- install-from-RubyGems wording;
- public release/demo readiness wording;
- production/stable/all-grammar claims.

If the README qualifier would make the section noisy, C2-I may skip it and
record that no README edit was needed.

---

## Required Forbidden Phrase Scan

C2-I must scan changed package/docs files for:

```text
production-ready
production ready
stable release
public release ready
release ready
demo ready
available on RubyGems
RubyGems available
published package
install from RubyGems
supports all grammar
supports branch
supports conditional
supports if_expr
profile discovery
profile defaulting
profile finalization
Spark integrated
Spark ready
Ruby Framework compatible
```

Expected result:

- no active claim hit;
- negation/exclusion wording is allowed only when surrounding context clearly
  says the surface is excluded or closed.

---

## Post-Follow-Up Smoke Boundary

Post-prep smoke does not run in C2-I.

If this follow-up is accepted, the next route may open:

```text
combined post-prep package/install + profile-source smoke authorization review
```

Target:

```text
package: igniter_lang
version: 0.1.0.alpha.1
```

Smoke must verify the final package artifact includes both:

```text
README.md
RELEASE_NOTES.md
```

---

## Closed Surfaces

Remain closed:

```text
release execution
RubyGems publish
git tag creation
git push
version/tag/push/publish/sign/deploy
public release/demo claims
production readiness claims
stable release claims
all grammar support claims
branch/conditional if_expr support
profile finalization/discovery/defaulting
named/generated profile lookup
inline JSON profile input
env/config/sidecar profile lookup
public API/CLI widening
loader/report or CompatibilityReport readiness
runtime/Ledger/TBackend/BiHistory/stream/OLAP/cache behavior
Spark integration or Spark public evidence claims
Ruby Framework compatibility claims
compiler/runtime behavior changes
```

---

## Exact C2-I Boundary

```text
Card: S3-R182-C2-I
Agent: [Package Agent / Implementation Agent]
Role: package-agent
Track: compiler-release-release-notes-bundling-follow-up-v0

Route: UPDATE
Depends on:
- S3-R182-C1-A

Goal:
Perform the tiny release-notes packaging follow-up authorized by S3-R182-C1-A.

Allowed writes:
- igniter-lang/igniter_lang.gemspec
- igniter-lang/README.md
- igniter-lang/docs/tracks/compiler-release-release-notes-bundling-follow-up-v0.md

Required implementation:
- include `RELEASE_NOTES.md` in gemspec packaged files;
- optionally add a narrow README version qualifier for prior smoke evidence;
- run/report forbidden phrase scan over changed package/docs files;
- record whether combined post-prep smoke may be requested next.

Do not:
- change version;
- edit RELEASE_NOTES.md;
- change compiler/runtime behavior;
- publish gems;
- create tags;
- push;
- sign/deploy;
- run post-prep smoke;
- claim RubyGems availability;
- claim public release/demo readiness.

Deliver:
- Track doc in `igniter-lang/docs/tracks/`
- Exact changed files
- Packaging change summary
- Forbidden phrase scan result
- Non-claims preservation checklist
- Whether post-prep smoke may be requested next
```

---

## Compact Summary

```text
S3-R182-C1-A: authorized tiny packaging follow-up.

RELEASE_NOTES.md must be bundled in gemspec packaged files.
Optional README version qualifier is allowed.

Allowed writes:
- igniter_lang.gemspec
- README.md
- follow-up track doc

No post-prep smoke in this card.
No release execution.
No RubyGems publish.
No tag/push/sign/deploy.
No public release/demo claims.
```
