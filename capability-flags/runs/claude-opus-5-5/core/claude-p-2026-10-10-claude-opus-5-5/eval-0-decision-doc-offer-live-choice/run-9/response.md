I've updated `docs/high-level-design.md` to the self-hosted WebSockets approach. Nothing else is touched and nothing is committed; the three nodes wait for your review of this.

## What changed

**Approach** now reads:

> Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit an event revision. Committed revisions reach browsers over WebSocket connections that MarketBoard hosts itself, so a change normally appears in connected browsers well inside the freshness goal rather than at the edge of it.
>
> The sockets carry committed revisions from server to browser only. Commands stay on HTTPS, so the command path and its authorization do not depend on a socket being open.
>
> Hosting the sockets means MarketBoard owns what a realtime provider would otherwise absorb: capacity for 800 simultaneous connections, connection lifecycle, and recovery after a dropped connection. That shapes three components, which are designed together:
>
> - The change store keeps each event's revisions in order and replayable from any retained revision, and reliably hands every committed revision to delivery.
> - Delivery manages socket sessions and pushes each event's revisions to the browsers subscribed to it.
> - Browser sync reconnects after a drop, catches up from the last revision it applied, and shows when it is not connected.

**Architecture** — the three unwritten nodes now state what they own instead of "depends on the approach":

- **Change store:** event revision history, replay from a given revision, and reliable publication of committed revisions to delivery.
- **Delivery:** socket sessions, per-event subscriptions, connection capacity, and pushing revisions to subscribed browsers.
- **Browser sync:** the browser's socket subscription, reconnect, catch-up from its last applied revision, and the visible connection state.
- **Access:** its line now reads "Authorizes HTTPS commands."

**Key Design Decisions** — new entry:

> **Self-hosted WebSockets deliver committed changes.** MarketBoard runs its own socket connections and pushes each committed revision to subscribed browsers. This gives low-latency updates with no recurring realtime-provider fee and no provider coupling; the cost is owning connection capacity, session management, and reconnect recovery. Five-second HTTPS polling was rejected: it is the simplest to operate and meets the 15-second freshness goal, but every browser re-reads on a timer and every update lags by seconds. A hosted realtime service was rejected: it is the quickest route to low latency with the least connection operations, but adds recurring fees and couples the board's delivery, credentials, and browser subscription model to one provider.

Tenets, Goals and Non-Goals are unchanged.

## Questions for you

1. **Sockets are delivery-only.** I wrote that sockets carry revisions server-to-browser and commands stay on HTTPS, because the existing HTTPS-commands decision and the access node are built on that. Is that right, or did you intend edits to travel over the socket too?
2. **Freshness goal.** The goal still says 15 seconds, which polling would also have met. Should it stay as the outer bound, with "fast" as the normal case, or do you want a tighter number? The delivery and browser-sync nodes will be sized against whatever it says.
3. **Vendor independence as a tenet.** The tenet "Self-hosted and managed infrastructure are both permitted" still stands. Was avoiding a realtime vendor a one-off call for delivery, or a lean you want recorded for future choices? I left it alone.
4. **Decision doc.** This choice trades latency, operating burden, recurring cost and vendor coupling, and three nodes are about to be built on it. Do you want a full decision doc at `docs/decisions/` laying out the criteria and options, linked from the entry above, or is the entry enough?
5. **Access node is now stale.** `access-design.md` still says "the still-open change-delivery approach" and that "delivery-specific subscription credentials" will belong to delivery. May I update the wording? Separately, who authorizes a viewer's socket subscription to an event — access or delivery? That needs settling before the delivery node.

Once you approve the approach (or send changes), I'll start on the three nodes, beginning with the change store unless you prefer a different order.