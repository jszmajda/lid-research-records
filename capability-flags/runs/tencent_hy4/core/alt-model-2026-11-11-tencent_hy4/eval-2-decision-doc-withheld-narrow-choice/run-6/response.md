Coherence pre-flight: clean. The HLD, `previews` LLD, `PREVIEW-*` specs, and `REVIEW-*` specs are mutually consistent — the policy is "open" in both HLD and LLD, `PREVIEW-004` is policy-agnostic, and the review API is independent of eviction. No drift to fix before starting.

Phase 1 (HLD check): settling the replacement policy does not alter architecture. It stays private to the preview worker (HLD tenet), with the fixed HTTP interface, FIFO queue, and 12 GiB budget unchanged. No functional change to the HLD or any cross-segment cascade into `review-api` is implied, so I made no upstream or sibling edits.

I recorded the settled choice as a **Decisions & Alternatives row**, not a standalone decision doc. The doc test is applied to the landed design, not the debate: this choice is confined to one node's private bookkeeping and no other design node is sized around it, so a cold reader has no live re-litigation to reconstruct — a row settles it. (A long argument is a symptom, not the test.) I wrote the LLD as a fresh author: no narration of last session, the meetings, or the thread; the rejected alternatives and rationale sit in the table, not as body-prose asides.

Here is the Phase 2 output in full — the revised `docs/intent/previews/previews-design.md`:

```markdown
---
parent: high-level-design
prefix: PREVIEW
---

# Previews Design

## Context

The worker renders one JPEG contact sheet per clip revision and renderer version. Long sequential screenings introduce many one-use sheets; comparison sessions repeatedly revisit a smaller working set of clips. The replacement policy separates first-use sheets from reused sheets so a screening scan cannot displace the comparison sheets editors return to repeatedly.

## Architecture

Expose `GET /internal/previews/{clip-id}/{revision}` with three outcomes: 200 and JPEG bytes, 202 and a job ticket with a two-second retry interval, or 404 for an unknown revision. This contract is fixed regardless of how the cache admits and evicts entries.

Use a FIFO render queue with at most four active rendering jobs. Cache entries and all replacement-policy metadata belong exclusively to this worker. Other nodes do not access files, pin previews, inspect policy counters, or depend on entries remaining warm.

## Rendering and Deduplication

Resolve the immutable source revision before rendering. The cache key includes clip ID, revision, and renderer version. Concurrent misses for one key share a job ticket. Once rendering completes, subsequent requests can receive the JPEG directly. Failed jobs are removed from the deduplication map so a later request can retry.

## Private Cache

Cached JPEG data may occupy at most 12 GiB. Before admitting a completed sheet, evict enough existing sheets to remain within that bound. Temporary render output is kept separately and removed on completion or failure. Eviction never deletes source footage or changes job-ticket semantics.

## Replacement Policy (2Q)

The cache maintains two queues over the same 12 GiB byte budget: a probationary queue for sheets seen once, and a protected queue for sheets that have been reused. A first admission enters the probationary queue; a sheet that is reused is promoted to the protected queue. One-off admissions from a sequential screening therefore contend for the probationary queue rather than displacing the comparison sheets editors revisit. Admission, promotion, and eviction are private to the worker; the fixed HTTP interface, job-ticket behavior, and render-queue concurrency are unaffected. The size split, the precise promotion trigger, and the eviction/demotion order are recorded under Open Questions.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Cache replacement policy | 2Q: a probationary queue for first-use sheets and a protected queue for reused sheets, promoting a sheet on reuse | LRU; frequency-based eviction with aging | Editors alternate long sequential screenings with repeated comparisons of a small set of clips. 2Q keeps one-off screening sheets out of the protected queue, so comparison sheets survive a large screening; this is worth the extra bookkeeping of a second queue and a size split. LRU lets a sequential scan evict useful comparison sheets. Aged frequency counts add counter maintenance and can retain clips from a project that is no longer active. |

## Open Questions & Future Decisions

### Deferred

1. Size split between the probationary and protected queues against the 12 GiB byte budget.
2. Precise promotion trigger — which reuse events move a sheet from the probationary to the protected queue.
3. Eviction order when the byte budget must be freed, and whether a sheet evicted from the protected queue is demoted to the probationary queue or removed.
4. Whether keys of evicted sheets are tracked to admit a returning sheet directly to the protected queue.

## References

- High-Level Design: `docs/high-level-design.md`
- EARS: `previews-specs.md`
```

LLD-level edge-case probe (gaps inside this LLD, "what happens when"):

1. What happens when a completed sheet is admitted but the probationary queue alone already holds the 12 GiB budget — does promotion fail, or is the protected queue's share shrunk?
2. What happens when a single contact sheet is larger than the probationary queue's share of the budget?
3. What happens when a probationary sheet is requested again while its original render job's deduplication entry is still live?
4. What happens to a sheet's queue membership when its render job fails after the entry was admitted?
5. What happens when the protected queue is full and reused sheets keep arriving — which protected sheet is evicted, and does it retain reuse history?
6. What happens when a request hits the unknown-revision (404) path — is any queue entry created or touched?
7. What happens on a worker restart — is queue membership rebuilt from cached files, or does the cache start cold?

Judgment items I'm surfacing rather than settling:

- **Unsettled 2Q parameters / spec forks.** The size split, promotion trigger, eviction/demotion order, and ghost-key handling are genuine forks that admit more than one reading. You flagged the size split as something to tune, so I left all of them as Deferred open questions rather than baking in values. Per LID I won't draft tests or specs against either reading until you rule; "ready to stop arguing" doesn't let go of these — only you hold the latent intent.
- **Cross-node contradiction.** `docs/high-level-design.md:14` still says of the previews node "Its eviction policy remains open." That line is now stale against the finalized LLD. I did not edit the HLD (this change doesn't alter architecture), and I'm not silently elevating 2Q into it — the policy stays private per the tenet. I'd propose removing that residue clause and leaving the architecture description as-is. Confirm, or tell me your preference.

This is the mandatory Phase 2 review stop. Please reply with:

1. **Approval or numbered feedback** on the LLD draft above (context-free wording, Decisions row, 2Q mechanism).
2. **Triage of the 7 probe gaps** — which to fix in the LLD now, which to defer as open questions.
3. **A ruling on the Deferred 2Q parameters** — pin values now or defer to tuning (and if pinned, the values).
4. **A decision on the stale HLD line** (remove the "remains open" clause / leave / other).

On your approval I'll move to Phase 3 (the corresponding EARS specs for 2Q) and continue the cascade within the previews segment in the same session. I haven't touched specs, tests, HLD, or `review-api` yet.