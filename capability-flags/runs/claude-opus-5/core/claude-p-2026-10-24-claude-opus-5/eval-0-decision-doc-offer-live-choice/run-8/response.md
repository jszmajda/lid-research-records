Phase 1 — HLD updated for the self-hosted WebSockets choice. Three edits, all in `docs/high-level-design.md`:

**Approach** — now states the mechanism rather than the open choice: the server holds an open connection per viewing browser and pushes each newly committed revision; no realtime vendor sits in the delivery path, so connection capacity, reconnect, and socket-tier operations are ours. The second paragraph replaces "must be designed together after this choice" with what each node now owns — replayable revision log plus reliable publication (change store), socket sessions and capacity (delivery), reconnect and catch-up from the last held revision (browser sync). The deliberation residue ("neither cost nor operational burden has been declared the overriding criterion") is gone, since it has been.

**Architecture** — the three unwritten nodes' one-liners now name socket-shaped responsibilities instead of "depends on the approach."

**Key Design Decisions** — new entry naming both rejected options and why (polling: seconds of lag plus repeated reads for 800 mostly-idle browsers; hosted service: recurring per-connection fees and a provider's subscription model in every board's delivery path), and the accepted cost.

Four things for you before Phase 2:

1. **Record this as a decision doc?** It clears the bar in my reading — three credible options traded against latency, cost, vendor coupling, and ops burden, and all three remaining nodes are about to be sized around the result, so a cold reader could well re-litigate "why not the hosted service?" The alternative is what I've already written: the Key Design Decisions entry alone. Your call; I'll write `docs/decisions/change-delivery-approach.md` only if you want it.

2. **A tenet on capacity saturation.** Owning the socket tier creates a class of choices no spec will anticipate: what gives when connections run past planned capacity. Two defensible leans — *refuse new connections and keep subscribed browsers fully fresh*, or *admit everyone and let fan-out fall behind for all*. Which way should the project lean? (Or tell me it's premature and I'll leave the tenet list as it stands.)

3. **Is an HTTPS fallback in scope?** I deliberately didn't decide this in the Approach. If browsers should fall back to polled reads when a socket can't be established, the change store needs cursor queries as well as log replay, and browser sync carries two delivery modes — materially more surface in two of the three nodes. If sockets are the only path, a browser that can't connect shows the disconnect state and retries. I'd default to socket-only for the pilot, but it's your risk call.

4. **Cross-segment staleness in `access`.** `access-design.md` says authorization "is independent of the still-open change-delivery approach," and that subscription credentials "will belong to the delivery node." Both now read stale, and connect-time socket authorization may turn out to need something from access. That's a different segment, so I haven't touched it — want me to refresh those two lines now, or leave access alone until the delivery node tells us what it actually needs from it?