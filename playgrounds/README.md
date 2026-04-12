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
  esp32-a1s/
  esp32-cam/
  bench/
```
