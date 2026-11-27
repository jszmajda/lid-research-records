Phase 1 (HLD) is updated. Here's what changed in `docs/high-level-design.md`, committing to self-hosted WebSockets:

**Approach** — dropped the "still open" framing and the open-criteria note; committed delivery to self-hosted WebSockets (server holds a persistent connection per browser, pushes revisions on commit, no realtime vendor). Rewrote the "designed together" paragraph to state the concrete obligations the choice creates: change store retains replayable revisions and publishes them reliably; delivery manages socket sessions and fan-out; browsers subscribe, detect disconnection, and catch up from last-seen revision. Kept the freshness stance (fast but subsecond not required).

**Architecture** — rewrote the three unwritten nodes from "depends on the approach" to their now-fixed roles: change store (revision history + replayable read model + publication outbox), delivery (socket sessions + fan-out), browser sync (WebSocket subscription + reconnect + catch-up).

**Key Design Decisions** — added an entry recording the choice and naming the two rejected alternatives (polling: repeated reads and lag; hosted service: fees and provider coupling) with the tradeoff you accepted.

Tenets are unchanged — they already cover this ("one authoritative event revision regardless of delivery route"; "self-hosted and managed infrastructure are both permitted"; "connectivity failures must be visible").

**One decision to make before we move on — how to record this choice.** I've recorded it as the Key Design Decisions entry above (the default). But this is a three-way architectural choice among credible options traded across several criteria — latency, operational burden, recurring cost, vendor coupling — and the three downstream nodes are about to be sized around it. That's the profile where a cold reader might later re-litigate "why self-host sockets rather than just poll, or pay for a hosted service?" So I can offer to upgrade it to a full **decision doc** at `docs/decisions/change-delivery.md`, laying out the options, criteria, and selection at enough resolution to re-run the judgment later.

- **(a)** Keep just the Key Design Decisions entry (what's there now).
- **(b)** Write the full decision doc and link it from that entry.

Which would you like? Once you confirm this HLD update (and the recording choice), we'll proceed to the three nodes — I'd suggest change-store, then delivery, then browser-sync, since each depends on the one before.