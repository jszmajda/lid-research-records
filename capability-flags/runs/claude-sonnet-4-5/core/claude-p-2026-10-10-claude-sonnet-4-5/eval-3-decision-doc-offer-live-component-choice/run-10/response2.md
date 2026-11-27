Perfect. The record-store LLD is now complete with:

**Core mechanics defined:**
- Whole-visit revision chains with sequential IDs
- Two-state model (resolved/unresolved) with clear transition rules
- Base revision validation covering all submission scenarios
- Complete API contracts (submission, retrieval, resolution, history)

**Downstream contracts specified:**
- **Tablet-sync** needs to: track base revision IDs locally, handle conflict notifications, display resolved vs. unresolved states, persist idempotency keys for retries
- **Review-export** needs to: build revision comparison UI, exclude unresolved visits from CSV, show resolution history, support manual merges, track review workload

**Design decisions documented:**
- Why whole-visit revisions beat field-aware merge (scientific relationships cross field boundaries unpredictably; merge rules would require continuous maintenance)
- Why field-aware merge remains credible (for domains where field independence is a verified invariant)
- Sequential integer revision IDs (human-readable, deterministic, compressible)
- Per-visit idempotency scope with indefinite validity (handles weeks-offline tablets)
- Unresolved visits excluded from export (coordinators affirm correctness before partner delivery)

The document reads context-free — a future session or cold reader can follow the design without conversation history.

Ready for Phase 3 (EARS specs) once you approve this LLD.