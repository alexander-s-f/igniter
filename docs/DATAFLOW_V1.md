# Incremental Dataflow v1

Historical reference.

For the current canonical reading, start with:

- [docs/guide/core-runtime-features.md](./guide/core-runtime-features.md)
- [docs/core/README.md](./core/README.md)

## What This Old Document Was About

The V1 write-up described incremental `collection` execution using
`mode: :incremental`.

Its key ideas were:

- O(change) collection execution
- explicit diffs of added/changed/removed items
- event-style `feed_diff`
- optional sliding windows before diff computation

## What Is Still Historically Useful

- the original mental model for incremental collection execution
- the older explanation of `feed_diff` and `collection_diff`
- the design rationale for applying windowing before diff computation

## What Changed Since V1

This topic is now treated as a focused core-runtime feature rather than as a
top-level entrypoint.

## Read It When

You are reading older notes or want detailed historical rationale for why
incremental collections were introduced.
