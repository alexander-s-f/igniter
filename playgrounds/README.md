# Playgrounds

`playgrounds/` is the local-first lab for fast-moving Igniter experiments. It is
ignored by the root repository, and several children are their own nested git
repositories. Treat this tree as working memory and prototype evidence, not as
public canon.

## Current Map

| Path | Nested repo | Purpose | Read first |
| --- | --- | --- | --- |
| [`docs/`](docs/README.md) | yes | Scratch documentation and historical notes that are useful locally but not canonical. | [`docs/README.md`](docs/README.md) |
| [`igniter-runtime/`](igniter-runtime/README.md) | yes | IVM/runtime playground for bytecode, branch/lazy proofs, resident supervisor, AOT loading, and backend candidates. | [`igniter-runtime/README.md`](igniter-runtime/README.md) |
| [`igniter-tbackend/`](igniter-tbackend/README.md) | yes | Rust bitemporal backend/server candidate and substrate research surface. | [`igniter-tbackend/README.md`](igniter-tbackend/README.md) |
| [`acts-as-tbackend/`](acts-as-tbackend/README.md) | yes | ActiveRecord adapter sketch that writes lifecycle facts to the TBackend playground. | [`acts-as-tbackend/README.md`](acts-as-tbackend/README.md) |
| [`igniter-apps/`](igniter-apps/README.md) | yes | Tiny local apps that exercise temporal/product ideas without becoming public examples. | [`igniter-apps/README.md`](igniter-apps/README.md) |

## Boundary

- `examples/` stays public and curated.
- `playgrounds/` stays local-first and is ignored by the root git repo.
- Each playground with `.git/` owns its own history; check its status before
  editing or committing.
- Playground proofs are evidence only. They do not authorize runtime, compiler,
  public API, packaging, release, production, or demo claims.
- Prefer pointing local Gemfiles at the monorepo checkout via `path: "../.."`.

## Working Flow

1. Check nested repository status before edits:

   ```bash
   find playgrounds -maxdepth 3 -type d -name .git -print
   git -C playgrounds/<child> status --short
   ```

2. Keep each child README current enough to answer:
   - what this playground is for;
   - what is proven or only sketched;
   - which commands are safe to run locally;
   - what remains explicitly not authorized.

3. For larger rewrites:
   - rename the current playground to `*-legacy`;
   - scaffold a fresh replacement;
   - migrate ideas selectively instead of carrying the whole historical shape
     forward.
