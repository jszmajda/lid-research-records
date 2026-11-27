I recommend keeping this as the `Decisions & Alternatives` row in `previews-design.md` rather than writing a standalone decision doc.

Two reasons:

1. **Test from the landed system looking forward, not the debate looking back.** Three meetings and a 180-message thread are a symptom of how hard it was to reach consensus, not of what a future cold reader needs. Once landed, a decision doc isn't a record of the argument—it's machinery for a reader who would otherwise re-litigate a choice that the rest of the architecture leans on.
2. **The blast radius is strictly inside `previews`.** By explicit HLD tenet and the fixed `200` / `202` / `404` HTTP contract, neither `review-api` nor any other component is sized around 2Q, reads replacement state, or changes if the policy ever changes. A cold reader opening `previews-design.md` *will* wonder "why two queues instead of plain LRU or aged frequency?", and the table row right below `Private Cache` already answers that directly without adding another file to keep coherent with the LLD.

The one reason to write `docs/intent/previews/decisions/cache-eviction-policy.md` anyway is if you expect pilot workloads to force re-running this exact judgment later and want explicit weighted criteria (e.g., comparison-set retention vs. project-switch recovery vs. bookkeeping cost) preserved so the team doesn't start that 180-message thread from scratch.

My lean is to let the table row carry it—if you want the standalone doc under `docs/intent/previews/decisions/` anyway, say the word and I'll draft it and link it from the row. Whenever you're ready, let me know your call on that and how you'd like to triage the Phase 2 edge cases above.