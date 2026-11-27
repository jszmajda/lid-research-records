Updated `docs/high-level-design.md` for the self-hosted WebSockets choice:

- **Approach**: resolved the open delivery question — the server now owns its own WebSocket connections and pushes revisions directly, trading connection/reconnect ownership for fast, vendor-free updates.
- **Architecture**: the change-store, delivery, and browser-sync entries now state their concrete obligations (replayable revisions + reliable publication; socket session management; reconnect/catch-up logic) instead of "depends on the approach."
- **Key Design Decisions**: added a row recording the choice and why the other two options were rejected.

This decision stays genuinely live for a cold reader — three credible options traded against latency, cost, and ops-burden criteria, with three sibling LLDs (change-store, delivery, browser-sync) about to be sized around it. Per the decision-docs guidance, I'm offering a full decision doc (`docs/decisions/change-delivery-approach.md`) as an alternative to just the HLD row above, rather than writing one unasked.

Want me to write that decision doc, or is the HLD row enough? And once you're happy with the HLD update, say go ahead and I'll start Phase 2 on the three nodes (change-store, delivery, browser-sync).