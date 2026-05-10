# History-S16 Playgrounds-Rotation-1 Approval Packet

Status: archived planning report and cleanup approval packet  
Date: 2026-05-10  
Agent: [Igniter-Lang History Curator]  
Role: history-curator  
Stage: History-S16  
Source posture: draft future cleanup packet only; no files moved or deleted

## Compact Claim

`Playgrounds-Rotation-1` should be a conservative metadata/index cleanup, not a
Markdown deletion pass.

The safe first move is:

```text
remove only approved metadata artifacts
add/adjust only small private indexes/status notes
keep all content-bearing Markdown
preserve nested git intentionally
report before/after counts and diffs
```

This S16 file is an approval packet. It does not execute cleanup.

## Source Set

- `igniter-lang/docs/archive/history/history-s2-playgrounds-docs-rotation-map.md`
- `igniter-lang/docs/archive/history/history-s12-archive-rotation-candidate-ledger.md`
- `igniter-lang/docs/archive/history/history-s15-syntax-pressure-backlog-map.md`
- `playgrounds/docs/` directory inventory
- `playgrounds/docs/external/README.md`

## Current Inventory Notes

`playgrounds/docs` is a nested git repository:

```text
playgrounds/docs/.git
```

This is high-caution. Do not remove, move, or flatten it without explicit
approval and backup decision.

Visible top-level areas:

| Area | Current role | S16 disposition |
| --- | --- | --- |
| `concepts/` | Small concept memory | Keep |
| `current/` | Historical platform-current snapshot | Add/keep status note later |
| `dev/` | Private process/tracks/reference/legacy memory | Keep; maybe add top-level index later |
| `experts/` | Expert pressure and theory corpus | Keep; already has README |
| `external/` | Private parallel research workbench | Keep; newly indexed privately |
| `guide/` | Full/cold guide drafts | Add README/status note later |
| `research-horizon/` | Research lane | Keep; already has README |
| `review/` | Small review evidence | Keep |

Metadata artifacts observed:

| Path | Candidate action | Reason |
| --- | --- | --- |
| `playgrounds/docs/.DS_Store` | Delete if approved | Finder artifact |
| `playgrounds/docs/experts/.DS_Store` | Delete if approved | Finder artifact |
| `playgrounds/docs/external/.DS_Store` | Delete if approved | Finder artifact |
| `playgrounds/docs/.idea/` | Optional local-only cleanup if approved | IDE metadata, not durable docs |
| `playgrounds/docs/.git/` | No action in this packet | Nested repo metadata; high caution |

## Proposed Packet

Name:

```text
Playgrounds-Rotation-1
```

Goal:

- reduce incidental metadata clutter;
- add private read-entrypoints where they reduce future agent context load;
- avoid content loss;
- avoid changing public docs, current Igniter-Lang canon, specs, proposals,
  gates, or active tracks.

Allowed actions after explicit approval:

1. Remove approved `.DS_Store` files:
   - `playgrounds/docs/.DS_Store`
   - `playgrounds/docs/experts/.DS_Store`
   - `playgrounds/docs/external/.DS_Store`
2. Optionally remove or ignore `playgrounds/docs/.idea/` after explicit
   approval.
3. Add tiny private README/status notes only where no index exists and the
   directory is repeatedly confusing:
   - `playgrounds/docs/README.md`
   - `playgrounds/docs/guide/README.md`
   - `playgrounds/docs/dev/README.md`
   - `playgrounds/docs/dev/reference/README.md`
4. Keep `playgrounds/docs/current/README.md` but consider a status-line update
   in a separate review if it still reads as active current truth.
5. Leave all Markdown source files in place.

Explicitly forbidden in this packet:

- deleting content-bearing Markdown;
- moving snapshot folders;
- moving `playgrounds/docs/external/`;
- moving `playgrounds/docs/experts/`;
- flattening or deleting nested `.git`;
- editing `igniter-lang/docs/current-status.md`;
- editing `igniter-lang/docs/agent-context.md`;
- editing specs, proposals, gates, active tracks, or hot docs.

## Proposed Index Additions

These are candidates only. They should stay short.

