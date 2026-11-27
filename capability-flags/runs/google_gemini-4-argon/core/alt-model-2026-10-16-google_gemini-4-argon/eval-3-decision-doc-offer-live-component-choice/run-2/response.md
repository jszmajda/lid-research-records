I have updated `docs/intent/record-store/record-store-design.md` (and marked `record-store` as `Drafted` in `docs/high-level-design.md`) to complete the Phase 2 LLD around **whole-visit revisions**.

### Summary of Updated `record-store` LLD (`docs/intent/record-store/record-store-design.md`)

1. **Revision Model & Active Head Set**:
   - Every accepted worker submission or coordinator resolution is stored as an immutable **Revision** (`revision_id`, `visit_id`, `parent_revision_ids`, `source_type`, `author_id`, `idempotency_key`, `received_at`, and `payload`).
   - A visit's **active head set** consists of all revisions for that `visit_id` not referenced in any later revision's `parent_revision_ids`.
   - **Single head (`status: current`)**: The sole head revision is the authoritative current visit and is eligible for Friday CSV export.
   - **Multiple heads (`status: needs_review`)**: Competing head revisions await coordinator review; `current_revision` is `null`, and the visit is held out of export.
   - **Linear vs. Forking transitions**:
     - Initial creation (`base_revision_id: null` on a new `visit_id`) creates a single root revision (`current`).
     - An edit whose `base_revision_id` matches the sole active head advances the head linearly (`current`).
     - An edit whose `base_revision_id` points to an already-superseded revision (or arrives while the visit already has multiple heads, or arrives with `base_revision_id: null` for an existing `visit_id`) creates a competing head and puts the visit in `needs_review`.

2. **Operations & Contracts**:
   - `POST /visits/{visit_id}/revisions`: Validates worker auth, plot reference (`site-catalog`), and payload structure; enforces idempotency (`200 OK` on identical replay, `409 Conflict` on key reuse with different payload/parameters, `422` on unknown `base_revision_id`); returns `status`, `accepted_revision_id`, `current_revision_id`, and `competing_revision_ids`.
   - `GET /visits/{visit_id}`: Returns `status: current` with `current_revision`, or `status: needs_review` with `current_revision: null` and `competing_revisions`.
   - `GET /visits`: Lists visits filtered by `status` (`current` | `needs_review`) and `updated_since` for `tablet-sync` and `review-export`.
   - `GET /visits/{visit_id}/revisions`: Returns the full immutable revision history in chronological order (`received_at`, tie-broken by `revision_id`).
   - `POST /visits/{visit_id}/resolutions`: Records a `coordinator_resolution` revision whose `parent_revision_ids` equals `resolved_revision_ids`, collapsing the active head set to a single head (`status: current`).

3. **Downstream Obligations**:
   - `tablet-sync` tracks the latest synced `revision_id` as `base_revision_id` for offline edits and surfaces `needs_review` outcomes.
   - `review-export` queries `needs_review` visits for revision comparison/resolution and exports only `current` visits to the Friday CSV.

---

### Decision Doc Offer

Because the choice between **whole-visit revisions** and **field-aware three-way merge** trades competing criteria (scientific cross-field integrity and operational simplicity vs. review queue volume) and sizes both downstream nodes (`tablet-sync` and `review-export`), a cold reader could be tempted to revisit it later:
- Would you like me to record a standalone decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md` (linked from the LLD's Decisions & Alternatives table), or keep the table row in `record-store-design.md` as sufficient?

---

### Phase 2 LLD Edge-Case Probe

Please let me know how you want to handle these edge cases (fix in the LLD now vs. defer as open questions):

1. **New worker submission arriving during coordinator review (`POST /visits/{visit_id}/resolutions`)**:
   - *Current draft*: Requires `resolved_revision_ids` to match the entire current active head set (rejecting with `409 Conflict` if a third revision $R_4$ arrived while the coordinator was reviewing $\{R_2, R_3\}$, forcing the coordinator to inspect $R_4$ before resolving).
   - *Alternative*: Allow partial resolution where resolving $\{R_2, R_3\}$ creates $R_{\text{res}}$ and leaves the active head set as $\{R_{\text{res}}, R_4\}$ (`status: needs_review`).
2. **Changing `plot_id` across revisions of an existing visit**:
   - If a worker realizes they recorded a visit under the wrong plot, can a subsequent revision change `plot_id` for the same `visit_id`, or must `plot_id` remain immutable once a `visit_id` is created?
3. **Concurrent edits with identical payloads**:
   - If two workers start from the same `base_revision_id` and independently submit byte-identical `payload` values (with different `idempotency_key`s and `author_id`s), should the store still create two competing heads (`needs_review`) to preserve both author attributions in review, or auto-coalesce them?
4. **Archived plots on new vs. existing visits**:
   - `site-catalog` notes that archived plots are excluded from the default new-visit picker but retained for historical lookup. Should `record-store` accept revisions referencing an archived `plot_id` (since an offline tablet may have captured the visit before archival), or restrict archived plots to edits of existing visits only?
5. **Payload validation boundaries**:
   - The draft specifies `observers` is non-empty and each `species_cover` entry has unique `species_code` within a revision and `cover_pct` in `0..100` (allowing sum > 100% across species for canopy layering). Can `species_cover` be empty (`[]`) for a barren/wrack-only plot, and should future `observation_date` values be rejected?

 *(Note: `docs/intent/site-catalog/site-catalog-design.md` line 24 also has a one-line reference noting that `tablet-sync` behavior "remains pending that choice"; let me know if you'd like me to update that line across the segment boundary as well.)*

Once you confirm your preferences on the decision doc and the edge-case items above, we will finalize the LLD and move to **Phase 3 (EARS specs)** for `record-store`.