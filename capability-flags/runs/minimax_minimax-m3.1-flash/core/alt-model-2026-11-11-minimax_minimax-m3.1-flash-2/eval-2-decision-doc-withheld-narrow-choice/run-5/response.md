**2Q is locked in.** Here's where the design now stands.

**What changed (Phases 1–3, `previews` segment):**

- `docs/high-level-design.md` — the "eviction policy remains open" line is now "It evicts with 2Q"; added the tenet *Reuse over recency*; the cache goal now reads "regardless of which entries the cache holds."
- `docs/intent/previews/previews-design.md` — 2Q specified in full: first-use queue, hot queue, key-only ghost list; per-key reference counting; two distinct eviction pressures (budget pressure spends screening sheets first; hot-cap pressure spends only the least-recently-used reused sheet); sizing table, invariants, Decisions & Alternatives table (LRU and frequency-with-aging recorded as rejected, with rationale), and three deferred items.
- `docs/intent/previews/previews-specs.md` — 24 new specs, PREVIEW-006 … PREVIEW-029.

**Consistency report:** three blind audits ran over the drafts and the specs were rewritten three times to close real defects — a genuine contradiction between the ghost route and the count threshold, an eviction-order conflict between the hot cap and the total budget, undefined "renderer version", and several scope leaks ("the system" vs "the preview worker"). A final pass is clean on contradictions, undefined terms, and coverage. `review-api` needed no cascade — it never sees eviction metadata.

**Warning:** your "go ahead and finish" was read as authorization to consolidate the Phase 1/2/3/4 stops into this one review. Say the word and I'll re-present them one at a time. Phases 5–6 (tests, code) can't run here — this repo is design docs only, with no worker code or test tooling.

**Your calls:**

1. **Sizing defaults** — hot queue cap 6 GiB (50% of budget), ghost list 50,000 keys. These are the "split we'll have to tune"; confirm the starting point or give me numbers.
2. **Reuse detection** — every request counts as a reference (including 202/pending tickets and requests sharing one render job), read at admission; a first-use eviction preserves the count in the ghost list, a hot eviction discards it. I settled this because "protect the comparison sheets" needs it, but it is a policy choice.
3. **Restart** — cached files re-admitted to the first-use queue, ghost list empty, nothing persisted.
4. **Decision doc** — the table row explains 2Q, but a cold reader may still "simplify" it back to LRU. Want a short `docs/intent/previews/decisions/2q-replacement-policy.md` memorializing the trade-off, so this stops coming back as a debate?
5. **Deferred, for later** — whether hot-queue evictions also leave a ghost entry, and whether counts survive a restart.