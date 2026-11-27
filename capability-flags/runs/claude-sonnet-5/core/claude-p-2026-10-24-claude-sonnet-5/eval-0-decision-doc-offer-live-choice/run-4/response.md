Updated `docs/high-level-design.md`:

- **Approach**: replaced the open three-way choice with the committed one — self-hosted WebSockets, server pushes committed revisions directly to connected browsers, trading vendor fees/coupling for owned connection capacity and reconnect handling.
- **Architecture**: updated the change-store, delivery, and browser-sync bullets to reflect this — replayable revisions + reliable publication, socket session management, and reconnect/catch-up logic, respectively.
- **Key Design Decisions**: added a row for the choice, with the rejected alternatives and why.

One thing before I stop for your review: this choice has real tradeoffs you weighed (latency vs. ops burden vs. vendor coupling) and three downstream nodes (change-store, delivery, browser-sync) are about to be sized around it — that's the bar where this skill offers a full standalone decision doc instead of just the HLD row I added. Want one, or is the row enough?