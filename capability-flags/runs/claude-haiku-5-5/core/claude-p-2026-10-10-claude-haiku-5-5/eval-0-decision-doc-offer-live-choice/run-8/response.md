The HLD now records self-hosted WebSockets as the delivery approach. I edited `docs/high-level-design.md` in place and did not commit. The three nodes (change store, delivery, browser sync) are not written yet, as you asked.

**Changes**

- **Approach:** Replaced the open-options paragraphs. Committed changes reach browsers over self-hosted WebSockets. The change store keeps replayable revisions and publishes each committed revision reliably. Delivery manages socket sessions and fan-out. Browsers track their last applied revision, reconnect with backoff, and catch up from it. The project owns connection capacity and reconnect operations as ongoing work.
- **Architecture:** The change store, delivery, and browser-sync entries now state what each owns under this approach. They are still marked "Not written yet."
- **Key Design Decisions:** Added a row for the choice. It names the polling and hosted-service alternatives and why they were not chosen, and it states the accepted cost.

Tenets, Goals, and Non-Goals are unchanged. The existing access node is still consistent with this approach: subscription credentials are already assigned to delivery.

**Decisions for you**

1. **Decision doc:** This choice trades cost, operational burden, latency, and coupling, and the three nodes will be sized around it. Do you want it recorded as a decision doc in `docs/decisions/`, with the Key Design Decisions entry as the alternative? I have not written one.
2. **Latency goal:** The Goals section still says committed changes show within 15 seconds. Do you want that tightened to subsecond now that the approach is sockets? I left it alone because it is your target to set.

Reply with your answers and the next step: I'll write the three nodes starting with the change store, one at a time for review.