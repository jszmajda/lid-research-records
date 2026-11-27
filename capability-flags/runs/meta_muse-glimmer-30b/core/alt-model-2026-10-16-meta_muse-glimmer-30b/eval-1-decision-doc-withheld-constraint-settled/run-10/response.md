Phase 1 – HLD check
docs/high-level-design.md exists and covers the registry domain. Tenets require offline lookup, no runtime network, signed USB snapshots only, and the certificate component must not read registry storage directly. The local embedded SQLite index choice satisfies those tenets; no HLD change is needed.

Phase 2 – LLD update
docs/intent/registry/registry-design.md has been updated to record the backend selection and make the design context-free.

Architecture now states:
Snapshot validation, backend preparation, and lookup all belong to this node. The lookup backend is a local embedded SQLite index built per kiosk from each validated snapshot. The index lives in registry storage, is rebuilt atomically on snapshot activation, and requires no runtime network. No certificate behavior or interface change is part of this selection.

Lookup Behavior now states:
Queries execute against the SQLite index using prepared statements for serial lookup; the index is read-only during normal operation and is replaced atomically when a new snapshot activates.

Decisions & Alternatives table added:

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Lookup backend | Local embedded SQLite index rebuilt per kiosk on snapshot activation | On-site HTTPS directory; Managed search service | Predictable lookups with no service to run; matches HLD tenet of offline operation and no runtime network; each kiosk validates and rebuilds its own index when a snapshot arrives, keeping all maintenance inside the registry component. On-site HTTPS would centralize the index but depend on lab network and require timeout handling. Managed search reduces index maintenance but adds recurring cost, credentials, and external connectivity concerns for registry. Certificate interface unchanged in all options. |

Open Questions & Future Decisions now records:
Resolved: Lookup backend selected as local SQLite index
Deferred: Index schema details and SQLite pragmas for 90k records / 250 ms lookup target; Disk space budget for SQLite file vs raw snapshot

LLD-level edge-case probe for this LLD:
1. What happens when the SQLite index build fails after signature/schema/duplicate validation passes? Is the partial file discarded and the previous index retained?
2. What happens if a lookup is requested while the atomic index swap is in progress? Is the read served from the old index or blocked?
3. Uniqueness validation: is serial uniqueness checked on the normalized form used for lookup, or on the raw value? What if two records differ only by surrounding whitespace or ASCII case?
4. Normalization is defined as trim + ASCII uppercase. What is the behavior for serials containing non-ASCII characters? Should they pass through unchanged?
5. What happens if the SQLite file is corrupted on disk? Is there a health check on startup and a fallback to the previous snapshot?
6. What happens if two snapshots are presented concurrently or a second import starts before the first activation completes?
7. What is the atomic replacement mechanism? Rename-swap, write-to-temp-then-replace, or versioned files?
8. How is the 250 ms lookup target enforced for 90k records? Which SQLite pragmas / indexes are assumed?
9. Should the normalized serial be stored in the index, or is normalization applied only at query time?

Please review the Phase 1 HLD check and the updated LLD with the edge-case probe above. Triage which gaps to close in the LLD now vs defer, and confirm approval to proceed to Phase 3 – EARS spec draft/update.