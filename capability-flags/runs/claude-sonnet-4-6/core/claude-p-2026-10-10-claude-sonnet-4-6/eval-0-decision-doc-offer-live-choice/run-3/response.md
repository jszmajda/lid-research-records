The HLD now reads cleanly with the decision locked in. Here is the full updated document for your review:

---

**Phase 1 — HLD update for review**

Three things changed:

**Approach** — replaced "still open: polling / sockets / hosted" with a direct statement that committed changes are delivered over self-hosted WebSockets, and described what that means for each downstream component: replayable revision sequences + outbox in the change store; session management + fan-out in delivery; reconnect/catch-up + connection state in the browser layer.

**Architecture** — replaced the "not written yet / depends on delivery approach" hedges with WebSocket-specific obligations for each of the three unwritten components.

**Key Design Decisions** — added the delivery-approach entry with the two rejected alternatives (polling: lag + read load; hosted service: fees + coupling) and the accepted trade-offs (connection-capacity and reconnect operations, replayable store, browser catch-up logic).

---

**Decision doc offer.** This choice traded three credible options against at least two criteria (latency vs. operational cost vs. vendor coupling), and the three unwritten LLDs will be sized around it. A cold reader encountering the Key Design Decisions row would have enough to follow the reasoning — the row names the alternatives and why each was rejected. I'd recommend the row as sufficient here; a full decision doc would add context, but the material is already compact and the row captures it. Let me know if you'd prefer a standalone doc at `docs/decisions/delivery-approach.md` instead.

Ready to move to the three nodes (change-store, delivery, browser-sync LLDs) when you approve this HLD update.