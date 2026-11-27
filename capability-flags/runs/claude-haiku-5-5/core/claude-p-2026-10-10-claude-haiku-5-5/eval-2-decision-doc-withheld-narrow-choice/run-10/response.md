**Phase 1 (HLD check) is done. Stopping here for your review.**

**HLD check:** The architecture is unchanged. 2Q is internal to the preview worker, so the review API contract, the 200/202/404 outcomes, the 12 GiB budget, and the four-job render queue all stay as they are. The one stale line was in `docs/high-level-design.md`: "Its eviction policy remains open." I deleted that sentence. The HLD should not carry a status note, and the policy now belongs to the previews design. No other HLD text changed.

**Coherence pre-flight:** The previews and review-api specs trace to their design docs. The repo has no tests or code yet, so the test-trace check has nothing to check against.

**Decision recording:** 2Q affects only the previews node, so I'd record it as a row in the previews design's Decisions & Alternatives table in Phase 2, not as a separate decision doc. I won't offer a doc for it.

**One thing to settle before Phase 2:** 2Q as you described it has two queues, but the classic algorithm also keeps a ghost list of recently evicted keys (metadata only, no JPEG bytes). That list is what lets a re-requested sheet get promoted into the main queue. I'd use the classic starting split:
- probation queue: 25% of the 12 GiB budget
- main queue: 75%
- ghost list: keys for up to 50% as many entries as the cache holds

Should I write the design with those values as starting points to tune later from pilot measurements, or do you want different numbers? Once you approve Phase 1 (or answer that question), I'll move to Phase 2 and draft the previews design around 2Q.