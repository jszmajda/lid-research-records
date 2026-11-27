The edge-case probe on the 2Q section came back. Nine genuine gaps, worth triaging before this LLD is settled — I'm presenting them for you to pick which land in the design vs. get deferred as open questions:

1. **Re-admission after eviction** — does a re-requested evicted sheet restart at `A1in`, or keep any memory of prior `Am` membership?
2. **`Am` overflow** — if `A1in` is empty/exhausted and `Am` is at its split but the incoming sheet still doesn't fit, what happens? The doc never caps `Am`'s own ceiling.
3. **Hard quota vs. preference** — is the capacity split a hard per-queue limit, or just eviction-order preference (so `Am` could balloon to the full 12 GiB if `A1in` stays small)?
4. **In-flight entries** — does a sheet still rendering (pending job ticket, not yet admitted) have any queue membership, or is it implicitly exempt from eviction until completion?
5. **Concurrent promotion race** — two simultaneous requests hitting an `A1in` entry: is promotion to `Am` idempotent, or can double-promotion/lost-signal bugs occur?
6. **What counts as "access"** — does a request served while rendering (resolved via job ticket) count toward promotion, or only a hit against an already-completed JPEG?
7. **Intra-`Am` ordering** — once promoted, does a 3rd/4th access reorder within `Am` (LRU-style), or is `Am`'s internal eviction order unspecified?
8. **Renderer-version churn** — do old-renderer-version entries for the same clip/revision interact with new ones in the queues at all, or are they just independent keys that age out normally?
9. **Multi-entry eviction** — if the incoming sheet is bigger than any single evictable `A1in` entry, does the policy evict several in one pass, and in what order?

Which of these need an answer in the LLD now, and which should go to the Open Questions / Deferred list instead? (My instinct: 1, 3, 4, 6, and 7 are load-bearing enough to settle now since they shape the spec and tests we're about to write; 2, 5, 8, 9 feel like safe deferrals — but it's your call.)