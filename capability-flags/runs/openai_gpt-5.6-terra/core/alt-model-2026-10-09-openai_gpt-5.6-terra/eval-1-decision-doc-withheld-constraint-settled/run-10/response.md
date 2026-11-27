## Registry LLD Draft

Updated `docs/intent/registry/registry-design.md` to select a kiosk-local embedded SQLite index.

- Imports stream verified snapshot records into a uniquely named candidate SQLite database.
- The normalized serial number is the SQLite primary key; canonical duplicates reject the import.
- SQLite integrity validation precedes activation.
- A durable active-database record is atomically switched only after a complete, valid candidate exists.
- Lookups use the active database read-only and observe either the old or new snapshot, never an incomplete import.
- The certificate-facing `findBySerial` result type remains unchanged.
- The design records the rejected HTTPS-directory and managed-search alternatives and their rationale.

## LLD Edge-Case Probe

Please review the draft, especially these cases:

1. **First startup before any valid snapshot:** `NotFound(snapshotDate)` requires an active snapshot date, but the design does not define what `findBySerial` returns when no snapshot has ever been imported. Should lookup return a distinct “registry unavailable/not initialized” result, or should the application prevent lookup until a valid snapshot is imported?
2. **Power loss during activation:** The intended behavior is that startup continues using the prior active database if the activation record was not durably replaced. Please confirm that this recovery guarantee is required, so it can be made explicit in the LLD and EARS specs.
3. **Disk-full or write failure during candidate creation:** The prior active snapshot remains usable; the import reports an error and any incomplete candidate is inactive. Please confirm this is the desired technician-visible behavior.
4. **Canonical collisions:** `ab-12` and `AB-12` are the same serial after the required ASCII case normalization and therefore reject the snapshot as duplicates. Punctuation remains significant, so `AB-12` and `AB12` remain distinct. Please confirm this interpretation.