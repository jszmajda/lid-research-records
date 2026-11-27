Overkill — no decision doc. I've recorded the choice as a row in the registry LLD's Decisions & Alternatives table instead, and created no `decisions/` file.

The decision-doc test runs from the **landed** state, not the deliberation, and this choice fails it on two counts:

- **An inherited constraint settles it.** The HLD Tenets already require lookups to finish from files on the kiosk with no runtime network access, and state kiosks have no network route. That eliminates the on-site HTTPS directory and the managed search service before any tradeoff weighing; SQLite is the only compliant option, so a cold reader finds it native, not non-obvious.
- **It affects only its own node.** All three options keep `findBySerial`'s result type and the certificate interface unchanged, and "all of that stays inside the registry component." No other node is sized around the result, so the "stays live" bar (credible options traded against more than one criterion *and* other nodes sized around it) isn't met.
- "They looked pretty close at first" describes the deliberation; the skill is explicit that a long debate is a symptom, not the test — "do not offer one … however long the debate ran." So I did **not** offer one and won't; the rule is to record the row without asking. A row (not "nothing") is still warranted: the tenets force *local* but not *SQLite specifically* over a plain local file, so one rationale line settles a cold reader's "why this?".

Placements follow from that: the HLD calls the backend "private," so the registry LLD owns it — no HLD Key Design Decisions entry, no new tenet (existing ones govern), and no cascade into the certificates segment (interface/result unchanged; I did not touch `certificates-design.md` or `certificates-specs.md`).

**Coherence pre-flight** (resuming at the registry LLD, Phase 2 — the HLD was settled last session and this internal choice doesn't change its architecture): REG-001..004 still trace to the LLD; the repo has no tests or code yet (all specs are `[ ]` gaps, design phase); LLD matches HLD architecture. Drift found and fixed: stale "remains open" / "not selected yet" / "pending the user's choice" residue, and a missing Decisions & Alternatives table.

**Phase 2 output — `docs/intent/registry/registry-design.md`:**

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Signed USB snapshots are the only registry update channel; the central inventory team publishes them and never operates a lookup service reachable from the kiosks. Each kiosk therefore keeps its own lookup index, built from the active snapshot.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed by this interface; backend details do not surface through it. The certificates node uses only this interface.

Snapshot validation, index preparation, and lookup all belong to this node. The lookup backend is a local embedded SQLite database file on the kiosk: answering a lookup starts no service and uses no network access.

## Lookup Index

The active snapshot is materialized as a SQLite database file with one row per serial number, keyed by the normalized serial number and holding that record's fields. A unique index on that key enforces one record per serial. Each kiosk rebuilds this file from the active snapshot on its own; no index is shared between kiosks.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build the new SQLite index from the validated records into a staging file without exposing partially imported records. Activate the staging file only after validation and the index build both succeed, keeping the previous snapshot and its index available until activation. An import or index-build failure leaves the previous snapshot active and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Look up the normalized serial number with a single indexed query against the active SQLite database file. Return the snapshot date even when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index, rebuilt on each kiosk when a snapshot arrives | On-site HTTPS directory; managed search service | Lookups must complete from files on the kiosk with no runtime network access (HLD Tenets), which eliminates both network-dependent options. Among local options, an embedded SQLite file gives predictable indexed lookups over 90,000 records within the 250 ms goal and starts no service. The per-kiosk validate-and-rebuild cost stays inside this node, and the `findBySerial` result type is unchanged for the certificates node. |

## References

- docs/high-level-design.md
- docs/intent/certificates/certificates-design.md
```

**Phase 2 LLD-level edge-case probe** — gaps in this LLD (I'm not resolving these for you):

1. What is the state before any snapshot has ever been imported (first boot), and what does `findBySerial` return then, given REG-002 requires a snapshot date in every result?
2. Where is the snapshot date stored and sourced for a NotFound result, when there is no matching row to carry it?
3. What happens when a lookup is in flight while a new snapshot's staging file is activated — is the lookup guaranteed to see one whole index, never a partially swapped file?
4. What happens when the index build fails mid-way (disk full, or a record malformed in a way initial validation missed)? Is the staging file discarded and the previous index retained (REG-003)?
5. Is "validate record serial numbers for uniqueness" applied to raw or normalized serial numbers? Two distinct raw serials can normalize to the same key — is that a duplicate rejection, and which wins?
6. What is the recovery path when the active SQLite file is missing or corrupt at kiosk startup, and what does a lookup return in that state?
7. When a future snapshot bumps the schema version, is the index always rebuilt from scratch, and is the index schema pinned to the snapshot schema version?

I'm pausing at the Phase 2 stop. Before I go on to Phase 3 (the EARS consistency check — whether the new index-rebuild behavior needs spec lines), please: (1) triage the gaps above — which to fix in the LLD now vs. defer as open questions; and (2) approve this LLD or give me numbered feedback. I won't move to specs, tests, or code until you reply.