**Phase 1 — HLD check (complete). Review this before I go further.**

Project is LID-configured (`CLAUDE.md`: Mode Full, v1.4.0); `docs/intent/` and `docs/high-level-design.md` exist; no `docs/arrows/` overlay, so no arrow-maintenance work is in scope. The HLD already covered the change's domain, but two lines were stale now that a policy is chosen.

Changes made to `docs/high-level-design.md`:
- `docs/high-level-design.md:14` — the Previews architecture line no longer says "Its eviction policy remains open"; it now states the cache replaces entries with 2Q (FIFO queue of recently admitted sheets + LRU queue of repeatedly reused sheets, tunable split), so a long sequential screening doesn't evict the comparison sheets an editor is working with.
- `docs/high-level-design.md:31` — the goal now reads "through the same interface regardless of cache eviction" rather than "for every eviction policy", since there is one policy now.
- `docs/high-level-design.md:23` — added tenet: *"Protect repeatedly reused work over minimizing the bookkeeping needed to track it."* This is the lean the 2Q choice turns on, and it gives the segment-level decision a root to cite.

Two things are yours to settle before Phase 2:

1. **Tenet wording.** I drafted that tenet from the trade you just made. Do you accept it as written, want it reworded, or would you rather it not live in the HLD? (It leans a class of decisions — retention-vs-bookkeeping, and how future editors treat eviction metadata — so it passes the platitude test, but it's your call.)

2. **Where the repo actually stands.** The repository contains only design documents — no source, no test runner, no `package.json`/`pyproject.toml`, nothing under `docs/` that tests could execute against. "Finish the preview design" therefore splits two ways: (a) design-only, meaning I carry Phases 2–4 (LLD revision → EARS specs → intent-narrowing edge audit) and the work ends with the spec set and no implementation; or (b) design plus greenfield implementation, meaning Phases 5–6 stand up a preview worker from scratch — which means choosing a language/runtime and test framework you have not specified, far beyond a cache-policy change. I recommend (a): the 2Q policy and its specs are the deliverable, and the worker implementation is a separate piece of work. Which do you want?

On the choice itself, I'll flag one item for Phase 2 so it's not a surprise: the 2Q "tunable split" needs a concrete value and a ghost-list (`A1out`) size, and those two parameters have genuinely different trade-offs — I'll sketch 2–3 options with their downstream consequences for you to select rather than picking one myself. Given the 2Q-vs-LRU choice was contested across three meetings, it also plausibly earns a decision doc under `docs/intent/previews/decisions/` so a future cold reader can re-run the judgment; I'll offer that explicitly at the Phase 2 stop.