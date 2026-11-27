Written `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked it from `docs/intent/record-store/record-store-design.md`. It covers the decision elements, the full case for field-aware three-way merge (and when it would be reconsidered), and the downstream obligations for `tablet-sync` and `review-export`.

Before moving to Phase 3 (updating `docs/intent/record-store/record-store-specs.md`), please triage the Phase 2 edge-case probe items (which to address in `record-store-design.md` now vs. defer) and confirm approval of `record-store-design.md`:

1. Extending an active competing head (replace that head vs. add a parallel head)
2. Simultaneous per-visit requests (per-visit serialization / CAS invariant)
3. Resolution retry idempotency (`idempotency_key` on coordinator resolution)
4. Invalid resolution targets (missing visit, already `resolved`, `selected_revision_id` outside `contributing_revision_ids`)
5. Coordinator `mode: "author"` validation & `plot_id` immutability across revisions
6. Error payload schema and distinct status codes (`409` causes, auth, `404`, validation)
7. `idempotency_key` scoping per `author_id`, behavior after rejected requests, and payload equality canonicalization
8. New visit (`base_revision_id: null`) referencing an archived `plot_id`
9. `GET /visits/{visit_id}/history` deterministic ordering tie-breaker & resolution record schema
10. Field-level validation bounds (`species_cover` empty/ranges, `notes` optional/nullable)