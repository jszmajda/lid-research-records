I recommend **keeping it as a row in `previews-design.md`'s Decisions & Alternatives table** rather than writing a standalone decision doc:

1. **Scope is local to `previews`**: Both the HLD and `review-api` are explicitly isolated from the worker's cache paths and replacement bookkeeping, so no other design node is sized around 2Q.
2. **A table row settles it for a cold reader**: A decision doc is for choices that stay live across the system—not for how long the debate took. A future reader seeing 2Q in `previews-design.md` gets the full "why" from the single table row (protecting comparison sheets from sequential screenings at the cost of extra queues and a tunable split).

If you still want a full decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md` despite the extra artifact to maintain, I can write it. Otherwise, let me know how you'd like to triage the 11 edge-case items above and whether we're good to move on to **Phase 3** (updating `previews-specs.md`).