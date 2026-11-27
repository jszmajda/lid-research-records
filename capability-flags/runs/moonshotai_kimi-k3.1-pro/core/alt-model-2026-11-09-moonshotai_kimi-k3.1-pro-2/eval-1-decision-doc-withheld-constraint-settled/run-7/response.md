### Phase 1 — HLD check

Updated `docs/high-level-design.md` to record the registry’s private lookup backend as a **local embedded SQLite index**. Snapshot validation and lookup remain inside the registry component, and the certificate interface remains unchanged.

Please review and approve this HLD update so I can proceed to **Phase 2: completing the registry LLD**.