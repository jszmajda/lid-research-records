Written: `docs/decisions/self-hosted-websockets-delivery.md`, linked from the HLD's Key Design Decisions row. It lays out the three options with their honest trade-offs, six decision elements (including the capacity risk at peak that cuts *against* our choice), and a Selection that names the tenet it turns on — so a new reader can re-run the judgment, not just see the outcome.

Still open from my last message, when you're ready:

1. **Freshness goal** — keep "within 15 seconds" as the floor, or tighten it (e.g., subsecond) now that we push?
2. **Stale line** in `docs/intent/access/access-design.md:10` ("the still-open change-delivery approach") — may I clean that up?

Then we walk the three nodes — change store, delivery, browser sync — starting with the change store LLD.