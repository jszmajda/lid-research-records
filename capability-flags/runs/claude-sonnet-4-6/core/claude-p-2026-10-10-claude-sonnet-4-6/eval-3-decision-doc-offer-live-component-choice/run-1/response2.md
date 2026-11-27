`docs/intent/record-store/decisions/concurrency-policy.md` is written and linked from the LLD.

The doc covers:

- **Context** — why this decision exists: two workers, same visit, server has no arrival-order authority.
- **Decision elements** — one gate (preserve every submission) and four weighted criteria. The major ones are review load (field-aware merge's strongest argument — genuinely significant at 6,000 visits/season with two coordinators) and merge rule correctness (whole-visit revisions' decisive argument — species ID and cover estimate are coupled fields the server can't detect as related). The moderate ones are audit integrity (tenet-grounded) and downstream implementation cost (what each policy asks of tablet-sync and review-export).
- **Options** — each described from its advocate's position, each criterion scored per option. Field-aware merge gets its strongest honest case, including the fact that the review-load concern is real and could warrant revisiting.
- **Selection** — names what the decision turns on (*Keep the path from a submitted observation to an exported value inspectable*), what it forecloses (auto-resolution of clearly unrelated edits), and the specific downstream obligations for tablet-sync (track and send `revision_id` as base, surface contested state to field workers) and review-export (revision comparison screen, export exclusion for contested visits, coordinator designation workflow).

Ready to move to Phase 4 — the intent-narrowing edge audit — whenever you're ready. That pass will probe cross-spec interactions and places where the specs as written admit more than one implementation reading.