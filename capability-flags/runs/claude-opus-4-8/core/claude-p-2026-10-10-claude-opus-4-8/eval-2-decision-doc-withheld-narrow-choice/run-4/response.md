Phase 2 probe is back. Here's where the previews LLD stands and what I need from you before Phase 3 (EARS).

## Done: sized the previews LLD around 2Q

`docs/intent/previews/previews-design.md` now has an **Eviction: 2Q** section describing the three structures — **A1in** (FIFO, first-use), **Am** (LRU, reused), **A1out** (ghost keys only, no bytes) — the admission/eviction rule, and the tunable **Kin** (A1in's byte share) / **Kout** (ghost-key count) split you signed up to tune. The external interface, four-job queue concurrency, and 12 GiB budget are untouched, as all three options promised. I recorded 2Q (vs. LRU and aged-frequency) as a **Decisions & Alternatives** row and left the Kin/Kout starting values as a Deferred open question.

## Decision doc — offering once

This choice clears the bar for a full decision doc: three credible options traded against scan-resistance, bookkeeping cost, and project-switch adaptation, with the LLD now sized around the result — a cold reader would reasonably ask "why 2Q and not LRU?" and be tempted to reverse it given the extra bookkeeping. Want me to write `docs/intent/previews/decisions/cache-eviction-policy.md` and link it from the Decisions row? The row I already added is the lighter alternative if you'd rather not.

## Phase 2 edge probe — please triage (fix now vs. defer)

A blind probe of the 2Q internals surfaced these forks. My recommended resolutions:

1. **First-use arrival must never evict the working set.** My drafted "otherwise evict Am's LRU tail" has a hole: if A1in is under Kin but the total is over budget (Am full), admitting a one-pass scan sheet would shrink the protected Am set — the exact thing 2Q exists to prevent. **Recommend:** admitting a first-use sheet evicts only from A1in (its tail → ghost); Am shrinks only to grow A1in's share, never to admit a first-use sheet. Fix in LLD now.
2. **Count the incoming sheet's size, and define the loop against the 12 GiB total, not just the per-queue Kin condition.** Recommend: evict until the arrival fits within 12 GiB, choosing the victim queue by the Kin split. Fix now.
3. **Concurrency.** Four renders can complete at once against shared lists. **Recommend:** serialize admission+eviction in one critical section, evaluate A1out membership atomically at admission, and have failed renders touch neither the budget nor the lists (bytes reserved only on successful admission). This also settles the "ghost dropped mid-render" and "pending co-request served the new Am entry" cases. Fix now.
4. **Repeated hits on a still-resident A1in sheet never promote it to Am** (strict 2Q — promotion needs the evict→ghost→re-render cycle). This is intended, but it has a real intent consequence worth your call: an editor who revisits the *same* sheet many times in a comparison session, without it ever being evicted, keeps it only in FIFO A1in, so a long scan can still push it out despite repeated views. Accept that, or do you want an in-place A1in hit to promote to Am? **This one is yours to decide** — it's the narrower-latent-intent question.
5. **Oversized single sheet larger than Kin's share** (only possible if Kin is set small). Recommend: defer with the Kin/Kout values, with a one-line note that a single entry may exceed its queue's share. Defer.
6. **Worker restart / cold start.** Recommend: the three lists are in-memory and start empty on restart (cache warms from scratch); no persistence claim. Confirm or defer.

## One cross-boundary flag

The HLD still says the previews node's "eviction policy remains open" (`docs/high-level-design.md`, Architecture). That's now stale, but it's the root doc — above this segment — so I won't edit it silently. May I drop that clause? The specific policy stays private to the worker per your "replacement bookkeeping private" tenet, so the HLD wouldn't name 2Q either way.

**Stopping here for review.** Tell me: the decision-doc call, your triage on 1–6 (especially #4), and the HLD clause — then I'll fold the resolutions into the LLD and move to the EARS specs.