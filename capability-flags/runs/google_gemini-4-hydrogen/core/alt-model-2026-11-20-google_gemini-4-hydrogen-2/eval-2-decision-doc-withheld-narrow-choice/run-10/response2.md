I'd recommend **keeping it as a `Decisions & Alternatives` row** rather than writing a full decision doc.

Under LID's earns-its-place test, the bar looks forward from the landed design, not back at how long the debate ran:

- **It affects only its own node.** Cache queues and replacement metadata stay private to the preview worker; `review-api`, the HTTP contract, the render queue, and the 12 GiB budget don't depend on this choice, and no other nodes are sized around it.
- **One row settles it for a cold reader.** A future maintainer only needs to know *why 2Q over LRU and aged LFU* (protecting comparison sheets from sequential scans without counter-aging lag on project switches), which the `Decisions & Alternatives` row already captures.

If you still want a full decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md` (for example, if you expect the team to re-litigate this during the pilot), I can write one. Otherwise, let me know how you'd like to triage the Phase 2 probe items (1–10) and whether you approve `previews-design.md` to move to **Phase 3 (EARS specs)**.