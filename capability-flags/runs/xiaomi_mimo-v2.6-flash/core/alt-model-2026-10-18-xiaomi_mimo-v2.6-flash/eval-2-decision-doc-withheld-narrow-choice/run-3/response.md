**Phase 1 — HLD check: done. Stopping for your review.**

Coherence pre-flight (resuming last session's work): the HLD, the previews LLD, and `PREVIEW-001`–`005` agree with each other, but both design docs still record the eviction policy as an open question. The HLD was the only place with a now-false statement.

The HLD covers the domain of this change and 2Q does not alter the architecture — it fills the slot the architecture already carved out (a bounded, worker-private cache). So the update is two lines in `docs/high-level-design.md`:

```
- Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, a private 12 GiB cache, and its 2Q eviction policy.
```
*(was: "…and a private 12 GiB cache. Its eviction policy remains open.")*

```
- Return a ready preview or a pending response through the same interface, regardless of the cache's eviction policy.
```
*(was: "…for every eviction policy." — kept the policy-independence guarantee, dropped the phrasing that implied candidates were still being weighed.)*

Everything else in the HLD (Tenets, Goals, Non-Goals, Approach) still reads true with 2Q chosen. No new tenet: "protect reused sheets from screening scans" is a triggered requirement, so it belongs in EARS at Phase 3, not the tenet list.

Recording the choice itself: 2Q's substance lives entirely inside the preview cache — no sibling node changes — so it will land as a row in the previews LLD's Decisions & Alternatives table, not a standalone decision doc.

Approve Phase 1 and I'll move to Phase 2 (rewriting `previews-design.md` around 2Q, then the LLD-level edge-case probe). Or tell me what to change.