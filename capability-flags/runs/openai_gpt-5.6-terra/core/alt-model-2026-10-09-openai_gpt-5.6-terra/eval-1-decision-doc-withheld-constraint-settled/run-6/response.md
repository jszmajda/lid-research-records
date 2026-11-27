## Phase 1: HLD Review

Updated `docs/high-level-design.md` to make the selected architecture explicit:

```markdown
- Registry: `docs/intent/registry/registry-design.md`, with `docs/intent/registry/registry-specs.md`. Owns snapshot validation and lookup through a local embedded SQLite index rebuilt from each validated snapshot.
```

The existing HLD remains coherent with this choice:

- Kiosk-local lookup and USB-only updates are already required.
- The SQLite index is internal to Registry; the certificate lookup interface remains unchanged.
- Existing tenets cover offline operation and preservation of the prior valid snapshot if import fails.

Please approve this HLD update to proceed to the Registry LLD design.