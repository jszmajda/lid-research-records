2Q is in. Here's the Phase 2 output.

## `previews-design.md` — revised

**New `## Eviction Policy` section.** Three private structures, named in our own terms rather than the paper's:

- **First-use queue** — FIFO, sheets admitted on their first render. A hit here serves but does not promote: a screening pass touching a sheet once, or twice in quick succession, isn't yet evidence of reuse.
- **Evicted-key ledger** — bounded FIFO of keys evicted from the first-use queue, keys only, no JPEG bytes.
- **Reuse queue** — LRU, sheets whose keys were in the ledger when re-requested. Reordered on every hit.

**Sizing:** 12 GiB total across both sheet-holding queues (hard); 3 GiB first-use share (soft — it steers which queue eviction draws from, not what may be admitted); 3,000-key ledger, outside the byte budget. At a typical 2 MiB sheet that's ~6,000 sheets, ~1,500 first-use, and a ledger remembering about half a cache of recent evictions. These three numbers are my proposals, not anything you settled — Deferred #3 holds them open for pilot measurement.

**Eviction order:** evict until the incoming sheet fits — first-use queue's oldest if that queue is over its share (key goes to the ledger), otherwise the reuse queue's LRU end (key discarded).

**Decisions & Alternatives** — four rows: the policy itself (LRU and aged-frequency named as rejected, with why), the promotion trigger, soft vs. hard share, and reference accounting. I did **not** offer a decision doc despite the length of the argument: every option kept its changes inside the preview cache, so a cold reader re-litigating it would be re-litigating one node's internals, and the rows carry what they'd need.

## Edge probe — gaps found

I had a subagent probe the draft cold (LLD-internal only). It found ten; four are mechanical, and I'd fix all of them in the doc with your nod:

1. **Eviction can fail to make progress.** If the first-use queue is at-or-under its share and the reuse queue is empty, step 2 has no candidate. Recommend: the share test only picks the *preferred* queue; eviction falls through to whichever queue has entries, and admission is refused if neither does.
2. **Ledger checked at request time or at admission time?** The draft reads both ways. Recommend request time — a 450 ms render shouldn't lose its promotion to a ledger overflow mid-flight.
3. **Admission ordering** — whether the incoming sheet's bytes count toward the share test before eviction runs. Recommend: classify first, evict before counting.
4. **Concurrent completions.** Four render jobs; the classify/evict/admit sequence needs to be stated as serialized, or two completions each evict for their own sheet and overshoot 12 GiB.
5. **"A reference is counted once per admission"** implies a per-entry counter that nothing reads. Recommend rewording to ledger-hit terms so nobody builds the counter.
6. **Ledger/residency disjointness** is implied but never stated as an invariant. Recommend stating it.

Two more I'd rather you called, because they trade against the thing you just bought:

7. **Oversize first-use sheet.** A sheet bigger than the 3 GiB share drains the first-use queue and then starts eating the comparison working set — the exact outcome 2Q is here to prevent. Real at 2 MiB sheets only if a sheet is pathological, but the rule is silent. Cap first-use admission size, or let it through and accept the rare bite?
8. **Renderer version bump.** Keys include renderer version, so every old key goes permanently unmatchable: dead sheets hold bytes until ordinary eviction reaches them, and dead ledger keys crowd out live ones — a version bump could starve promotions right when editors are re-requesting everything. Purge on version change, or let it drain naturally?

And **worker restart** sits in Deferred: queues and ledger are in memory, surviving cache files aren't. Re-admit survivors as first-use, re-admit as reuse, or discard the cache? Discarding is cleanest but costs a 450 ms re-render per sheet on the first comparison session after a deploy.

Finally, one thing crosses out of this segment: the HLD still says *"Its eviction policy remains open."* Want me to update that line, or leave the HLD alone this session?

Fastest path if you're done arguing: say "apply 1–6, leave 7/8/restart deferred, fix the HLD line" and I'll land it and move to Phase 3 specs.