2Q is now written into the previews design (Phase 2, LLD). I've stopped here for your review; no specs, tests, or code yet.

## What changed

- **`docs/intent/previews/previews-design.md`, Private Cache.** The "policy is still open" paragraph is replaced with the 2Q mechanism:
  - **Probationary queue:** a FIFO of freshly rendered sheets that haven't yet been served from cache.
  - **Protected queue:** an LRU of sheets that have been served from cache at least once.
  - **Promotion:** a cache hit on a probationary sheet moves it to the protected queue.
  - **Eviction:** it takes from the probationary head while that queue is over its target share, otherwise from the protected LRU end.
  - **Privacy:** all bookkeeping stays private to the preview worker. The API, render queue, and disk budget are untouched.
- **Decisions & Alternatives table (new).** It has two rows: the policy choice with LRU and aged-frequency as the rejected alternatives, and what counts as "reuse".
- **`docs/high-level-design.md`.** The Previews line said the eviction policy "remains open"; it now says it uses 2Q replacement. The review-api node needs no change, since it already treats eviction as invisible.

I did not offer a standalone decision doc. The choice affects only the preview worker, so a table row covers it.

## Questions for you

1. **Reuse = a served cache hit.** I wrote that only a request served from cache promotes a sheet. Requests that merely receive the shared pending ticket don't count, so one editor's retry loop can't promote a sheet. Is that right?
2. **Promote on the first re-hit.** A probationary sheet moves to protected the first time it is served from cache. Classic 2Q instead keeps a ghost list of evicted keys and promotes only on a hit after eviction. It guards harder against scans but adds a third structure. I chose the simpler two-queue form, matching your option text. Which do you want?
3. **Probationary share.** The design says the value is configurable and private, but not what it is. Classic 2Q uses about 25% of the budget (~3 GiB, roughly 1,500 sheets). Should I record 25% as the starting value, or leave it deferred to pilot tuning?
4. **Restart behavior.** After a worker restart with sheets already on disk, should queue order be rebuilt (e.g. by file access time) or reset with everything treated as probationary? I listed this under Deferred.

## Edge-case probe

These are gaps in this LLD that I did not settle. Please triage which to fix in the LLD and which to defer:

- A completed render for a key that is already resident, for example after a renderer-version race.
- A sheet that is larger than the probationary share on its own.
- Superseded renderer-version sheets that are never hit again. They would sit in the protected queue until they age out of the LRU end.
- Whether the protected queue needs a floor or cap so it cannot starve probationary admission entirely.
- A failed render admits nothing and touches neither queue. I believe that is already implied, but it is not written down.

Once you've ruled on these, I'll draft the EARS specs (Phase 3).