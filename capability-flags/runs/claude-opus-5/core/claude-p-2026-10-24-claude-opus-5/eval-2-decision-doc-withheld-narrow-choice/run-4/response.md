**Phase 1 — HLD check**

Coherence pre-flight on the previews segment first: the five `PREVIEW-*` specs trace to the current previews LLD, the LLD matches the HLD's architecture (fixed internal HTTP contract, FIFO queue capped at four jobs, cache private to the worker), and there are no tests or code yet — so nothing downstream is stale. No drift to repair before starting.

Choosing 2Q does not alter the architecture. The HLD already places eviction entirely inside the previews node ("No other node reads cache files, pins entries, or consumes eviction metadata"), and 2Q keeps it there — two queues and a size split are replacement bookkeeping, which the tenet says stays private to the worker. So the HLD keeps its structure; two lines in it were written *while* the policy was open and go stale now:

```diff
 ## Architecture
-- Previews: … Owns rendering, pending jobs, and a private 12 GiB cache. Its eviction policy remains open.
+- Previews: … Owns rendering, pending jobs, and a private 12 GiB cache, including the choice of replacement policy for that cache.

 ## Goals
-- Return a ready preview or a pending response through the same interface for every eviction policy.
+- Return a ready preview or a pending response through the same interface, whatever replacement policy the cache uses.
```

The first records where the decision lives rather than that it is pending; the second keeps the real constraint (the request interface must not expose the policy) without reading as a note about an open question. No tenet or goal changes otherwise — nothing in 2Q pushes against "a cache miss is ordinary behavior" or the 12 GiB bound.

One thing I settled without asking, so you can see it and overrule: how the 2Q choice gets recorded. Despite the three meetings, this choice lands entirely inside one node — every option left the preview API, the render queue, the disk budget and the 202 protocol untouched, and no other design node gets sized around the result. That is the case the skill says not to offer a decision doc for, however long the debate ran. So it goes in as a Decisions & Alternatives row in the previews LLD, naming LRU and aged-frequency as the alternatives and scan resistance during big screenings as the reason — not a standalone decision doc.

Approve this HLD sync and I'll move to Phase 2: write the 2Q design into the previews LLD (the two queues, what the size split controls, and the fact that it needs tuning as a deferred open question), add that Decisions row, then run the LLD-level edge-case probe and bring you its gap list.