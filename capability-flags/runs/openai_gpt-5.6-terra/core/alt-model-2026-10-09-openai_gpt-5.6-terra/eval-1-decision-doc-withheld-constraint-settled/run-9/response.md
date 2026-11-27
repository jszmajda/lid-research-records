## Phase 1: HLD Review

Updated `docs/high-level-design.md` to record the selected registry architecture:

```markdown
- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup through a kiosk-local embedded SQLite index rebuilt from each validated snapshot.
```

This preserves the HLD’s offline-only, USB-update, atomic-import, and certificate-storage-boundary tenets. The SQLite schema, rebuild process, activation mechanism, and failure handling will be specified in the registry LLD.

Please approve the HLD update to proceed to Phase 2 and finish the registry LLD.