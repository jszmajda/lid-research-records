Created **Decision: Change Delivery Approach** at `docs/decisions/change-delivery-approach.md` and linked it from the HLD.

The doc covers:
- **Context**: Pilot scale (800 browsers, 20 edits/s burst), 15s freshness, 20-min recovery
- **Gates**: delivery target, no vendor bill, recovery, no lock-in
- **Weighted criteria**: operational burden (major), observability of failures (major, tenet-backed), latency (moderate), implementation complexity (moderate), cost predictability (major)
- **Three options** with full analysis against each element
- **Selection**: Self-hosted WebSockets wins on the tenet-backed observability criterion (explicit disconnect signal vs. polling's "stalled poll = looks like no changes" failure mode), accepting bounded operational burden at pilot scale
- **Downstream obligations** for change-store, delivery, browser-sync
- **Tenets engaged**

**STOP for review.** 

Ready for Phase 2: draft the three leaf LLDs — `change-store`, `delivery`, `browser-sync` — each with its own EARS specs?