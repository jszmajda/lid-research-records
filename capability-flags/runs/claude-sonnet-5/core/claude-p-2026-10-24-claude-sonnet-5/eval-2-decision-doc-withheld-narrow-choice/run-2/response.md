I've drafted the Phase 2 LLD update for the preview cache's 2Q eviction policy. Here's what changed and what needs your review before I move to EARS.

**`docs/intent/previews/previews-design.md`** — added an "Eviction Policy: 2Q" subsection under Private Cache:
- **A1in** (FIFO, first-touch sheets, 3 GiB / 25% of budget), **Am** (LRU, reused sheets, 9 GiB / 75%), **A1out** (ghost list of keys evicted from A1in, capped at 10,000 keys, no bytes).
- Admission/promotion: new sheet → A1in tail; hit in A1in → promoted to Am tail; hit in Am → refreshed to Am tail; miss on a key found in A1out → admitted straight into Am (skips probation) and the ghost entry is cleared.
- Eviction: drain A1in head first (recording the key in A1out), fall back to Am head only once A1in is empty; Am evictions aren't ghosted.
- Added a **Decisions & Alternatives** row recording 2Q as chosen over LRU and frequency+aging, with your rationale (protecting comparison sheets during big screenings is worth the extra queues/ghost-list/size-split bookkeeping), and an **Open Questions → Deferred** item flagging the 25/75 split and the 10,000-key ghost cap as defaults to tune against real traffic.
- Also fixed the now-stale "Its eviction policy remains open" line in `docs/high-level-design.md` to say it uses 2Q.

All of this stayed inside the Previews LLD (plus that one-line HLD staleness fix), matching what you described.

**Decision doc?** This was contested across three meetings and a long thread, with real tradeoffs on more than one axis (bookkeeping cost vs. scan resistance vs. retention) and a parameter (the queue split) still open for tuning — the kind of choice a cold reader might reasonably re-litigate. Want a standalone decision doc under `docs/intent/previews/decisions/`, or is the Decisions-table row enough?

**Edge-case probe (delegated, blind to this conversation) found these gaps in the 2Q section — please triage which to resolve now vs. defer:**
1. What happens when a single sheet's size exceeds its queue's bound by itself (flagged as possible given variable sheet sizes)?
2. What happens when both queues are drained but the incoming sheet still doesn't fit?
3. What happens when a key already in A1in/Am is re-rendered (same clip/revision/renderer-version) — treated as a hit, or does it duplicate/overwrite?
4. Does rule 4's direct-to-Am admission run the budget check before or after, and could it evict the entry it just promoted?
5. Does a single A1in eviction suffice before checking the budget again, or does A1in drain fully before Am eviction ever triggers?
6. Are the 3/9/12 GiB bounds allowed to be transiently exceeded between evict and admit, or must they never cross even momentarily?
7. An entry evicted from Am (not ghosted) that's requested again — does it re-enter A1in from scratch, i.e. lose its "reused" status? Is that intended?
8. Can a key silently fall out of A1out (cap eviction) before being re-requested, reverting its future re-admission to probation instead of direct-to-Am?
9. Can A1out hold duplicate keys for the same cache key, or does a repeat ghost-insertion move/refresh the existing one?
10. If a key is in A1out while a render for it is already in flight (dedup ticket), is that a hit, a miss, or undefined against rule 4's "cache miss" framing?
11. What breaks ties for "head of Am" when multiple entries share identical recency (e.g., several admitted via rule 4 at once)?

Let me know which of these to settle now (I'll fold resolutions into the LLD) versus defer as open questions, and whether you want the decision doc. Once that's settled I'll treat Phase 2 as approved and move to the EARS update.