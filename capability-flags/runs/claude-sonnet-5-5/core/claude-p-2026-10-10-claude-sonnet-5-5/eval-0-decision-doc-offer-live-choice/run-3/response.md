I updated the Approach in `docs/high-level-design.md` to self-hosted WebSockets. This is the Phase 1 stop, so nothing downstream has been touched.

**What changed**
- **Approach:**
  - The "still open" framing is replaced with the chosen route: committed changes reach browsers over self-hosted WebSockets that we operate.
  - The 15-second target is described as a ceiling, with sockets delivering much faster.
  - The three-way consequences paragraph now states the cascade: the change store keeps replayable revisions and publishes reliably, delivery owns sessions and connection capacity, and browser sync reconnects and catches up from its last seen revision.
- **Architecture bullets:** the change-store, delivery, and browser-sync entries no longer say "depends on the approach". Each now states what it owns under the socket design.
- **Key Design Decisions:** one new row records the choice. It names the polling and hosted-service alternatives and the ops-for-no-vendor-coupling trade-off.

**Decisions for you**
1. **Decision doc:** the row above may be enough, or you can have a full decision doc at `docs/decisions/`. This choice traded several criteria, and three nodes are about to be sized around it, so a cold reader might want to re-run the judgment. I'd write the doc only if you want it; the row alone is the lighter option.
2. **Tenet:** your reasoning has a defensible opposite, namely that vendor independence outweighs minimum operational burden when the two conflict. Would you like that recorded as a one-line tenet? The existing tenet "Self-hosted and managed infrastructure are both permitted" is still true, so I left it alone.
3. **Stale wording in `access-design.md`:** its Context says authorization is independent of the "still-open change-delivery approach", and its Architecture says delivery subscription credentials "will belong to the delivery node". That is a separate segment, so I haven't edited it. May I update that wording, or leave it for later?

**Check against the HLD yourself:** nothing in the HLD blocks this choice. Please read the 800-browser and 20-edits-per-second goals against the socket design. Delivery's connection capacity will have to be sized to meet them, and that sizing is the thing to hold the delivery LLD to.

Please give numbered feedback or approve. On approval, I'll move to the three nodes, starting with the Phase 2 LLD for the change store, then delivery, then browser sync.