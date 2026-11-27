Done. Created a full decision doc at `docs/decisions/delivery-approach.md` and linked it from the HLD's Key Design Decisions. The doc follows the template structure:

- **Context** — the delivery requirements and three contending options
- **Gates** — no vendor lock-in (eliminates hosted service), 15s freshness, 800 browsers/20 edits/sec
- **Weighted criteria** — operational simplicity (moderate), latency headroom (moderate), connection visibility (major, from tenet), cost predictability (moderate), recovery robustness (major)
- **Three options analyzed** — each with description, per-element verdict (passes/eliminated, strong/partial/weak), and summary
- **Selection** — explains why self-hosted WebSockets wins on the two major criteria (connection visibility from the tenet, latency headroom), accepts the ops work as bounded, and names the downstream implications for the three nodes

A cold reader can reconstruct the judgment from this doc alone. Ready for Phase 2: draft the three leaf LLDs (change-store, delivery, browser-sync) now that the approach is fixed. Want me to proceed?