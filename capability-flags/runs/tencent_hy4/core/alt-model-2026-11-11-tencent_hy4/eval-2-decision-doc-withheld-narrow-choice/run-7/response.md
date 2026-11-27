Coherence pre-flight — clean. The HLD, both LLDs, and both spec files are mutually consistent: PREVIEW-001–005 and REVIEW-001–004 trace to their LLDs, both LLDs match the HLD's fixed-interface/private-cache architecture, and there are no tests or code yet (every spec is an active gap). The eviction policy is the one deliberately open hole, flagged in both the HLD and the previews LLD. No drift to repair first.

Phase 1 — HLD check. 2Q is settled, so I'm not re-sketching the options or reopening the trade-off. 2Q changes no architecture — still one worker, one bounded 12 GiB private cache, the same 200/202/404 internal interface — so no new HLD approach and no re-selection. The HLD's tenets already cover the choice ("Keep cache paths and replacement bookkeeping private to the preview worker"; the policy-independent interface goal), and no new tenet is warranted: a "prefer scan resistance over low bookkeeping" lean would be a project-wide rule for a decision that lives entirely inside one leaf. The only edit removes the now-false line "Its eviction policy remains open." A fresh author would neither name 2Q at HLD level (bookkeeping is private by tenet) nor mark the policy open. I left the Goal "…through the same interface for every eviction policy" as-is — it is the interface-stability invariant and stays true with one policy.

`docs/high-level-design.md`, in full:

```
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

How the decision will be recorded: it affects only its own node — the review API and render queue are unchanged by design, and `review-api-design.md` already forbids reading eviction counters or policy config — so there is no cross-segment cascade and no decision doc, however long the argument ran. It lands as a Decisions & Alternatives row in the previews LLD (2Q chosen, LRU and aged-frequency as named alternatives with rationale), with the 2Q mechanics written as current design in the LLD body, not as a record of the debate.

Known downstream cascade, deferred to Phase 2: the previews LLD still says "The eviction policy is still open" and lists the three candidates in body prose. That line becomes the 2Q design plus the Decisions row, followed by the LLD-level edge-case probe — notably the probationary/protected queue-size split you flagged as needing tuning. Phase 3 then adds the EARS specs for the 2Q behavior.

**STOP — Phase 1.** Please approve the HLD check above, or give numbered feedback, before I move to Phase 2. For the phases ahead I'll draft each document whole for your review; tell me if you'd rather go one concept at a time or hand inspection to a delegated reader.