Decision doc written: `docs/intent/record-store/decisions/whole-visit-revisions.md`, linked from the LLD's Decisions & Alternatives row. It records:

- **Context and stakes** — the two ways the choice can go wrong: silently losing an observation, or overflowing the coordinators' review queue.
- **Decision elements** — the inherited gate (no submitted edit discarded, which eliminated last-write-wins) and weighted criteria (review workload; preservation/inspectability; correctness of automatic combination; implementation burden; offline cost), with the tenets each derives from named.
- **Both options in their strongest honest form** — whole-visit revisions and field-aware three-way merge, each analyzed per element with the concrete observer-correction/added-species example.
- **Selection**, including **why the field-aware approach stays worth considering** and the trigger to revisit it (a review backlog the coordinators can't clear before export), plus the exact **downstream obligations** for tablet-sync (retain base revision IDs, submit full snapshots naming the base, handle a returned `contested` state without assuming its edit became current) and review-export (comparison against the common ancestor, contested-visit review queue, export only `resolved` visits, preserve resolution provenance).

Two things still need your ruling before I draft the EARS updates (Phase 3):

1. **Resolution scope** — the LLD has a coordinator *select* one competing revision. Do you also want coordinators able to author a combined revision, or is select-only the intent?
2. The edge-case gaps from the last message are still unanswered — most consequentially: after a resolution, should a submission based on a `closed`/`superseded` revision reopen the visit as contested (my current design), and should byte-identical competing revisions collapse or both enter the queue?

Confirm or adjust those (and flag any others you want changed), and approve, and I'll move to Phase 3 — the EARS updates in `record-store-specs.md`.