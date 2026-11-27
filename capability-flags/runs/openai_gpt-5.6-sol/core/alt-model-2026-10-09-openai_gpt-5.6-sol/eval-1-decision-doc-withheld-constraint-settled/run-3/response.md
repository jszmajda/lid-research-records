Phase 1 is ready for review. I updated `docs/high-level-design.md` to state that the registry owns a private embedded SQLite index built from each accepted snapshot. This keeps the architecture coherent with the offline-operation and USB-update tenets; the index lifecycle details remain in the registry LLD.

Please approve this HLD update, and I’ll draft the completed registry design.