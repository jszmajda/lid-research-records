Registry LLD is drafted at `docs/intent/registry/registry-design.md`. Phase 2 output below; nothing has cascaded to specs yet.

## One thing to flag before the content

The two options you were weighing against SQLite were already excluded by the HLD. `docs/high-level-design.md:18-19` makes offline lookup a tenet ("no runtime network access is permitted", "Kiosks have no network route during normal operation"), and `:33` lists live sync / remote access / cloud services as a non-goal. An on-site HTTPS directory and a managed search service both need a runtime network route from the kiosk. So the choice wasn't close on the HLD's terms — it was settled upstream, and the real options were among on-kiosk index shapes.

That matters two ways:

- **No decision doc.** A choice an inherited constraint settles doesn't earn one, however long the deliberation ran. I've recorded a Decisions row instead.
- **The alternatives I recorded are different from the three you sketched.** The row trades SQLite against per-query NDJSON scan and an in-memory map — the on-kiosk options a fresh reader would actually question. I left the network options out of the doc, since the HLD already rules them out and re-arguing them in the LLD is stale residue. **Your call: leave them out, or add a row noting they were weighed and excluded by the offline tenet?**

If instead the back-and-forth means the no-network tenet itself is less settled than the HLD states, say so — that's an HLD change and a Phase 1 conversation, not this one.

## What the LLD now says

- **Architecture** — backend is an embedded SQLite file on kiosk local disk, built by this node at import; the file, its schema, and the query path are invisible outside the node. `findBySerial` is unchanged, so certificates is untouched.
- **Snapshot Import** — a five-step build-then-activate sequence over a *staging* database file: verify signature → check schema version → create staging file and write snapshot-date/schema metadata → stream NDJSON into the record table keyed by normalized serial (the key's uniqueness constraint is what detects duplicates) → atomically rename staging over active. Activation is the only step lookups observe, and it's one rename, so a lookup sees the whole old or the whole new snapshot. Failures before activation leave the active file untouched and discard staging.
- **Lookup Behavior** — one normalization function applied in two places: to each record's serial on write, and to the query before use. Trim surrounding whitespace, uppercase ASCII letters, punctuation significant. Normalizing on write is what makes lookup an exact keyed read rather than a scan. Each record keeps the snapshot's original serial spelling for display. Reads open the active database read-only, and the snapshot date comes from the same file as the record.
- **Decisions & Alternatives** — four rows: lookup backend, build-on-kiosk vs. prebuilt index (the signature covers the record stream, so a prebuilt binary would need its own trust path), rename-activation vs. in-place transaction, normalized key vs. normalize-at-query.
- **Deferred** — import duration on kiosk hardware, whether the superseded file is kept for rollback, free-disk precondition for staging.

## Edge-case probe

I ran the probe with a subagent given only the two design docs. Fifteen gaps came back; triaged into four groups — tell me which to settle in the LLD now and which to park as open questions.

**A. Crash and concurrency around activation** — recovery for a staging file left by a power loss mid-import; whether activation can be interrupted into a partial or zero-length active file; whether import is single-flight or two imports can collide on a fixed staging path; what a read-only handle opened *before* the rename observes (keeps the unlinked old file vs. sees the new one — the doc's "whole old or whole new" wording permits both, and they differ for a multi-read lookup).

**B. No-snapshot and broken-snapshot states** — `findBySerial` currently admits only `Found`/`NotFound`, and both carry a snapshot date. A fresh kiosk that has never imported, or an active file that's missing or unreadable, has no date to return. This is the one I'd most want settled now, because it may change the result type the certificates node consumes — and that's a segment boundary, so I'd come back to you before touching certificates.

**C. Error reporting shape** — "reports which step failed and why" doesn't say to whom or in what form: a return value, a log, a kiosk-visible message, and whether failure cases are distinguishable (missing public key vs. signature mismatch; absent/unparseable schema version vs. unsupported one). Also: where the supported schema-version set is defined.

**D. Normalization and record validity** — a genuine fork here: two *different* raw serials that normalize to the same key currently fail the import via the uniqueness constraint, same as a literal duplicate. Is that intended semantics or an accident of the mechanism? Plus: what a query normalizing to empty does (`NotFound` vs. rejected as invalid input); non-ASCII handling (are non-ASCII letters passed through, is NBSP/zero-width trimmed, any Unicode normalization); serial length bounds; records with missing/non-string serials and malformed NDJSON lines mid-stream; and whether anything forbids activating an older snapshot over a newer one.

**Stopping here for your review.** When you've ruled on the alternatives question, group B, and the group-D fork, I'll fold the rest in and move to Phase 3 — REG-001 through REG-004 all stand as written, and the new material looks like added spec lines rather than edits to existing IDs.