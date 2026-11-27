Phase 2 LLD draft is done. Here's where it stands, for your review before I cascade into EARS specs.

## What I changed (`docs/intent/previews/previews-design.md`)

I rewrote the open "eviction policy" paragraph into a concrete **2Q** design and recorded the choice. The fixed contract, render-queue concurrency, and 12 GiB budget are untouched, as all three sketches promised. New **Eviction: 2Q** section, in short:

- **Recent queue** — FIFO, first-use sheets, holds bytes, bounded by a *recent share* of the 12 GiB.
- **Hot queue** — LRU, protected reused sheets, holds bytes, gets the rest of the 12 GiB.
- **Ghost queue** — keys only (no bytes, so it doesn't count against 12 GiB), records sheets recently evicted from the recent queue.
- **Promotion is only via the ghost queue**: a sheet reaches the hot queue only when it's requested *again after* aging out of the recent queue. A second touch while still in the recent queue does **not** promote it — that's precisely what lets a screening pass fail to protect its one-shot sheets.
- **Eviction**: recent queue over its share → evict its FIFO head to the ghost; else evict hot-queue LRU and discard. Ghost over its bound → drop oldest key.

I recorded 2Q (vs. LRU and frequency-with-aging) as a **Decisions & Alternatives row**, not a standalone decision doc. The policy is private to the preview worker and sizes no other node — LID reserves decision docs for choices that stay live across the system, and "affects only its own node" means a row regardless of how long the debate ran. The row preserves the full LRU/frequency tradeoff so a cold reader sees why 2Q won.

## Edge-case probe — two things I need from you

The size split you flagged is genuinely open; I deferred both tunables as Open Questions rather than guess them in:

1. **Recent share** — the recent queue's byte budget before its head is evicted ahead of the hot queue. Classic 2Q uses ~25% (≈3 GiB here). Set a starting value, or leave it deferred to implementation with 25% as the documented default?
2. **Ghost-queue key count** — how many evicted keys we remember; this is the window in which a re-request still earns promotion. Keys are tiny so the cost is bookkeeping, not bytes. Tie a default to the ~6,000 expected cached sheets (e.g. ~3,000 keys ≈ half), or leave deferred?

And one behavior I resolved in the draft that's worth a conscious confirm, since it's the crux of the whole choice:

3. **No promotion on a repeat touch while a sheet is still in the recent queue** — a clip revisited twice inside one screening pass stays unprotected until it's been evicted once and then requested again. This is standard 2Q and is what buys the scan resistance you're paying for, but it means a *very* short comparison burst (revisit before first eviction) gets no protection. Confirm that's the intended behavior.

## One upstream note

The HLD (`docs/high-level-design.md`) still says the previews node's "eviction policy remains open." That's now stale. I left it untouched rather than edit the root silently — I'd suggest changing that clause to drop the "remains open" wording (the HLD deliberately keeps the policy private to the worker, so it needn't name 2Q). OK to make that one-line edit?

Once you've set 1–3 and ruled on the HLD line, I'll move to Phase 3 (EARS updates — PREVIEW-004 stays policy-agnostic, but the placement/promotion/eviction-ordering rules will want new spec lines).