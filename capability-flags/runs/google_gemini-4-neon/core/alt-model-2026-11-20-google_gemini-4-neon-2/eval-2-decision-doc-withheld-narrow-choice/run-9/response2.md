I'd keep this as the **Decisions & Alternatives** table row rather than adding a standalone decision doc.

The bar for a decision doc is forward-looking from the landed design, not how long the debate ran: *will a cold reader re-litigate the choice without full options and weighted criteria, and are other design nodes sized around it?* Here:

- **Blast radius is local to `previews`.** The HTTP contract, render queue, 12 GiB cap, and `review-api` are all unaffected—no other node leans on 2Q or its metadata, and swapping the policy later if pilot workloads shift stays inside the preview worker.
- **One line settles "why 2Q?"** A future reader wondering why 2Q was chosen over LRU or aged frequency gets the core trade directly from the table row: protecting reused comparison sheets during sequential screenings without the project-switch lag of aged frequency counters.

That said, it's your call—if you expect future maintainers to genuinely re-litigate 2Q vs. LRU vs. aged frequency unless the full criteria and trade-offs are captured, say the word and I'll write `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from the table row. Otherwise, let me know how you'd like to triage the Phase 2 probe items and whether we're good to move to Phase 3 (`previews-specs.md`).