# igniter-hub

Local capsule catalog discovery for Igniter.

Status: first POC slice, not stable API.

## Owns

- local capsule catalog loading
- bundle metadata for install candidates
- capability summaries for applications

## Does Not Own

- remote download
- trust/signatures
- applying bundles
- running installed capsules

Applications should use `igniter-application` transfer verification, intake,
apply, and receipt APIs to install a selected bundle.
