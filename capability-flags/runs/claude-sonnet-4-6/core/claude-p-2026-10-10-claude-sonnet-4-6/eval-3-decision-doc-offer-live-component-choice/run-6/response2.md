Here's the updated LLD. The main additions from the previous draft:

**Decisions table — field-aware merge entry** now explains the genuine appeal of the alternative: most real corrections are to independent fields (observer name typos, a missed species entry), so merge rules would clear the majority of conflicts automatically and keep the Friday queue manageable. The reason it loses is that domain-complete merge rules are not achievable — scientific relationships between observation date, species identifications, and cover estimates are things the system cannot know, and a combined record that no worker actually submitted is harder to defend to the science partner than a longer queue. The entry closes with "revisit if queue volume proves operationally unsustainable," because that condition genuinely changes the calculus.

**Downstream Obligations section** now makes the contract explicit for both nodes:

- *Tablet-sync*: persist revision_id locally per visit, update it on acceptance, surface visit_state to the worker after each submission, and use the idempotency_key for retries rather than re-deriving anything.
- *Review-export*: drive work from the unresolved queue, present competing payloads side-by-side via the revision-history endpoint, provide a resolution UI, exclude unresolved visits from the export set with a visible count, and distinguish coordinator-resolved visits from never-competed ones for the science partner's audit trail.

This is the Phase 2 stop. Does this LLD read right to you before we move on to the EARS specs?