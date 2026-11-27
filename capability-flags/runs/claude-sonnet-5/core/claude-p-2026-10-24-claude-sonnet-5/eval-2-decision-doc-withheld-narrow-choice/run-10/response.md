I've updated the Previews LLD with the 2Q decision and resolved the open question in the HLD's one-line reference to it.

**Changes made** (`docs/intent/previews/previews-design.md`):
- Private Cache section now specifies 2Q mechanics: A1in (FIFO, first-touch), A1out (ghost list, keys only), Am (LRU, reused sheets), with eviction always draining A1in before Am.
- Added a Decisions & Alternatives row recording the choice, the two rejected alternatives, and the "long sequential screening must not evict actively-compared sheets" rationale.
- Added the size-split as a Deferred open question (starting point: A1in ~¼ of the 12 GiB budget, Am the remainder, A1out sized comparably to A1in — tune against pilot traffic).
- Updated `docs/high-level-design.md`'s one reference from "eviction policy remains open" to "evicted with a 2Q policy."

**Decision doc offer.** This choice was contested across three meetings and a 180-message thread, trades credible options against more than one criterion (bookkeeping cost, scan-resistance, retention lag), and the queue-size split is a parameter other work will size around. That clears the bar for a full decision doc rather than just the LLD table row I already added. Want one recorded at `docs/intent/previews/decisions/`, or is the table row enough?

**Edge-case probe on the new 2Q section** — gaps a blind reader flagged that this LLD doesn't yet settle:
1. When A1out (ghost list) is full, which key gets dropped — oldest-first?
2. On an A1out hit, is the ghost entry retired immediately, and does the sheet enter Am at the MRU end?
3. What happens if one sheet's size alone exceeds A1in's quota (or the full 12 GiB) — does eviction reach into Am, or is the sheet rejected?
4. Is the A1in/Am split a hard per-admission ceiling, or a soft target drifted toward?
5. If a sheet in A1in is re-requested at the same moment eviction has selected it, which wins — promotion or eviction?
6. When a hit pulls a sheet out of A1in into Am, do the remaining A1in entries keep their original FIFO order?
7. Once eviction reaches Am, is it strict LRU, and what breaks a tie on identical last-access time?

Which of these should get settled in the LLD now, and which should I defer as open questions?