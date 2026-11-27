The HLD is updated. Let me note what changed and what needs to happen next.

---

## Updated HLD — Phase 1 stop

Here is what changed and why:

**Approach** — replaced the open three-way choice with the chosen design: HTTPS commands in, WebSocket broadcasts out. Added the downstream obligations each segment carries as a consequence.

**Architecture** — updated each unwritten segment's stub to name its WebSocket-specific responsibility: publication outbox + cursor queries (change store), session and replay management (delivery), connection lifecycle + catch-up + visible disconnection (browser sync).

**Tenets** — split the fourth tenet. "Self-hosted and managed infrastructure are both permitted" was holding the delivery decision open; that decision is now made and moved to Key Design Decisions. "Event updates carry stall IDs and operational statuses, not customer records" survives as a data-boundary tenet.

**Key Design Decisions** — added the delivery approach decision with the rationale for rejecting polling and hosted service.

---

**Cascade flag — access-design.md**

`docs/intent/access/access-design.md` contains: *"Authorization for HTTPS edit commands is independent of the still-open change-delivery approach."* The "still-open" language is now stale. The substance is still correct (access is independent of delivery), so this is a wording-only update — but it crosses a segment boundary from the HLD into the ACCESS segment. I'll hold on it until you confirm.

---

**Decision doc offer**

The delivery mechanism choice (WebSockets vs. polling vs. hosted service) meets the earns-its-place test: a cold reader of the result would reasonably question it, the three options were weighed against several criteria (update latency, operational burden, vendor coupling, cost), and the change-store, delivery, and browser-sync segments are all sized around this result. That profile warrants a full decision doc at `docs/decisions/delivery-mechanism.md` rather than just the Key Design Decisions row.

Do you want one? (If not, the row already in the HLD is the record.)

---

Does the updated HLD read correctly? Any changes before we proceed?