Now I'll run an LLD-level edge-case probe to identify gaps in the registry design with the SQLite backend selected:

**Edge-Case Probe Results**

The following gaps emerged when probing the SQLite-backed registry design for state transitions, invariants, and error handling:

1. **Concurrent access during import**: What happens when a lookup request arrives while the registry is replacing the active index database? Is there a lock, a lease, or a read-only copy guarantee?

2. **Index readability validation**: The design says "validating that all records are readable before committing the transaction." What specific errors trigger a rollback? If 89,999 records insert successfully but record 90,000 fails to read back, does the entire import fail?

3. **Snapshot staging isolation**: During the import phase, if a staging database write fails partway through (disk full, permission denied), does the system explicitly clean up the temporary file, or does it leave a cleanup obligation?

4. **First-boot state**: On a kiosk with no prior snapshot, `findBySerial` is called. What does it return? Is there a "no snapshot loaded" error distinct from "serial not found"?

5. **Multi-version index retention**: The design says fallback to "the most recent valid snapshot if one exists" when the active index is corrupted. Does the system keep prior snapshots on disk, or only the active one? If kept, how many?

6. **Snapshot metadata durability**: The metadata record (snapshot date, schema version, signature reference) is stored "alongside or within the database." If this gets out of sync with actual records, what is the recovery path?

7. **Normalization edge cases**: Whitespace and ASCII letter case are normalized. What about Unicode lookalikes, leading zeros, or non-ASCII punctuation? Are these explicitly out of scope or handled?

8. **Timestamp format and timezone**: The snapshot date is returned in `findBySerial` results and displayed on certificates. What format and timezone are used? Is there an invariant that the snapshot date never changes for a given active index?

---

**Please review these gaps and advise:**

- Which gaps should be resolved in the LLD (design elaboration)?
- Which should become EARS specifications (behavioral requirements)?
- Which are open questions for later (deferred decision)?

Once you clarify the treatment, I'll update the design and specs accordingly before moving to Phase 3.