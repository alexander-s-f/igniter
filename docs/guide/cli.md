# CLI

This is the shortest guide to the current stack-first CLI surface.

## Main Entry Points

- `bin/start` — start the mounted stack runtime
- `bin/start --node NAME` — start one local node profile
- `bin/console` — open the igniter console
- `bin/console --node NAME` — open console with one node profile selected
- `bin/console --node NAME --eval '...'` — evaluate one expression and exit
- `bin/dev` — start all local node profiles with prefixed output

`bin/dev` also writes per-node logs to `var/log/dev/*.log`.

## Scaffold Profiles

`igniter-stack new` currently supports:

- base profile by default
- `--profile dashboard` for a mounted dashboard app at `/dashboard`
- `--profile cluster` for a cluster-ready sandbox with node profiles and self-heal demo
- `--profile playground` for a richer local lab scaffold

Examples:

```bash
bin/igniter-stack new my_app
bin/igniter-stack new my_hub --profile dashboard
bin/igniter-stack new mesh_lab --profile cluster
bin/igniter-stack new playgrounds/home-lab --profile playground
```

## Mental Model

- `stack.rb` is the executable runtime surface
- positional `app` means “run this one app directly”
- `--node` means “boot the stack as this node profile”
- `--console` means “load stack/app/runtime helpers into IRB”

## Console Helpers

Inside `bin/console`, these locals are available:

- `stack`
- `context`
- `app`
- `root_app`
- `node`
- `node_profile`
- `deployment`
- `runtime`
- `mounts`
- `mesh`
- `stack_settings`

Example:

```bash
bin/console --node seed --eval 'context.node_name'
```

## Built-In Help

The runtime also exposes help directly:

```bash
bundle exec ruby stack.rb --help
bundle exec ruby stack.rb --console --help
```
