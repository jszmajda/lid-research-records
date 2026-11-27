I updated the HLD to name the local SQLite index and drafted the registry LLD. The LLD keeps the certificate-facing lookup interface unchanged.

## Registry LLD draft

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. Each kiosk builds and maintains its own lookup index from the signed registry snapshot delivered on approved USB media. The signed snapshot is the authoritative input; the SQLite database is a local, rebuildable lookup index. All validation, index preparation, activation, and lookup remain inside the registry component.

## Registry Interface

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. The record contains the equipment description, calibration date, and due date. The result types and fields do not expose SQLite tables, query syntax, or storage paths. The certificates node uses only this interface.

## Snapshot Import and Index Activation

The signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Verify its signature using the bundled public key and reject unsupported schema versions before activating any data. Parse and validate the records while preparing a replacement index. Normalize each serial number using the lookup normalization rule and reject duplicate normalized keys, including serials that differ only by surrounding whitespace or ASCII letter case.

Store the active records in a local SQLite database. The record table has the normalized serial number as its primary key and stores the equipment description, calibration date, and due date. Store the active snapshot date as database metadata. The primary-key index supports exact serial-number lookup; no network service or separate search process participates in imports or lookups.

Build and activate a replacement within one SQLite transaction. Do not expose a replacement until its signature, schema version, and complete record set have passed validation. Commit the replacement records and snapshot date together; if validation or database work fails, roll back so the prior records and date remain active and report an import error. Serialize snapshot imports so two replacements cannot interleave.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Use an indexed equality lookup on the normalized serial number. Return the active snapshot date with both `Found` and `NotFound` results. The registry performs local lookups against the active SQLite database and does not require runtime network access.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | A local SQLite index maintained by each kiosk | An on-site HTTPS directory; a managed search service | Kiosks have no runtime network route. A local embedded database provides predictable indexed lookups without an additional service or credentials, and keeps the backend inside the registry boundary. |
| Index key | Normalized serial number as the unique primary key | Indexing the source serial verbatim or using a non-unique key | Lookup normalizes surrounding whitespace and ASCII case, so uniqueness must be enforced on the same canonical value to prevent ambiguous matches. |
| Replacement activation | Replace records and snapshot metadata in one SQLite transaction | Expose records incrementally or keep a partially populated replacement active | A transaction makes the new snapshot visible as one complete generation and preserves the previous active snapshot when preparation fails. |

## Open Questions & Future Decisions

1. Define the exact error categories and user-facing messages for import failures.
2. Define behavior before the kiosk has any successfully imported snapshot.
3. Confirm whether the registry must support lookups concurrently with snapshot import and specify any resulting busy/retry behavior.

## References

- [GaugeDesk High-Level Design](../../high-level-design.md)
- [Registry specifications](registry-specs.md)
- [Certificates design](../certificates/certificates-design.md)
```

## LLD edge-case probe

Please review these questions and indicate which should be resolved in the LLD now and which should remain open:

1. **No active snapshot:** Before the first successful import—or if the local index is missing or corrupt—what should `findBySerial` do when it cannot provide a snapshot date?
2. **Normalization collisions:** Should a snapshot be rejected if two source serials become identical after trimming surrounding whitespace and uppercasing ASCII letters? The draft says yes; `REG-003` currently says only “duplicate serial numbers.” Also, what whitespace characters count as surrounding whitespace?
3. **Concurrent lookup and import:** Must lookups remain available during an import and meet the 250 ms target, or may they wait or return a temporary error?
4. **Import failures:** Is a useful generic import error enough, or should the registry distinguish failures such as invalid signature, unsupported schema, malformed records, and database errors?

The current EARS remain mostly aligned: `REG-001` covers normalization, `REG-002` covers the snapshot date, and `REG-004` covers atomic activation. `REG-003` needs clarification if normalized collisions are intended to count as duplicates. I also ran `git diff --check`; it passed.

Please review the LLD and triage the four questions. I’ll wait for your response before updating the registry EARS.