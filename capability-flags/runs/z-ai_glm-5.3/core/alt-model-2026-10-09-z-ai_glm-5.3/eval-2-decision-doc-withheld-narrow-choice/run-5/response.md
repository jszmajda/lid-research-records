I updated the preview design to 2Q and refreshed the HLD summary.

**What’s now in `docs/intent/previews/previews-design.md`:**
- A **3 GiB first-use queue (FIFO)** and a **9 GiB reused queue (LRU)**, both private to the preview worker.
- New sheets enter the first-use queue; a later hit promotes them to the reused queue.
- Pending requests do not count as reuse.
- Corrupt or missing cache files re-render; oversized sheets are treated as render failures.
- The 25% / 75% split is recorded as a starting point, tunable later.

**LLD edge-case probe found these gaps:**
1. No bound or backpressure outcome for queued render jobs.
2. No terminal outcome for a client retrying a job that failed.
3. Oversized sheets may re-render and fail on every request.
4. The triggering client’s post-completion retry may count as the promoting hit, undermining the first-use queue.
5. Worker restart behavior for cached files, 2Q metadata, and outstanding tickets is unspecified.
6. No ordering rule for concurrent admissions, hits, and evictions.
7. A sheet can be admitted and evicted before the requester’s retry arrives.
8. A corrupt entry’s queue slot and byte accounting are not explicitly reclaimed.
9. “Eligible victim” is undefined, and self-eviction during promotion is unaddressed.
10. Temporary render output has no size bound.
11. Renderer-version changes during queued or in-flight jobs are unspecified.
12. Job-ticket contents and lifetime are unspecified.

Please tell me which of these to fix in the LLD now and which to defer. Once you approve the LLD, I’ll draft the corresponding EARS specs.