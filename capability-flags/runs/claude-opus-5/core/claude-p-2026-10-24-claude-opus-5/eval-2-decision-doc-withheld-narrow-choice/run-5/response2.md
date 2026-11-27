My honest read: no, and the length of the argument is the reason it feels like it should rather than a reason it should.

The test I'd apply is forward-looking from where this lands, not backward from how hard it was to settle. Three things point away from a doc:

- **It affects only its own node.** All three candidates kept their changes inside the preview cache — no external interface, no queue concurrency, no disk budget, nothing the review API can see. A decision doc exists so other parts of the system can be sized around a choice that stays live across them. Nothing else is sized around this one.
- **The row already carries the machinery.** The Decisions & Alternatives row names both rejected options, the criterion that killed each (LRU loses to the sequential scan; aged counters cost per-entry maintenance and lag a project switch), and the cost we accepted. A cold reader asking "why not just LRU?" gets the answer in a line.
- **It reads as native once it lands.** Screening passes are a scan over more sheets than the cache holds; the policy that confines a scan is 2Q. A fresh reader of the finished design is more likely to find that obvious than to want to reverse it.

What I think the three meetings are actually asking to be protected is a different thing: the **3 GiB share and 3,000-key ledger**. Those are my proposals, not measured, and they're the part a maintainer might genuinely re-run — if the pilot shows the mix is mostly one-use, the tuning question reopens even though the policy doesn't. That's held by Deferred #3 and by the soft-share row, and I'd rather strengthen those than write a doc about a settled policy.

If you disagree, this is your call and I'll write it — a doc on the eviction policy at `docs/intent/previews/decisions/eviction-policy.md`, gates and weighted criteria with the three options at full strength, and the row rewritten to link it. Say the word and it's the next thing I do.

Otherwise, where we left off: apply probe fixes 1–6, your call on 7 (oversize first-use sheet) and 8 (renderer version bump) plus restart behavior, and whether I touch the HLD's "eviction policy remains open" line.