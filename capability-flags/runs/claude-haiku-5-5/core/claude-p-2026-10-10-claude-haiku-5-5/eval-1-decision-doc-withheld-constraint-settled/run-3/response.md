Phase 1 (HLD check) is done. I stopped here for your review, per the workflow's phase stops, so the registry LLD, specs, and tests are not yet updated.

**What I checked**
- The HLD already covers the registry and its tenets. Lookup must use files on the kiosk, with no runtime network. A failed import must keep the last valid snapshot. The certificates component must not read registry storage directly. SQLite meets all four, so no tenet conflicts with your choice.
- The choice only affects the registry node. The certificates component still calls `findBySerial` and gets the same result types, so it belongs in the registry LLD, not the HLD. I didn't offer a decision doc, since this is a single-node choice a Decisions row can settle.

**What I changed**
- `docs/high-level-design.md`, Architecture, Registry bullet: "Its private lookup backend remains open" is now "Its lookup storage is private to the node." The old wording described a decision that is no longer open.

**Coherence pre-flight**
- The registry specs (REG-001 to REG-004) still trace to the registry LLD. Their wording doesn't depend on the backend, so they need no change for this decision.
- `docs/intent/registry/registry-design.md` is out of date. Its Architecture and Lookup Behavior sections still say the backend is not selected, and the Snapshot Import section doesn't say how a SQLite index is built and swapped in. Phase 2 fixes these.

**Next, pending your approval**
- **Phase 2 (registry LLD):** record SQLite as the backend with a Decisions & Alternatives row (the on-site HTTPS directory and managed search service as rejected alternatives, with reasons). Describe how the kiosk builds the index in a staging file, validates it, and swaps it in atomically. Remove the "not selected" language. Then run the LLD edge-case probe.
- **Phase 3 (EARS):** add specs only if Phase 2 changes behavior, such as index build failure or a lookup before any snapshot is active. Then run the consistency check.

Do you approve the HLD change, and should I go on to Phase 2?