My view: yes, it earns one. Applying the test from the landed state — a cold reader who sees "2Q" with its queues, ghosts, and split parameter would question it against plain LRU, and the choice turns on tradeoffs no option dominates (scan protection vs. bookkeeping vs. project-switch adaptation). The workload evidence and the deliberate acceptance of tuning cost are exactly the memory a future re-run of the judgment needs; a row would settle "why this?" but not "would we still choose it?". The one caution in the heuristic is that node-local choices usually get only a row — but you've asked, and by the landed-state test this clears the bar. Written to `docs/intent/previews/decisions/preview-cache-eviction-policy.md`:

````markdown
---
node: previews
---

# Decision: Preview cache eviction policy

## Context

The preview worker holds a bounded 12 GiB private cache of contact-sheet JPEGs — roughly 6,100 resident sheets at the typical 2 MiB size. Editors drive two access patterns: long sequential screenings, which introduce many sheets requested once, and repeated comparison sessions, which revisit a small working set over and over. Which entries a full cache surrenders therefore decides whether the comparison set survives a screening.

Replacement state belongs to the preview worker alone, the HTTP outcomes (200/202/404) and the render queue are fixed, and no policy may exceed the 12 GiB bound — every candidate satisfies all three, so none of them eliminates a candidate. A misjudged policy costs misses, not correctness: an evicted sheet re-renders and returns through the ordinary pending path. The decision is about which misses the editors feel.

## Decision Elements

- **major — Screening-scan resistance.** How much of a repeatedly-compared working set survives a long sequential screening of single-request sheets that runs to completion. The workload alternates these screenings with comparison sessions, so this is the failure mode to design against.
- **moderate — Replacement bookkeeping cost.** Per-request metadata work and resident state size, measured against ~6,100 entries.
- **moderate — Adaptation to a changed working set.** How quickly residency reflects a new comparison set after editors switch projects.
- **moderate — Retention of repeatedly used sheets.** Whether sheets with high reuse stay resident while temporarily unrequested.
- **minor — Tuning burden.** Parameters an operator must choose before the policy behaves sensibly.

## Options in the Domain

### LRU

**Description.** Evict the least recently used resident sheet. Replacement state is a single recency order — one list position or last-access stamp, updated on every hit.

**Analysis**

- Screening-scan resistance — **weak**: the scan touches every resident sheet and reorders all of them; the comparison set is displaced in scan order and misses once the screening passes it.
- Bookkeeping cost — **strong**: one order update per request.
- Adaptation — **strong**: a new comparison set is resident within roughly one working set of requests.
- Retention of reused sheets — **weak**: reuse counts only while it is also recent.
- Tuning burden — **strong**: no parameters.

**Summary.** Least machinery and fastest adaptation, paid for with the comparison set.

### Frequency-based eviction with aging

**Description.** Each resident sheet carries a hit count; counts decay on a periodic aging pass so historical popularity fades. Eviction takes the sheet with the lowest current count.

**Analysis**

- Screening-scan resistance — **strong**: single-request sheets accumulate the minimum count and become the first victims; high-count comparison sheets are held through the scan.
- Bookkeeping cost — **weak**: counter increments on every hit plus an aging sweep across resident entries.
- Adaptation — **weak**: decay takes several aging periods, so sheets popular yesterday linger after editors move to another project.
- Retention of reused sheets — **strong**: this is the count's direct purpose.
- Tuning burden — **partial**: the aging interval must be set.

**Summary.** Remembers what was loved; slow to forget.

### 2Q

**Description.** Two resident queues plus bounded ghost records. A sheet's first reference admits it to A1, a small FIFO for first-use entries. When an A1 entry is evicted, a ghost record remembers it; a later reference recognized through that ghost promotes the sheet into Am, the protected queue ordered by recency, where reused sheets live until other reused sheets displace them. Under admission pressure A1 cycles; Am yields only when reused sheets supersede reused sheets.

**Analysis**

- Screening-scan resistance — **strong**: screening sheets touch once, occupy A1, and cycle out without displacing Am, so the comparison set stays resident through the screening.
- Bookkeeping cost — **weak**: queue transfers on promotion, ghost records for evicted A1 entries, and two size bounds to maintain.
- Adaptation — **partial**: a new comparison set needs a second request before it earns Am residency, and the previous project's Am entries persist until superseded.
- Retention of reused sheets — **strong**: a second request is exactly the qualification.
- Tuning burden — **weak**: the A1/Am split and the ghost bounds must be chosen.

**Summary.** Scan protection bought with two queues, ghosts, and a split to tune.

## Selection

**2Q.** It wins the only major criterion, and the workload makes that criterion decisive: screenings are the traffic that would otherwise evict the comparison sheets editors return to. LRU's strong fits — bookkeeping, adaptation, no tuning — all serve a workload where recency predicts reuse; here recency is exactly what a scan corrupts. Frequency-with-aging matches 2Q on retention but is weak on adaptation and adds aging machinery on top of counter maintenance, which is the wrong trade when editors switch projects between screenings.

Committing to 2Q takes on its costs knowingly: more replacement state and code paths than LRU, all of it private to the preview worker, and an A1/Am split plus ghost bounds that the previews design must set and later retune. It forecloses zero-parameter operation. It commits nothing at the public interface — misses still surface as 202 tickets, and no policy promises any particular sheet stays cached.
````

A Decisions row in `previews-design.md` will link to this doc when I rewrite that section in Phase 2.

**STOP — Phase 1 still open.** Numbered feedback:

1. The decision doc above — approve as written, or revise (criteria weights, the option descriptions, the Selection)?
2. Still open from my last stop: add the HLD tenet *"Retention favors reused sheets over one-off screenings"*? Worth noting the decision doc's template flags a decision that cites no tenet — this one currently cites none, so the tenet would give its major criterion something to lean on.
3. Approve the two HLD edits from my last message (2Q named in Architecture; "independent of the cache eviction policy" in Goals)? If 1–3 pass, I proceed to Phase 2: rewriting the Previews "Private Cache" section around A1/Am/ghosts, with split defaults and an edge-case probe for your review.