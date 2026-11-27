Decision doc written to `docs/decisions/change-delivery-transport.md` (frontmatter `node: high-level-design`) and linked from the Key Design Decisions entry in the HLD.

What it records, cold-readable:

- **Context** — why the transport choice spans all three components and what's fixed (15 s freshness, 20-min recovery, 20 edits/s bursts, seven-day retention).
- **Decision Elements** — update latency (moderate), recurring cost (major), vendor dependence (major), operational burden (major), failure visibility (moderate, tied to the *connectivity failures must be visible* tenet), repeated-read load (minor).
- **Options in the Domain** — five-second polling, self-hosted WebSockets, and hosted realtime, each with a description and per-element verdicts.
- **Selection** — self-hosted WebSockets: ties hosted on latency and read efficiency, ties polling on cost and vendor independence, loses only on operational burden, which is the accepted cost. Turns on the failure-visibility tenet; taken deliberately against operational burden. Lists what it forecloses and what it obligates for change store, delivery, and browser sync.

Phase 1 is settled. Ready to start the three leaf LLDs — change store, delivery, browser sync — each with its own Phase 2 review? Say the word and I'll begin with the first, or name the order you want.