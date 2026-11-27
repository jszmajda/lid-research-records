I finished the registry LLD for the local embedded SQLite index choice. Here's what changed in `docs/intent/registry/registry-design.md`:

- **Architecture**: the lookup backend is now fixed as a local embedded SQLite index built from the active snapshot; no other node depends on its internals or query syntax.
- **Snapshot Import**: now specifies building the new index into a separate file (so a partial build is never exposed), and activating snapshot + index together only after signature, schema, uniqueness, *and* index-build validation all succeed. Import failure (including an index-build failure) leaves the previous snapshot and index active.
- **Lookup Behavior**: lookups query the active snapshot's SQLite index by normalized serial.
- **Decisions & Alternatives** (new table): records the SQLite choice and the two rejected alternatives.

One thing worth flagging while recording the rationale: the HLD already has tenets that "no runtime network access is permitted" and "signed USB snapshots are the only registry update channel." Both the on-site HTTPS directory and the managed search service options directly conflict with those — so they weren't really live alternatives once the HLD was in place, which may be why they only *looked* close at first. I recorded this in the Decisions table rather than a full decision doc, since an inherited constraint settles it rather than it staying a genuinely live tradeoff.

I ran the LLD-level edge-case probe (via a blind subagent given only the document text). The sharpest gaps it surfaced, for you to triage:

1. Does uniqueness validation run on raw serials or normalized ones? (Two raw-distinct serials could collide after uppercasing/whitespace normalization.)
2. Is there an atomic-switch guarantee for `findBySerial` during an in-progress activation, or could a lookup see a torn state?
3. How is the bundled public key rotated without breaking verification of older or in-flight snapshots?
4. Is there any post-build consistency check confirming the index actually matches the snapshot's records before activation?
5. What does `findBySerial` return on first boot, before any snapshot has ever been successfully imported — is there a "previous snapshot" to fall back to?
6. Is an empty-after-trim serial number NotFound, a validation error, or undefined?
7. On a uniqueness-validation failure, does the whole import fail, or can records be skipped — and what error detail is reported?
8. Is cleanup of a partially-built index file specified if disk space or I/O fails mid-build?
9. If the index build crashes mid-way, is the half-built new index file cleaned up, or could it persist and be mistaken for valid on a later import attempt?
10. Does the design assume single-threaded access, or is concurrent lookup-during-activation addressed?

Which of these do you want resolved in the LLD now, and which should become open questions deferred for later?