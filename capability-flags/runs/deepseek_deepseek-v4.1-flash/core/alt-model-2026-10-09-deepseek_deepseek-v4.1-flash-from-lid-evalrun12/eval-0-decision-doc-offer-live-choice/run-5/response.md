Updated `docs/high-level-design.md` to commit the delivery approach. The revised Approach reads:

---

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision and publishes it to connected browsers over self-hosted WebSockets. Browsers keep an open socket subscription and, after a disconnection, reconnect and catch up on revisions missed while away.

Self-hosted WebSockets give fast updates without tying the board to a realtime vendor. The accepted cost is owning connection capacity and reconnect behavior. Delivery, change storage, and browser recovery are designed together around this choice:

- **Change store** retains replayable revisions so a reconnecting browser can catch up, and publishes committed revisions reliably to connected sessions.
- **Delivery** manages socket sessions and the fan-out of published revisions, owning connection capacity and reconnect handling.
- **Browser sync** maintains the socket subscription, and after a disconnect reconnects and replays missed revisions to recover the latest board.

---

I also cascaded the choice into the Architecture bullets (each node's ownership is now fixed rather than conditional on the approach) and added a Key Design Decisions entry: *Self-hosted WebSockets for change delivery*, with polling and the hosted service recorded as rejected.

Two things to rule on before I go further:

1. **Record the delivery-approach choice.** It stays live for a cold reader — three credible options traded against cost, ops burden, latency, and vendor coupling, with three nodes about to be sized around the result. Do you want a full decision doc at `docs/decisions/` (the Key Design Decisions bullet would then link to it), or is the bullet I added enough?

2. **Cross-segment cascade into Access.** `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach" — now stale since the approach is settled. That's a different segment, so I've left it untouched. Want me to update that line to reflect the settled approach?