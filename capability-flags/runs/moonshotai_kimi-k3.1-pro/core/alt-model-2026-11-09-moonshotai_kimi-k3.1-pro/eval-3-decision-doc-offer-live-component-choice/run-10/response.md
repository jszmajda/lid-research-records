### Phase 1 — HLD check

Updated `docs/high-level-design.md` to record the selected architecture:

- **record-store:** “Accept visit submissions and preserve concurrent edits as competing whole-visit revisions for resolution.”
- **Architecture:** “Record-store uses whole-visit revisions: submissions based on the same revision remain intact as competing revisions until a coordinator resolves them. Tablet-sync and review-export depend on that node’s revision contract for submission metadata, the shape of review work, and which record states can enter an export.”

The HLD remains coherent with the existing goals and tenets, particularly **“Do not silently discard a submitted edit.”** No other HLD changes are needed.

Please approve this HLD update so I can proceed to **Phase 2: complete the record-store LLD**.