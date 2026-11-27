Done — the HLD now commits to self-hosted WebSockets. Here's what changed and one decision to make before we move on to the three nodes.

**`docs/high-level-design.md`**

1. **Approach** — rewritten to commit to self-hosted WebSockets: server holds a connection per browser and pushes each committed revision, no third-party realtime service. The second paragraph now states the settled shape (replayable store + reliable publication, delivery owns socket sessions, browser sync owns reconnect/catch-up, board owns its connection capacity) instead of hedging across three options.
2. **Architecture** — resolved the three "depends on the approach" node descriptions to their WebSocket consequences (change store = replayable + reliably published; delivery = socket sessions + publication; browser sync = subscription + reconnect + catch-up). All three stay marked "Not written yet."
3. **Key Design Decisions** — added a row naming both rejected alternatives (polling; hosted realtime) and why self-hosted sockets won (fast updates without a vendor bill, accepting connection/reconnect ops).

I wrote the prose as a fresh author committing to sockets today — no narration that the approach used to be open — and kept the rejected-alternatives rationale in the Decisions entry rather than the Approach body.

**One thing for you to decide — decision record depth.** This choice stays live for a cold reader: three credible options traded against latency, recurring cost, vendor coupling, and operational burden, and all three downstream nodes are about to be sized around it. I've recorded it as a Key Design Decisions row (above). Do you want me to also write a full **decision doc** (`docs/decisions/`) laying out the options and criteria at enough resolution to re-run the judgment, or is the row enough? My lean: the row is enough unless you expect this to get re-litigated.

I did **not** touch the tenets — "self-hosted and managed infrastructure are both permitted" still holds (self-hosting delivery is permitted under it; the store could still use managed infra). Say the word if you'd rather tighten it.

Phase 1 stop. Once you confirm the HLD and the decision-doc question, we'll take the three nodes — I'd suggest change-store first, since delivery and browser-sync both size against its revision/publication contract.