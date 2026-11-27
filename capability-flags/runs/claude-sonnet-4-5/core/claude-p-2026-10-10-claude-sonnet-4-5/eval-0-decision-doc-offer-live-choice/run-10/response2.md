**Decision doc created**

I've written `docs/decisions/realtime-delivery-approach.md` with the full tradeoff analysis:

**Structure:**

- **Context**: Why this decision matters — 800 browsers need fast updates, and the choice shapes three components (change store, delivery, browser sync).

- **Decision Elements**:
  - Gates: 800 browsers, 20-minute recovery, 15-second freshness (all three options pass)
  - Major criteria: update latency, vendor coupling, operational complexity
  - Moderate criteria: operating cost, implementation complexity

- **Three options analyzed**:
  - **Polling**: Simplest (strong on ops/implementation), but 5-10 second latency (partial fit)
  - **Self-hosted WebSockets**: Subsecond latency, zero vendor coupling (both strong), accepts connection management (partial on ops complexity)
  - **Hosted service**: Subsecond latency, minimal ops work, but weak on vendor coupling and introduces recurring costs

- **Selection**: WebSockets wins on vendor coupling (preserves flexibility) and latency (subsecond vs. 5-10 seconds). The decision turns on avoiding lock-in before the pilot's future is known, while still delivering fast updates. Accepts bounded operational complexity as the price of independence.

- **Implications**: Specifies what each component must handle (change store: replayable revisions; delivery: session lifecycle; browser sync: reconnect + catch-up).

The HLD now links to it from Key Design Decisions.

A cold reader can re-run the judgment if circumstances change — if operational complexity proves higher than estimated, or if multi-region needs later favor a managed platform. Ready to proceed with the three LLD drafts?