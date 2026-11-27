Phase 2 is drafted around 2Q. Here's the stop.

## What changed

**`docs/intent/previews/previews-design.md`** — the open-policy paragraph is gone, replaced by an `## Eviction` section that pins 2Q in the project's own terms: a **first-use queue** (FIFO, bounded share of the 12 GiB), a **reuse queue** (LRU, the remainder), and a **recently-evicted key list** (keys only, not bytes). Promotion evidence is the *second miss* on a key, not a second resident hit — a screening long enough to overflow the first-use queue evicts a comparison sheet before its next request, so resident-hit promotion would never fire for exactly the sheets you're buying 2Q to protect. A hit inside the first-use queue deliberately does nothing.

A `## Decisions & Alternatives` table now carries two rows: the policy choice (2Q over LRU and aged frequency counts, with the bookkeeping named as accepted cost) and the promotion-evidence choice. I did **not** offer a decision doc — the policy is sealed inside the previews node, no sibling node gets sized around it, and the HLD already states nothing else consumes eviction metadata, so a row carries it. The three meetings don't change that test; the blast radius does.

**`docs/high-level-design.md`** — one clause: "Its eviction policy remains open" → "with its own eviction policy." Flagging it because it's an upstream edit, not a cascade — revert it if you'd rather the HLD stay silent.

## Edge probe

A blind reader, given only the previews design and specs and none of this conversation, found ten gaps. The ones I think are real, grouped:

1. **Admission under concurrency** — four render jobs can each measure the cache, evict to fit, and link in, blowing past 12 GiB by up to three sheets. PREVIEW-004 asserts the bound; nothing in the design makes it hold. I'd pin admission as serialized.
2. **An inconsistency I introduced** — §Private Cache says "evict enough to remain within that bound" (counts the incoming sheet) while §Eviction says "exceeds / is still over" (counts only resident bytes). PREVIEW-004's "would exceed" settles it in favor of the former; I'd fix the §Eviction wording to match rather than ask you to re-rule.
3. **Is the reuse queue's share a ceiling or just the leftover?** After a comparison-only stretch the first-use queue may be near-empty — does the reuse queue expand into the full 12 GiB, or stay capped so screening churn always has its share to absorb? This one changes what your tuning parameter actually means, and it's a retention preference rather than a technical fork.
4. **Key-list mechanics** — what happens on recording a key when the list is full, whether a key can appear twice, and whether keys ever expire. With no expiry, a sheet re-requested days later still gets promoted.
5. **Successful jobs' dedup entries** — the design only says *failed* jobs release theirs. A sharer polling after the sheet was already re-evicted is unspecified.
6. **Eviction vs. an in-flight 200** — nothing says whether a sheet being served can be deleted under the reader.
7. Lower-value: what exactly is measured against 12 GiB (JPEG bytes vs. on-disk size), a sheet larger than the first-use share, restart rebuild ordering, and whether a resident first-use hit is remembered as evidence at eviction time.

Two parameters I left in Open Questions rather than inventing: the first-use queue's **share of the 12 GiB** and the **key list's bound**. The pilot's traffic is the evidence for both, and guessing them in the doc would make a tuning knob look like a design decision.

## What I need from you

**(a)** On the probe list — which do you want fixed in the LLD now, and which deferred? My recommendation: I fix 1, 2, 4, 5 and 6 in-place (they're mechanics, and two implementers would otherwise disagree), defer 7, and get your ruling on 3.

**(b)** On #3 specifically, since it's yours and not mine: should the reuse queue be **capped** at the remainder, so a screening's churn is always confined to the first-use share — or **elastic**, free to grow into the whole budget when screening traffic is light, accepting that a screening starting from that state will push against comparison sheets before the first-use queue refills? Capped is the stricter reading of "protect the comparison sheets during big screenings"; elastic gets you more comparison sheets resident on quiet days.

**(c)** Should I put a starting value for the first-use share in the doc anyway, so implementation has something to run against, or leave both parameters open until pilot traffic exists?

Say the word and I'll apply (a), then move to Phase 3 — PREVIEW-004 needs company: the current specs say nothing about queue placement, promotion, or eviction order, so 2Q is currently design-only with no spec line holding it.