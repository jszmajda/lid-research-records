Verified: HLD fix applied, LLD rewritten fresh, existing REG specs still trace, certificates segment untouched (no cross-segment cascade). Here is the Phase 2 stop.

---

## Coherence pre-flight & how I recorded your choice

This is a new session resuming last session's backend selection, so I checked HLD ↔ LLD ↔ EARS ↔ tests for the registry segment first. One finding drives how I recorded your decision:

**The HLD already settles it.** Its tenets state *"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"* and *"Kiosks have no network route during normal operation,"* and its Non-Goals bar *"cloud services during kiosk operation."* Two of the three options you weighed — the on-site HTTPS directory (lab-network lookups + timeout handling) and the managed search service (external connectivity, credentials, recurring cost) — require runtime network access and are therefore inadmissible under the current HLD. The **local SQLite index is the only compliant option**; from the design's standpoint the choice was already forced, which is why it looked closer than it was.

Because this is a choice **an inherited constraint settles**, that **one option dominates**, and that **affects only its own node** (the certificate interface is unchanged), I did **not** offer a decision doc — the skill reserves those for choices that stay genuinely live for a cold reader *however long the debate ran*, and a landed local index reads as native given the offline tenets. I recorded the rejected alternatives and their rationale in the registry LLD's **Decisions & Alternatives** table instead, wrote the docs as a fresh author (no "went back and forth," no "we selected," no "as discussed" residue), and kept the decision's substance inside the registry segment with no cross-segment obligation. `docs/intent/certificates/` is untouched — that is the across-segment pause.

HLD coherence fix only: removed the stale *"Its private lookup backend remains open"* and named the registry's `index maintenance` responsibility. No architectural change; tenets unchanged.

## Phase 2 output — `docs/intent/registry/registry-design.md` (in full)

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks have no network route during normal operation, so each kiosk resolves lookups entirely from files it holds locally.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and the result type are a fixed contract; the certificates node depends only on this interface and has no visibility into registry storage, query syntax, or index files.

Snapshot validation, index maintenance, and lookup all belong to this node. The lookup backend is a local embedded SQLite index built from the active snapshot. It is a file on the kiosk; no separate service runs and no network access is used.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. Build the SQLite index for the validated records in a staging file, confirm the built index is complete and queryable, and activate it only after every check succeeds by renaming the staging file into the active index slot. Prepare the new snapshot without exposing partially imported records. Any import failure leaves the previous snapshot and its index active and reports a useful error.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active SQLite index, keyed on the normalized serial number, so a lookup is a single-key read that stays within the 250 ms goal at 90,000 records. Return the snapshot date even when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | The HLD requires every serial-number lookup to complete from files on the kiosk with no runtime network access and bars cloud services during kiosk operation. Both alternatives depend on network or external connectivity, so they are inadmissible here. SQLite keeps validation, indexing, and lookup inside the registry, needs no service to run, and leaves the certificate interface unchanged. |
| Index construction | Each kiosk builds and validates its own index from each arriving snapshot, then activates it by an atomic file rename | Prebuilt index shipped from the central team; incremental index updates | Signed USB snapshots are the only update channel and arrive as whole files. A full local rebuild keeps index correctness under the kiosk's own validation and makes activation a single atomic swap, matching the rule that no partially imported snapshot is exposed. A prebuilt index would move correctness outside that validation; incremental updates add state that must be reconciled across snapshots. |

## References

- High-level design: docs/high-level-design.md
- Certificates design: docs/intent/certificates/certificates-design.md
```

## LLD-level edge-case probe — gaps in the finished LLD

Per the skill I kept this probe to the LLD's own gaps (cross-spec / cross-segment forks are Phase 4, not here). Each is genuinely under-specified; **I have not resolved any of them**:

1. **Lookups during an index build** — the LLD builds a staging file and renames it into the active slot, but does not say what `findBySerial` does while a build is in flight: keep serving the previous active index, block until the rename, or fail. (State-transition gap; bears on the HLD tenet that a failed import leaves the last valid snapshot available.)
2. **What the built-index check verifies** — "confirm the built index is complete and queryable" is the activation gate, but its checks are unstated (record count vs. the snapshot, a probe lookup, a SQLite integrity check, or a combination). (Unstated invariant; two implementers would build different gates.)
3. **Index lifetime across kiosk restarts** — the LLD persists the index as the active file but does not say whether a reboot reuses it or triggers a rebuild from the active snapshot. (State-transition gap.)
4. **Fate of the superseded index** — the LLD renames the staging file into the active slot but does not say whether the previously active index is deleted, retained for rollback, or archived — relevant to disk growth under repeated 150 MB snapshots. (Missing transition.)
5. **Import error shape** — "reports a useful error" has no shape, recipient, or delivery path specified. (Unspecified API error shape.)

## Stop — need your call before I cascade

Please give numbered feedback on the LLD, and **triage the five gaps**: for each, say whether to fix it in the LLD now or defer it as an open question. I have deliberately not answered these for you.

I have **not** touched the EARS specs (Phase 3), tests, or code — the new SQLite behaviors (index build/validation, atomic activation, persistence) are the coverage gaps Phase 3 will add specs for — and I have **not** cascaded into the certificates segment. On your approval of the LLD and the triage, I'll proceed to Phase 3 (EARS draft + post-draft consistency report); if you want anything above changed, I'll revise in place first.