I've updated the registry LLD with the SQLite decision and run the Phase 2 edge-case probe. Here's where things stand — this is the mandatory stop for your review.

**Updated `docs/intent/registry/registry-design.md`:**
- Architecture section now states the lookup backend is a local embedded SQLite index, built and validated per-kiosk from each incoming snapshot.
- Snapshot Import section now covers building the new index alongside (not replacing) the active one, and activating snapshot + index together only after both validate.
- Lookup Behavior now says lookups query the active SQLite index.
- Added a Decisions & Alternatives table row recording the choice and rationale — tying it back to the HLD's existing "no runtime network access" tenet, which the HTTPS-directory and managed-service options would have violated.

I did **not** write a separate decision doc for this. Per the LID decision-doc test, a doc is only offered when other design nodes would be sized around the result — here the certificate interface and result type are identical under all three options, so this stays a table row inside registry's own LLD.

**Phase 2 edge-case probe** (gaps specific to this LLD now that the index is locally built/rebuilt — not cross-component, that's Phase 4):

1. Snapshot import succeeds but the SQLite index build fails partway (disk full, crash) — does `findBySerial` still correctly serve the previous snapshot/index, or can it land in "snapshot activated, index absent"?
2. A lookup arrives while a new index is mid-build — blocks, serves the old index, or races an unfinished file?
3. The on-disk index file is corrupted (power loss, bad USB unmount) without a re-import — detected at startup, at lookup time, or not at all?
4. Insufficient disk space to build the new index alongside the still-active old index + snapshot?
5. Index build exceeds a time budget on a slow kiosk — is there a timeout, and does it count as an import failure (preserving the last valid snapshot)?
6. Kiosk loses power mid-rebuild — on restart, how does Registry tell a fully-activated prior index apart from a half-built new one?
7. An older on-disk index format is encountered after a Registry software update — version check, and what's the failure mode?
8. Two rebuild attempts trigger in quick succession (USB reinserted, retry after failure) — any lock preventing concurrent builds against the same index path?
9. The built index's contents don't match the validated snapshot (e.g., a silent insert failure on a subset of ~90,000 records) — is there a post-build integrity check before activation?

Which of these do you want folded into the LLD now, and which should go into Open Questions / be deferred?