**Phase 1 — HLD check: complete.** Coherence pre-flight first: the five `PREVIEW-*` specs trace to the current previews LLD, the four `REVIEW-*` specs trace to the review-api LLD, and no code exists yet to test against — no drift found; the only stale statement was the HLD's open-policy note, which your 2Q selection resolves.

The 2Q selection doesn't alter the architecture (review API, worker, fixed HTTP interface, private cache all stand), so the HLD needed one change: the line flagging the eviction policy as open is now resolved. The decision itself is node-local — it stays inside the previews design, where I'll record it as a Decisions & Alternatives row in Phase 2 (rationale: 2Q protects reused comparison sheets from sequential screening scans at the cost of two queues and a tunable size split; LRU and aged-frequency alternatives trimmed for scan-vulnerability and counter/aging overhead respectively). It doesn't warrant a standalone decision doc: nothing outside the previews node sizes around it.

Updated HLD in full:

```markdown
# FrameDesk High-Level Design

## Problem

Twenty-four documentary editors review an archive of 90,000 clips, with approximately 6,000 distinct clips viewed each week. Contact sheets help them screen footage without downloading the original video. Editors alternate long sequential screenings with repeated comparisons of a small set of clips.

## Approach

An authenticated review API checks project membership and forwards preview requests to one internal preview worker. The worker renders contact sheets from immutable clip revisions and keeps a bounded private cache. A typical sheet is 2 MiB and takes about 450 ms to render; cache misses use a fixed pending-response protocol rather than blocking the review API.

## Architecture

- Review API: `docs/intent/review-api/review-api-design.md`, with `docs/intent/review-api/review-api-specs.md`. Owns project authorization and the public request boundary.
- Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache.

The review API accesses previews only through the fixed HTTP interface. No other node reads cache files, pins entries, or consumes eviction metadata.

## Tenets

- Never treat a cache as the authoritative copy of source footage.
- Key previews by immutable clip revision and renderer version.
- A cache miss is ordinary behavior, not an API failure.
- Keep cache paths and replacement bookkeeping private to the preview worker.

## Goals

- Support 24 active editors on one eight-core preview worker during the pilot.
- Limit cached JPEG data to 12 GiB.
- Deduplicate concurrent rendering requests for the same preview key.
- Return a ready preview or a pending response through the same interface for every eviction policy.

## Non-Goals

- Editing or transcoding original footage.
- Distributed cache coordination or multiple preview workers in the pilot.
- Promising that any particular clip remains cached.
```

One judgment call for you: your rationale — protect reused comparison sheets during big screenings over minimizing bookkeeping — could also serve as a project tenet under `## Tenets` (a lean for future cache-tuning choices no spec anticipates), or stay purely as the LLD decision row's rationale. I lean toward keeping it in the LLD row only, since it's cache-scoped rather than project-wide.

Please give numbered feedback on the HLD (including that tenet question) and explicit approval to proceed to Phase 2, where I'll rewrite the previews Private Cache section around 2Q and run the LLD-level edge-case probe.