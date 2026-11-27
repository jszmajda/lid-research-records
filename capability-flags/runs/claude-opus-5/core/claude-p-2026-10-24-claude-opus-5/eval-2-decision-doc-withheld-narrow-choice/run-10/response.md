Phase 2 (LLD) is drafted against the 2Q selection. Stopping here for your review.

## What changed

**`docs/intent/previews/previews-design.md`** — new `## Replacement Policy` section: A1in (FIFO of first-use sheets, a hit serves without reordering), A1out (evicted keys only, no bytes, so it stays off the 12 GiB budget), Am (LRU of reused sheets). Admission promotes to Am when the key is in A1out, otherwise to A1in's head. Eviction takes A1in's tail (recording the key in A1out) while A1in is over its share, otherwise Am's LRU end. Context section rewritten: it now states the screening-vs-comparison workload as the thing the policy must handle, rather than leaving the policy open.

**Decisions & Alternatives** — four rows: the policy choice itself (2Q, with LRU and aged-frequency as the alternatives and the accepted bookkeeping cost named), no promotion on an A1in hit, A1out holding keys only, and Am evictions not being recorded in A1out. The last three are the sub-choices a cold reader would otherwise be tempted to "fix" in the direction that reintroduces scan vulnerability. This is recorded as table rows rather than a decision doc — every option's effect stops inside the preview worker, so there's no sibling node sized around the result.

**`docs/high-level-design.md`** — one line: Previews "owns rendering, pending jobs, and a private 12 GiB cache, including its replacement policy." The old line said the eviction policy remains open. Architecture, tenets and goals are untouched.

## Edge-case probe

I delegated the probe to a subagent given only the previews docs. It came back with 18 gaps; these are the ones that would change what gets built, and I did **not** resolve any of them:

1. **What the eviction loop is making room against** — the global 12 GiB bound, or the destination queue's own budget. These pick different victims for the same arrival, and they decide whether an Am admission can evict A1in entries at all. Related: is A1in's share a hard cap, or only a trigger that lets A1in sprawl while Am is underfilled? And is Am capped at the complement, or does it get whatever A1in isn't using?
2. **Which end of Am a promoted sheet enters** — MRU (fresh reuse credit) or LRU (immediate candidate). The doc only specifies where a *hit* moves it.
3. **When the A1out membership test is evaluated** — at request time, or at render completion. A long render can age the key out of A1out in between, so the completion-time reading drops a genuine reuse into A1in.
4. **Renderer-version rollover** — keys include renderer version, so after an upgrade every old sheet is unreachable but still occupying the 12 GiB budget and A1out slots. Nothing invalidates them.
5. **Eviction racing a read, and concurrent admissions** — four render jobs each running evict-then-admit with no stated serialization can both see room and overshoot the bound PREVIEW-004 asserts; and nothing pins an entry while its bytes are being served.

Lower-priority, deferrable: A1out's overflow drop, a single sheet larger than A1in's budget, policy state after a worker restart, whether temp render output counts against the bound, and render-queue saturation during a screening (that last one predates 2Q).

## What I need from you

- **Triage the five above** — into the LLD now, or deferred as open questions? My suggestion, if you want to approve in one line: answer 1–3 in the LLD (global bound, Am admits at MRU, test at request time), fold 4 and 5 in as invariants, defer the rest.
- **The two tuning parameters** are open questions in the doc, not decisions. The published 2Q defaults are A1in at ~25% of capacity (~1,500 sheets at 2 MiB) and A1out holding keys for ~50% of capacity (~3,000 keys). Confirm those as the pilot's starting values, or name your own — A1out's size is what decides whether an editor returning to a sheet after a long screening is recognized as reuse.

On approval I'll move to Phase 3 and update the PREVIEW specs; PREVIEW-004 is the one that changes, plus new lines for the queue transitions.