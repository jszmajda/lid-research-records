I’ve drafted the SQLite-backed registry design in `docs/intent/registry/registry-design.md` and updated the HLD to remove the open-backend language. The certificate interface remains unchanged.

The design now covers:

- A registry-private SQLite database built locally from validated snapshot records.
- A unique index on normalized serial numbers with parameterized exact-match queries.
- Snapshot date stored in the same database as its records.
- Staging, integrity checking, and atomic replacement of the complete database.
- Preservation of the previous snapshot when import fails before activation.
- The backend alternatives and rationale in Decisions & Alternatives.

The edge-case probe found these decisions still need your judgment:

1. **Lookup failures:** When SQLite cannot open or query the active database, should `findBySerial` return a distinct error result or throw? It should not report `NotFound`, which would falsely claim the serial is absent.
2. **Import contract:** Should import be synchronous? Which failures must callers be able to distinguish, and is cancellation required?
3. **Crash at activation:** After a crash during or immediately after atomic rename, may the replacement become active even though success was never reported, or must the previous snapshot be restored?
4. **Overlapping imports:** Should they be serialized, rejected, or allowed concurrently? May an older snapshot replace a newer active snapshot?
5. **Lookups during activation:** Should they continue against the old snapshot or briefly block?
6. **Snapshot validation:** Are empty snapshots valid, and what validation applies to snapshot dates and metadata?
7. **Normalized duplicates:** Should serials differing only by case or surrounding whitespace be rejected as duplicates? The unique normalized-serial index currently implies yes.
8. **No active snapshot:** What should startup and lookup do before the first successful import?
9. **Damaged active index:** Should startup fail, rebuild from a retained snapshot, or enter another explicit state?
10. **Open readers:** Does the kiosk operating system permit atomic replacement while SQLite readers are open, or should activation drain readers/use indirection?

Please resolve or explicitly defer these points, and approve or request changes to the drafted LLD. I’ll update the EARS specifications after your review.