# igniter-schema-rendering

`igniter-schema-rendering` is a local monorepo gem for agent-facing and
schema-driven rendering on top of Igniter.

It groups the schema-specific surface that does not belong in the human-first
frontend package:

- schema page rendering
- schema renderer/runtime
- schema storage and patching
- submission normalization/validation/processing

The intent is to keep `igniter-frontend` focused on developer-authored human UI,
while this package owns the machine-authored or agent-oriented schema lane.

This package now owns the schema runtime directly inside the monorepo:

- schema loading and validation
- schema rendering
- schema storage and patching
- submission normalization, validation, and processing
