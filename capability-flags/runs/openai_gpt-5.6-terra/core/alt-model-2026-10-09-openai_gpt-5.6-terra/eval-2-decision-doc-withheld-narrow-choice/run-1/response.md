## Phase 1: HLD Review

Updated `docs/high-level-design.md` to close the previously open eviction-policy decision:

> Previews own rendering, pending jobs, and a private 12 GiB cache using 2Q eviction to retain sheets that editors revisit during comparison work while admitting long sequential screenings.

The HLD's fixed API boundary, cache privacy, 12 GiB limit, and pending-response behavior remain unchanged. The preview LLD still needs the 2Q design details and corresponding EARS requirements.

Approve this HLD update so I can draft the preview LLD and run its edge-case probe?