**Phase 1 — HLD check (complete).**

Coherence pre-flight: `docs/high-level-design.md`, `docs/intent/previews/*`, and `docs/intent/review-api/*` are mutually consistent for the preview segment; no EARS spec asserts a specific eviction policy, so nothing drifts. Note there is no source tree or test suite in this repo yet — the change lands as design intent only.

Changed `docs/high-level-design.md:14`:

> - Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache that evicts with 2Q, keeping first-use sheets separate from reused sheets so that long sequential screenings do not evict the comparison sheets an editor is working with.

The policy choice does not change the preview interface, the render queue, or the review API, so it stays inside the preview segment: I will record it as a Decisions & Alternatives row in `previews-design.md` (a standalone decision doc would be over-documenting a segment-local choice). Phase 2 will also have to settle one thing your sketch compressed — whether "2Q" here means classic 2Q with a ghost list of recently evicted first-use keys, or a two-queue approximation — since reuse detection after eviction depends on it.

Two things I need from you before Phase 2:

1. Does the HLD wording above read correctly to you, or should the 2Q mention live only in the previews LLD?
2. Tenet candidate for the HLD — add it or not, and does it lean the right way?

   - *Protect the working set over minimal bookkeeping.* When cache retention competes with bookkeeping effort, prefer protecting the editor's working set even at the cost of extra per-entry state.
   - Defensible opposite: prefer the cheapest policy that adapts fastest when editors switch projects.