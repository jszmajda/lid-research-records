Phase 2 done — registry LLD drafted around the local SQLite index, plus the probe. Here's where it landed.

## One thing to flag first

Two of the three options I sketched last session weren't actually live. The HLD tenets say *"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"* and *"Kiosks have no network route during normal operation."* The on-site HTTPS directory and the managed search service both put a network call on the lookup path, so the HLD rules them out before the trade-offs get weighed. That's on the option sketch, not on you — they were presented as comparable when one was the only one that passes. If you want the network-backed shapes to be genuinely available, that's an HLD tenet change and we'd walk Phase 1 again. Otherwise the choice you made is the one the HLD already required.

That also settles how it gets recorded: a choice an inherited constraint eliminates the alternatives for earns a Decisions row, not a decision doc. I recorded a row; no doc.

## What changed

`docs/intent/registry/registry-design.md` — backend is now settled rather than open:

- **Lookup Index** — one SQLite file per kiosk, built locally. `equipment` keyed by the *normalized* serial as `TEXT PRIMARY KEY` plus the raw serial and the record fields; `snapshot_meta` holds snapshot date, snapshot schema version, and an index format version that is the registry's own.
- **Normalization Invariant** — one routine produces both the stored key and the query key; the index format version changes when that routine changes, because an older index holds keys the new query path would miss.
- **Snapshot Import** — staged build: verify signature → reject unsupported schema → build at a staging path (duplicate key = build failure, which is how uniqueness is enforced) → validate the staged index → atomic replace. Lookups serve the old snapshot throughout; activation is the only moment the answer changes.
- **Decisions & Alternatives** — three rows: backend, normalized-vs-raw key, atomic-replace-vs-in-place.

`docs/high-level-design.md` — one stale line: "Its private lookup backend remains open" → "Its lookup backend is private to the node." No architecture change.

Certificates untouched — the interface is unchanged, as all three options promised.

## Probe findings to triage

I ran the LLD probe through a reader given only the design docs, not our conversation. Seven gaps worth your call:

1. **No index at all** — first boot, before any snapshot has ever been imported. Both result types carry a snapshot date, and there isn't one. What should `findBySerial` do?
2. **Index format version mismatch** — the doc says a stale index is *recognized* but never says what follows. Refuse lookups until a snapshot is re-imported, or serve it with a warning? The kiosk can't rebuild without the snapshot media.
3. **Unreadable or corrupt index at query time** — same shape as (1): `Found`/`NotFound` admits no failure value.
4. **Crash between build and activation** — a stray staging file survives the reboot. Discarded, resumed, or reused?
5. **Byte-identical duplicate records** — "duplicate key is a build failure" covers two different cases. An exact repeated row is plausibly benign; two records whose raw serials differ but normalize to the same key is a genuine data problem. Same treatment or not?
6. **Malformed NDJSON line, or a zero-record snapshot** — the row-count check passes an empty snapshot. Skip bad lines or fail the import?
7. **Import failure reporting** — "reports which stage failed" names no shape. Structured stages the kiosk UI can render, or free text?

Items 1–3 need a decision I shouldn't make alone: all three want a lookup outcome that isn't `Found` or `NotFound`, and that result type is the registry/certificates contract. Widening it cascades into the certificates segment, so I've stopped rather than propagated. Options are (a) add a third variant and cascade to certificates, (b) keep the two-variant type and have the registry raise on unavailability, with certificates handling it outside the result type, or (c) make the registry refuse to serve at all until a valid index exists, so the condition never reaches a caller.

5 and 6 I'd fix in the LLD now — they're inside the registry and cheap to pin. 4 and 7 could go either way.

Which of these do you want folded into the LLD, and which deferred as open questions? And for 1–3, which direction on the result type?