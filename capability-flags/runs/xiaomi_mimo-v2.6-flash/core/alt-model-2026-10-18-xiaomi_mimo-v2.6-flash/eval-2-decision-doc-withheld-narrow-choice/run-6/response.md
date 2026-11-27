**Phase 1 — HLD check (complete)**

Coherence pre-flight first: the existing specs trace to the previews LLD, the LLD traces to the HLD, and no tests exist yet to check. No drift found — the only stale line was the HLD's "eviction policy remains open" flag, now cleared by your selection.

Recording the choice: its substance lives in the previews LLD (only the preview worker is affected; the review API contract is policy-agnostic), so it will land as a Decisions & Alternatives **row** in `previews-design.md` at Phase 2 — not an HLD Key Design Decisions entry, and a full decision doc doesn't earn its place: one rationale line settles a cold reader's "why not LRU?" question.

Updated HLD in full:

```markdown
# FrameDesk High-Level Design

## Problem

Twenty-four documentary editors review an archive of 90,000 clips, with approximately 6,000 distinct clips viewed each week. Contact sheets help them screen footage without downloading the original video. Editors alternate long sequential screenings with repeated comparisons of a small set of clips.

## Approach

An authenticated review API checks project membership and forwards preview requests to one internal preview worker. The worker renders contact sheets from immutable clip revisions and keeps a bounded private cache. A typical sheet is 2 MiB and takes about 450 ms to render; cache misses use a fixed pending-response protocol rather than blocking the review API.

## Architecture

- Review API: `docs/intent/review-api/review-api-design.md`, with `docs/intent/review-api/review-api-specs.md`. Owns project authorization and the public request boundary.
- Previews: `docs/intent/previews/previews-design.md`, with `docs/intent/previews/previews-specs.md`. Owns rendering, pending jobs, and a private 12 GiB cache with 2Q replacement.

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

**STOP for review.** Approve to proceed to Phase 2 — revising the previews LLD to record the 2Q decision (Decisions row) and design the two-queue split — or give numbered feedback on this phase.