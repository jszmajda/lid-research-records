## Phase 1: HLD Review

Updated `docs/high-level-design.md` to make 2Q the selected private preview-cache eviction policy.

```markdown
# FrameDesk High-Level Design

## Problem

Twenty-four documentary editors review an archive of 90,000 clips, with approximately 6,000 distinct clips viewed each week. Contact sheets help them screen footage without downloading the original video. Editors alternate long sequential screenings with repeated comparisons of a small set of clips.

## Approach

An authenticated review API checks project membership and forwards preview requests to one internal preview worker. The worker renders contact sheets from immutable clip revisions and keeps a bounded private cache. A typical sheet is 2 MiB and takes about 450 ms to render; cache misses use a fixed pending-response protocol rather than blocking the review API.

## Architecture

- Review API: `docs/intent/review-api/review-api-design.md`, with `docs/intent/review-api/review-api-specs.md`. Owns project authorization and the public request boundary.
- Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache using 2Q eviction.

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

## Key Design Decisions

- **Use 2Q eviction in the private preview cache.** The cache separates first-use previews from previews that have been reused, so long sequential screenings do not displace the comparison sheets editors revisit. LRU was rejected because scans can evict those reused sheets. Frequency-based eviction with aging was rejected because maintaining and aging counters adds work while retaining prior-project favorites longer than needed. The additional queue bookkeeping and tunable size split stay entirely within the preview worker; the review API, pending-response protocol, render queue, and cache budget are unchanged.
```

Please approve this HLD revision to continue with the preview LLD.