| Candidate index | Purpose | Risk |
| --- | --- | --- |
| `playgrounds/docs/README.md` | Top-level private memory map and read order | Low |
| `playgrounds/docs/guide/README.md` | Mark guide drafts as full/cold source, point to public docs | Low |
| `playgrounds/docs/dev/README.md` | Point to process, tracks, reference, legacy, full plans | Low |
| `playgrounds/docs/dev/reference/README.md` | Warn current-check before using reference docs | Low |

Do not create large new docs in the cleanup packet. If more than a few lines are
needed, write a separate report first.

## Before/After Checks

Before cleanup:

```text
find playgrounds/docs -maxdepth 2 -type d | sort
find playgrounds/docs -name .DS_Store -o -name .idea -o -name .git | sort
git -C playgrounds/docs status --short
git status --short
```

After cleanup:

```text
find playgrounds/docs -name .DS_Store -o -name .idea -o -name .git | sort
git -C playgrounds/docs status --short
git status --short
```

If any Markdown is changed:

```text
git -C playgrounds/docs diff -- README.md guide/README.md dev/README.md dev/reference/README.md
```

## Approval Decision Matrix

| Decision | Options | Recommendation |
| --- | --- | --- |
| `.DS_Store` files | delete / keep | Delete after approval |
| `.idea/` | delete / keep local / ignore | Ask explicitly |
| nested `.git/` | preserve / backup then remove / migrate | Preserve |
| top-level README | add / skip | Add short private map |
| guide README | add / skip | Add if guide remains confusing |
| dev README | add / skip | Add if future agents keep entering broad dev tree |
| reference README | add / skip | Add current-check warning if reference tree stays active |
| content Markdown | delete / keep | Keep |

## Why This Packet Is Safe

- It does not treat private memory as trash.
- It separates metadata cleanup from content rotation.
- It preserves external/private research workbench status.
- It keeps nested repository history untouched.
- It creates small entrypoints instead of moving large trees.
- It leaves public/canon docs alone.

## Stage-Close Handoff

Compact claim:

S16 prepares `Playgrounds-Rotation-1` as an approval-ready cleanup packet. The
first cleanup should remove only approved metadata artifacts and add tiny private
indexes/status notes. No Markdown deletion or tree movement belongs in this
packet.

Source set:

- S2 playground rotation map
- S12 archive rotation ledger
- S15 syntax pressure backlog
- current `playgrounds/docs` inventory

Categories applied:

- cleanup_candidate
- no_move
- keep_warm
- keep_cold
- metadata_artifact
- approval_required

Values preserved:

- private memory stays recoverable
- cleanup before deletion
- compact indexes over broad reads
- nested history caution
- public/canon boundaries

Accepted/implemented signals:

- `playgrounds/docs/external/README.md` now indexes the private external
  workbench;
- archive history reports S1-S15 are the first read for archaeology;
- process/track entrypoints remain warm.

Superseded/rejected signals:

- bulk Markdown deletion;
- treating `playgrounds/docs/current` as active public truth;
- treating nested `.git` as disposable metadata;
- moving external research into public docs without proposal.

Research still alive:

- forms/effects private workbench;
- syntax-pressure backlog;
- external pressure fixtures;
- product proposal mining;
- research-horizon doctrines.

Duplicate/rotation recommendations:

- remove `.DS_Store` only after approval;
- preserve nested `.git`;
- keep content Markdown;
- add small indexes only where they reduce future reads;
- defer guide/current/reference content rotation to separate packets.

Unresolved questions:

- Should `.idea/` be removed, ignored, or preserved as local project state?
- Should `playgrounds/docs/current/README.md` be revised in a later packet to
  mark it historical/private more explicitly?
- Which index should be created first if only one is approved:
  top-level `playgrounds/docs/README.md` or `dev/README.md`?

Changed files:

- `igniter-lang/docs/archive/history/history-s16-playgrounds-rotation-1-approval-packet.md`
- `igniter-lang/docs/archive/history/README.md`

Suggested next Stage:

History-S17 should either produce a compact `forms-research snapshot` for the
private external workbench or, after user approval, execute
`Playgrounds-Rotation-1` exactly as approved.
