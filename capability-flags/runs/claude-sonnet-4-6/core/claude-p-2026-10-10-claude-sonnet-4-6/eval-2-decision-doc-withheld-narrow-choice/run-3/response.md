Here is the Phase 1 output — the updated HLD — for your review before I proceed to the LLD.

---

**Phase 1 — HLD update**

The single changed line, in context:

```
## Architecture

- Review API: `docs/intent/review-api/review-api-design.md`, with
  `docs/intent/review-api/review-api-specs.md`. Owns project authorization
  and the public request boundary.
- Previews: `docs/intent/previews/previews-design.md`, with
  `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs,
  and a private 12 GiB cache. Uses a 2Q replacement policy to protect
  reused comparison sheets from eviction during long sequential screenings.
```

Everything else in the HLD is unchanged. The 2Q choice is internal to the preview worker (satisfies the "keep cache paths and replacement bookkeeping private" tenet), so no tenet or goal lines needed updating.

**Decision doc?** The three-options debate is real, but this choice affects only the previews node — per the decision-doc guidance, a Decisions & Alternatives row in the LLD is the right home, not a standalone doc. I'll record it there in Phase 2.

Does this read correctly? Once you approve I'll move to Phase 2 — drafting the 2Q mechanics into the LLD.