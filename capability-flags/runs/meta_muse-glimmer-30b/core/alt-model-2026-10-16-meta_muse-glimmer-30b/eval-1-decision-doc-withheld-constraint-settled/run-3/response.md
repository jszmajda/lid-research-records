Updated the Registry LLD with the SQLite decision.

**Changes to `docs/intent/registry/registry-design.md`:**
- Architecture now specifies a local embedded SQLite index built from the active snapshot; each kiosk validates and rebuilds its own index on arrival, no service required.
- Snapshot Import adds “Build the SQLite index from the validated records before activation. Activate it only after all validation and index build succeeds.”
- Lookup Behavior notes lookups execute against the local SQLite index.
- Added Decisions & Alternatives table recording the choice of Local embedded SQLite index over On-site HTTPS directory and Managed search service with rationale.
- Open Questions moved the backend decision to Resolved; deferred index rebuild performance budget for 150 MB snapshots on 4 GB RAM kiosks.

**LLD-level edge-case probe for your triage:**
1. What happens if snapshot import is interrupted / power loss occurs during index build?
2. What happens if a lookup request arrives while index rebuild is in progress?
3. What happens if the SQLite index file becomes corrupted on disk?
4. What happens if a serial number contains non-ASCII characters beyond uppercase ASCII normalization?
5. What happens if two snapshots arrive concurrently?
6. What happens if the snapshot schema version changes between imports?

Please indicate which gaps to address in the LLD now vs defer, and confirm approval to proceed to Phase 3 EARS consistency verification.