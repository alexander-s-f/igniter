# Playgrounds

`playgrounds/` is for local, fast-moving experiments that should not affect the public
examples in this repository.

Use it for:

- home-lab workspaces
- hardware integrations
- performance experiments
- throwaway prototypes that may later graduate into public examples

Rules:

- `examples/` stays public and curated
- `playgrounds/` stays local-first and is ignored by the root git repo
- each playground may become its own nested git repo if you want private history
- prefer pointing playground Gemfiles at the local monorepo checkout via `path: "../.."`

Suggested layout:

```text
playgrounds/
  home-lab/
  home-lab-legacy/
  esp32-a1s/
  esp32-cam/
  bench/
```

Recommended flow for bigger playground rewrites:

- rename the current playground to `*-legacy`
- scaffold a fresh replacement with `ruby bin/igniter-stack new playgrounds/<name> --profile playground`
- migrate ideas selectively instead of carrying the whole historical shape forward
