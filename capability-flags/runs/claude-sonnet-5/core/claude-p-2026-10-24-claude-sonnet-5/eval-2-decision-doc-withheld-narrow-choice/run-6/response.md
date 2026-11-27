I've updated the previews LLD to reflect the 2Q decision (Phase 2 of the LID workflow). Here's what changed and what needs your review before I proceed:

**`docs/intent/previews/previews-design.md`** — Private Cache section now specifies 2Q concretely: new sheets enter `A1in` (FIFO), promote to `Am` (LRU) on a second request while still resident, and eviction always drains `A1in` before touching `Am` — so a long screening can't evict sheets comparison work is reusing. I set a default 25%/75% `A1in`/`Am` split (3 GiB / 9 GiB) and flagged it as a tunable parameter under Open Questions rather than treating it as settled, since no workload data yet justifies a specific number. I also added a Decisions & Alternatives row capturing why 2Q won over LRU and aged-frequency, for a cold reader later.

**`docs/high-level-design.md`** — synced the Previews line from "eviction policy remains open" to "evicted with a 2Q policy," since that line was now stale.

No EARS changes — PREVIEW-004 ("evict entries before admission so the cache remains within [12 GiB]") already covers this generically, and nothing external changes, consistent with your note that this stays inside the preview cache.

Two things from the LLD-level edge-case probe I should bring to you rather than settle myself:

1. **Hard partition or soft budget?** Should `A1in`'s 3 GiB cap be enforced even when `Am` is underfull (so a quiet comparison period still caps screening throughput at 3 GiB), or is the split just an eviction-order tiebreaker against the shared 12 GiB total, letting `A1in` borrow idle `Am` headroom? This changes actual eviction behavior, not just bookkeeping.
2. **No ghost queue (`A1out`).** I wrote the design as simplified 2Q — no tracking of recently-evicted keys, so a sheet evicted from `A1in` and re-requested later starts over in `A1in` rather than jumping straight to `Am`. That's simpler but means a sheet evicted just before a comparison session resumes won't get fast-tracked back into the protected queue. Worth the extra bookkeeping of a ghost list, or is simplified 2Q fine given today's "accept the extra bookkeeping" already covers two real queues?

Also offering, since this cleared three meetings and real tradeoffs across criteria: want this recorded as a full decision doc (`docs/intent/previews/decisions/`) instead of just the table row I added, so a future cold reader has the full option-by-option reasoning? Row-only is probably enough given how it reads once landed, but it's your call.