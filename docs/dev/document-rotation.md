# Document Rotation

Use public docs for the current product surface. Use `playgrounds/docs/` for
full memory: research, expert reports, agent handoffs, old tracks, rejected
options, and long-form history.

## Public Stays Small

Keep a document public only when it is one of these:

- user-facing guide or how-to
- package README or API reference
- current architecture boundary or target plan
- runnable example documentation
- recent track summary needed by active contributors

Everything else should be private until it is distilled into accepted public
shape.

## Track Rotation

Public development tracks keep a short tail, not the whole conversation:

- keep at most three recent active public track summaries
- when a fourth track appears, move the oldest public track into
  `playgrounds/docs/dev/tracks/`
- keep agent comments, raw handoffs, and detailed cycle logs private by default
- after a track closes, copy only the accepted result into stable public guide,
  dev, example, or package docs

The public git history remains the recent development trail. The private docs
keep the full memory.

## Promote And Demote

Promote private material into public docs only after it becomes concrete:
accepted behavior, public API, package boundary, user workflow, or verification
surface.

Demote public material when it becomes superseded, duplicated, too verbose for
its purpose, internal-process oriented, or mostly useful as historical context.

## Rotation Cadence

Run rotation after major track closure, before release readiness passes, and
whenever public docs start competing with each other. A rotation pass should:

- update or remove public links
- move private history under `playgrounds/docs/`
- leave a compact public decision/result when the knowledge is still current
- run markdown link checks and `git diff --check`
