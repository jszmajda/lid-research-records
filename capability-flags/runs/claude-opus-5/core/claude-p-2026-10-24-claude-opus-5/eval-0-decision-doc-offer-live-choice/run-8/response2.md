Written to `docs/decisions/change-delivery-approach.md`, owned by `high-level-design`, and linked from the HLD's Key Design Decisions entry.

How it's built, since a few choices in it are worth your eye:

**No gates.** All three routes clear the 15-second goal, the 800-browser capacity, and the data boundary, so there was nothing that *eliminated* an option — the doc says that outright rather than listing passed-by-everyone constraints as if they discriminated. Selection turns entirely on weighted criteria.

**Six criteria**, with the weights where I think they honestly fall: recurring operating cost, delivery-path substitutability, and operational burden as *major*; flaky market connectivity and update latency as *moderate*; change-store read load as *minor*. Latency is deliberately not major — the binding goal is 15 seconds and subsecond is explicitly optional, so calling latency decisive would misrepresent your own goals.

**Two criteria cut against the choice**, and the doc says so instead of smoothing it. Operational burden is *major* and self-hosted sockets are *weak* on it. Flaky connectivity is only *partial* — market-floor drops are frequent and the recovery is now code we write rather than a property of the transport. Selection states the judgment plainly: one-time engineering against a recurring fee and a permanent coupling. That's the tradeoff you accepted, so I made it legible rather than arguing it away.

**Polling is given its real strengths.** It wins on cost, burden, connectivity, and substitutability, and loses on one thing. The doc names that as a preference for responsiveness over simplest operation, not a requirement the goals impose — a cold reader deserves to know the goals forgave five seconds of lag and we chose not to.

**On tenets:** this decision is taken *against* the permissiveness of "self-hosted and managed infrastructure are both permitted" — nothing forbade the hosted route, it lost on cost and coupling. I named that explicitly, plus the two tenets the choice now has to live up to, which are where the change store's reliable-publication obligation and the browser's visible-disconnect obligation actually come from.

I left the polled-fallback question unsettled in the doc rather than deciding it for you — Selection says so in one line, since a reader seeing "polling rejected" would otherwise assume polling is gone entirely.

Still open from the last stop, unchanged:

1. **Capacity-saturation tenet** — refuse new connections and keep subscribed browsers fresh, or admit everyone and let fan-out fall behind for all? The decision doc names capacity policy as delivery's job but takes no position on which way it leans.
2. **HTTPS fallback in scope?** My default is socket-only for the pilot; it's your risk call, and it changes two of the three nodes.
3. **The stale lines in `access-design.md`** — refresh now, or wait until delivery tells us what it needs from access?

Answer those and I'll move to Phase 2 on the three nodes. If you'd rather read the doc first and reply after, that works too.