**Phase 1 — HLD updated for the self-hosted WebSockets route.** I edited `docs/high-level-design.md` only. Coherence pre-flight: the access segment is untouched by this choice (its LLD states authorization is independent of delivery), so no cascade into written specs/tests/code.

Changed sections:

**Approach**
> Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision, and browsers display a revisioned view of the board. Committed revisions reach browsers over self-hosted WebSockets: the server holds a live socket per connected browser and pushes each new revision as it is committed, so connected boards refresh without polling. Subsecond updates would be useful, but are not required.
>
> Change storage, delivery, and browser recovery are designed together around this route. The change store retains replayable revisions and reliably publishes each committed revision; delivery manages socket sessions and connection capacity; browser sync subscribes over the socket and reconnects and catches up against retained revision history. The project owns connection capacity and reconnect behavior rather than delegating them to a realtime vendor.

**Architecture** (node obligations now WebSocket-specific)
> - Change store: … Not written yet. Retains replayable revision history and a publication outbox that reliably hands each committed revision to delivery.
> - Delivery: … Not written yet. Owns socket sessions and connection capacity, and publishes committed revisions to connected browsers.
> - Browser sync: … Not written yet. Subscribes over the socket, and reconnects and catches up against retained revision history.

**Key Design Decisions** (new entry)
> - **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over a server-held socket. Five-second HTTPS polling was rejected: it repeats reads and lags by the poll interval. A hosted realtime service was rejected: it adds recurring fees and couples the board to a vendor. Self-hosting accepts responsibility for connection capacity and reconnect behavior in exchange for low-latency updates without vendor dependency. This route sizes the change store (replayable revisions and reliable publication), delivery (session management), and browser sync (reconnect and catch-up).

Problem, Tenets, Goals, and Non-Goals are unchanged.

**STOP for your review.** A few things for you to rule on before we open the three nodes:

1. **Approval** — does the HLD above capture the route you picked, or should anything change before I move on?
2. **Decision doc?** This choice traded three credible options against more than one criterion (cost, ops burden, latency), and the three downstream nodes are about to be sized around it — so a cold reader may re-litigate it. Want me to record it as a full decision doc under `docs/decisions/` (linked from the Key Design Decisions entry), or leave the entry as-is?
3. **Tenet?** Your rationale leans on a forward-looking rule no spec will anticipate — *own the operational burden rather than couple to a realtime vendor, when that buys a real capability gap*. Its opposite (a vendor to cut ops) is a choice another project could reasonably make. Should I add it to `## Tenets`, or leave it out?
4. **Cross-segment staleness (cascade pause).** `docs/intent/access/access-design.md:10` still reads "independent of the still-open change-delivery approach." That phrase is now stale. Updating it crosses into the access segment, so I paused — want me to drop "still-open"?