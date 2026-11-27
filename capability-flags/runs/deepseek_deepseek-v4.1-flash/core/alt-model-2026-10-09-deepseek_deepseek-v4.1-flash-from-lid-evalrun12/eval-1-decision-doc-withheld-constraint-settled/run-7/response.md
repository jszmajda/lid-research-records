## Phase 2 — Registry LLD (STOP)

Backend choice recorded: **local embedded SQLite index**. I updated `docs/intent/registry/registry-design.md`, and cascaded one stale line in the HLD (`high-level-design.md:13`) so it no longer says the backend "remains open."

**Coherence pre-flight:** HLD → registry LLD consistent (local index satisfies the no-network tenet; no separate service). Existing specs REG-001–004 still trace to the LLD unchanged — the backend choice is design-level, so I don't expect new EARS, but that's Phase 3 to confirm.

Here is the updated LLD in full:

---

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, index construction, and lookup all belong to this node. The kiosk keeps one active snapshot as a local embedded SQLite database; every lookup is served from that file, so no service runs and no network access is needed at query time.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build the incoming snapshot's SQLite index into a staging location, then activate it only after validation and index construction succeed. Activation atomically replaces the active database, so a reader sees either the previous complete snapshot or the new complete snapshot — never a partial one. An import failure leaves the previous snapshot active and reports a useful error.

## Index Format

The index is a single SQLite file containing:

- a `records` table keyed by the normalized serial number, holding the equipment description, calibration date, and due date;
- a `metadata` table holding the snapshot date and schema version.

The normalized serial number is the primary key. Normalization (surrounding whitespace trimmed, ASCII letters uppercased, punctuation preserved) is applied once at build time and again on each query, so lookups are a single primary-key equality seek. A 90,000-record snapshot with a primary-key index fits comfortably within the kiosk's memory and disk profile.

## Lookup Behavior

Normalize the requested serial number, then query the active index by primary key. Return the matching record with the active snapshot date; when no row matches, return `NotFound` with the same snapshot date. Serial-number punctuation is significant and is never stripped.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | Keeps every lookup on the kiosk (the no-network tenet) and removes a service to operate; accepts that each kiosk validates and rebuilds its own index when a snapshot arrives. |
| Snapshot activation | Build to a staging location, then atomically replace the active database | In-place update of the active database; retain versioned database files behind a mutable pointer | Atomic replacement is what lets an interrupted import leave the last valid snapshot intact and never expose a partial snapshot. |
| Index key | Normalized serial number stored as the primary key | Store raw serials and normalize at query time | Normalize once at build time for one equality seek per lookup, while keeping punctuation significant. |

## Open Questions & Future Decisions

### Deferred

1. Whether index construction runs inline with import or as a separate resumable step — decide alongside the kiosk import experience.
```

---

**One offer before we move on.** This was a close three-way choice with consequences that the certificate side and the import flow will be sized around — a cold reader could plausibly re-litigate it. Would you like me to record it as a full **decision doc** (`docs/intent/registry/decisions/lookup-backend.md`), or is the Decisions & Alternatives row above enough?

Please review and give me numbered feedback or approval. Once you approve this LLD, I'll move to Phase 3 (EARS) — and tell me your call on the decision doc.