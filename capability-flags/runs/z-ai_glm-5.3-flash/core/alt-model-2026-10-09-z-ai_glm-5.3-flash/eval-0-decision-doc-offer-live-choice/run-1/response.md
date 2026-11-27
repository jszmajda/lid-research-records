I've updated the HLD (`docs/high-level-design.md`) to land the self-hosted WebSockets choice:

- **Approach** — states the delivery route as decided: the server holds socket sessions and pushes each committed revision as it lands. It also names the three obligations the choice creates and which node owns each: replayable revisions + reliable publication (change store), socket session lifecycle (delivery), reconnect and catch-up (browser sync). The old "still open, three options" text is gone.
- **Architecture** — the three unwritten nodes now describe their WebSocket-shaped scope instead of "depends on the approach."
- **Key Design Decisions** — added the decision with the rejected alternatives and why: polling (read load at 800 browsers, seconds of lag, cursor queries either way) and hosted realtime (recurring fees, provider coupling on the core update path).
- **Goals** — left untouched. The 15-second freshness goal still stands as written; I described subsecond as practical, not required, since you haven't ratified a tighter target. Say the word if you want the goal tightened.

Two things for you at this stop:

1. **Decision doc offer.** This choice stays genuinely live for a cold reader — three credible options weighed against cost, latency, and operational burden, and the three remaining nodes are about to be sized around it. Want me to record it as a full decision doc in `docs/decisions/` (linked from the HLD row), or is the Key Design Decisions row sufficient?
2. **Cascade flag into the access segment.** `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach" — that's now stale residue. It's a small, clearly-implied cleanup; confirm and I'll make that one-line edit, or it can wait for the access segment's own review.

Once you've ruled on those, we move to Phase 2: drafting the change store, delivery, and browser sync LLDs — starting with which of the three you want first.