Updated:

- `docs/high-level-design.md` now records the local SQLite index and the rationale for choosing it.
- `docs/intent/registry/registry-design.md` now specifies the SQLite schema, normalized lookup key, staged import, transactional activation, and lookup behavior.

`git diff --check` passes. The HLD and Registry LLD agree on the offline architecture, and the unchanged `findBySerial` result remains consistent with the Certificates LLD.

## Registry LLD draft for review

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. The registry receives signed snapshots as newline-delimited JSON records with a schema version, snapshot date, and signature manifest. Kiosks use these snapshots without a runtime network connection.

Snapshot validation, local index construction, activation, and lookup are owned by the Registry component. The certificate component depends only on the stable registry result type and does not access registry storage.

## Architecture

The Registry exposes `findBySerial(serial)`, returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. The record fields and result type do not expose SQLite details.

Each kiosk maintains a private SQLite database containing the currently active snapshot's records and metadata. SQLite is embedded in the kiosk application; no service, credentials, or runtime network access are needed. A B-tree primary key on the normalized serial supports exact serial lookups within the project goal of 250 ms for a 90,000-record registry.

The database contains:

| Table | Contents |
|---|---|
| `registry_metadata` | The active snapshot date and source schema version. |
| `records` | The source serial, its normalized lookup key, equipment description, calibration date, and due date. The normalized key is the primary key. |

The source serial is retained for the returned record. The lookup key is produced by trimming surrounding whitespace and converting ASCII letters to uppercase. SQLite compares the key using binary equality; punctuation is not removed or rewritten.

## Snapshot Import and Activation

1. Read the snapshot from approved USB media and verify its signature using the bundled public key. Reject an unsupported source schema version.
2. Parse and validate the complete snapshot into a temporary local SQLite database using the same record schema and normalized-key constraint as the active database. Duplicate normalized keys are rejected, including serials that differ only by surrounding whitespace or ASCII letter case.
3. After all records have been accepted and the staged database passes SQLite integrity checking, activate the replacement in a transaction against the active database. Replace all records and update the snapshot date and source schema version in the same transaction.
4. Commit only after the full replacement is ready. SQLite readers observe either the old committed snapshot or the new committed snapshot; a failed import or failed activation leaves the prior snapshot available. Temporary import data is removed after success or failure.

The active database uses SQLite WAL mode so lookups can continue against the prior committed state while the replacement is staged and written. Each lookup reads the matching record and snapshot metadata in one read transaction, ensuring that the record and returned snapshot date come from the same active snapshot. Only one import may activate at a time.

An import failure is reported with an actionable reason. It does not partially update the active records or snapshot metadata.

## Lookup Behavior

Normalize the requested serial in the same way used for stored lookup keys. An exact key match returns `Found(record, snapshotDate)`; a miss returns `NotFound(snapshotDate)`. A lookup does not perform fuzzy matching or ignore punctuation. The snapshot date is returned for both outcomes.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | A local embedded SQLite index rebuilt from each accepted snapshot on every kiosk | An on-site HTTPS directory; a managed search service | Kiosks have no runtime network route, and signed USB snapshots are the update channel. A local index makes lookup self-contained and keeps validation and index maintenance in Registry. It requires each kiosk to validate and rebuild its own index when a snapshot arrives. The fixed lookup result keeps the backend change invisible to Certificates. |
| Snapshot activation | Replace active records and metadata in one SQLite transaction after complete staging | Expose records while they are imported; replace data before all validation completes | The transaction gives readers an all-old or all-new snapshot and preserves the prior committed state if activation fails. |
| Serial lookup key | Trim surrounding whitespace and uppercase ASCII letters; preserve punctuation; enforce uniqueness on the normalized key | Exact raw-string matching; punctuation-insensitive or broader canonicalization | This matches the lookup normalization contract while preventing two source records from mapping to the same lookup key. Punctuation remains significant as stated by the registry contract. |

## Open Questions & Future Decisions

### Deferred

1. The lookup result currently defines only `Found` and `NotFound`. The behavior before the first successful snapshot import is not specified; decide whether installation/import must guarantee an active snapshot before lookup is available or whether the registry interface needs an explicit unavailable/error result. Any interface change requires review of the Certificates segment.

## References

- `docs/high-level-design.md` — offline kiosk architecture, capacity, and lookup target.
- `docs/intent/registry/registry-specs.md` — registry behavior requirements.
- `docs/intent/certificates/certificates-design.md` — consumer contract and storage boundary.
```

## Edge-case probe

The design handles failed activation without exposing partial data. These remaining cases need your judgment:

1. **Before the first successful import:** Should installation/import guarantee an active snapshot before lookups are available, or should the registry return an explicit unavailable/error result? The latter changes the interface consumed by Certificates.
2. **Older signed snapshot:** If a valid snapshot has a date earlier than the active snapshot, should Registry allow it to replace the active one or reject it?
3. **Invalid individual records:** Should malformed JSON, missing required fields, empty serials, or invalid dates reject the entire snapshot, or may invalid records be skipped?
4. **Overlapping imports:** Should a second import request be queued or rejected while another import is in progress?

Please review the LLD and say which probe items you want resolved in the design versus deferred. Once you approve the LLD, I’ll update the Registry EARS specs and continue the workflow.