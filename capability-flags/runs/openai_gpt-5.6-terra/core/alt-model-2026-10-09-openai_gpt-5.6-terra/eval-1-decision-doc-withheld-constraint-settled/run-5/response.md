## Registry LLD Draft

Updated `docs/intent/registry/registry-design.md` to select a local embedded SQLite index.

- The active registry is a kiosk-local SQLite database, with no runtime network dependency.
- Snapshot imports validate first, build a separate staging database, then atomically replace the active database only after successful construction.
- Lookups use normalized serial numbers for exact indexed queries and return the active snapshot date for both `Found` and `NotFound`.
- The database enforces uniqueness of normalized serial numbers as a second safeguard.
- The decision table records why SQLite was chosen over an on-site HTTPS directory and managed search service.

No standalone decision document was added: this choice is bounded to the registry node and its rationale is adequately captured in the LLD.

## LLD Edge Cases To Triage

Before I draft or revise registry EARS specifications, please decide how to handle these LLD-level gaps:

1. **Active-database replacement with open lookups:** should imports wait for active lookup handles to close, briefly reject new lookups during activation, or use a platform-specific indirection mechanism such as an active-version pointer?
2. **Snapshot record validation:** beyond duplicate serial numbers, which malformed fields must reject an entire snapshot? Candidate fields are missing/blank serial number, invalid dates, and missing equipment description.
3. **Serial-number character set:** normalization currently only trims whitespace and uppercases ASCII letters. Should non-ASCII serial numbers be rejected during import, preserved and matched exactly, or normalized with a defined Unicode rule?
4. **Staging recovery:** if the kiosk loses power while building the staging database, should the next launch automatically remove incomplete staging files, or retain them for technician diagnostics?
5. **Import capacity failure:** if the kiosk lacks disk space or the SQLite build fails, should the registry expose only a generic import failure, or distinguish capacity and database-construction errors for the technician?

Please approve the LLD draft and answer the items you want resolved now; I will record those choices and proceed to the EARS phase.