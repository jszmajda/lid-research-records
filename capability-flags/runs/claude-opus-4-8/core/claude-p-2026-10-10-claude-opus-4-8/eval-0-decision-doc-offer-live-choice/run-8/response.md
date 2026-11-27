Done — the HLD now commits to self-hosted WebSockets. This is a Phase 1 (HLD) change; per your note I've **stopped here and not touched the three nodes**. Here's what changed in `docs/high-level-design.md`, for your review:

**Approach** — rewrote the open three-way choice into the committed route: browsers receive committed changes over self-hosted WebSocket connections; the change store keeps replayable revisions + a commit-to-broadcast publication path; delivery owns the socket sessions; browser sync owns subscribe/reconnect/catch-up. Added the explicit tradeoff line (owning the socket tier buys vendor independence at the cost of connection/reconnect ops). I also **removed** the old sentence "Neither operating cost nor minimum operational burden has been declared the overriding criterion" — your pick resolves that criterion, so leaving it would contradict the decision.

**Architecture** — the change-store / delivery / browser-sync bullets now describe socket-specific responsibilities instead of "depending on the approach."

**Key Design Decisions** — added an entry recording the choice context-free (chosen route, the accepted cost, and the two rejected options with their one-line tradeoffs).

Two things for you to rule on:

1. **Decision doc?** This choice stays live for a cold reader — three credible options traded across latency, cost, vendor coupling, and ops burden, and the three nodes are about to be sized around it. I've recorded it as a Key Design Decisions entry for now; I can **upgrade it to a full decision doc** at `docs/decisions/` (context, criteria, the three options, selection) if you'd like the deeper record. Your call — the entry is the lighter alternative.

2. **A tenet for the lean?** Your rationale ("fast updates without tying the board to a realtime vendor, accepting the extra ops") reads as a forward-leaning preference, not just this one decision — something like *"Prefer owning the realtime path over coupling to a realtime vendor, even at added connection/reconnect cost."* It passes the defensible-opposite test. I did **not** add it, since tenets are yours to set, and it sits alongside the existing "self-hosted and managed infrastructure are both permitted" tenet (which I left as-is). Want me to add it, or leave the tenets unchanged?

Once you've reviewed the HLD and answered those, we can move to the three nodes (Phase 2 LLDs for change-store, delivery, and browser-sync).