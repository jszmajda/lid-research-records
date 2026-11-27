**Phase 1 complete — HLD updated** (`docs/high-level-design.md`). Here's what changed and three things I need from you before moving to the three nodes.

**What the HLD now says**

- **Approach** — committed revisions reach browsers over self-hosted WebSocket sessions; the delivery component owns sessions/subscriptions/publish, the change store must keep revisions replayable for catch-up, browser sync owns connect/reconnect/catch-up. Editors still use the HTTPS command path; the socket path carries changes outward only. The paragraph saying the approach is "still open" and that all three options meet the freshness target is gone, replaced by the accepted-cost statement: we own connection capacity and reconnect work in exchange for push-speed updates without a vendor bill.
- **Architecture** — the three unwritten node bullets now name their WebSocket-specific obligations instead of listing "polling responses, socket sessions, or hosted publication" as alternatives.
- **Non-Goals** — added "Depending on a hosted realtime service to deliver committed changes."
- **Key Design Decisions** — new row recording the choice with polling and hosted realtime named as rejected alternatives and the reason (stateless vs. seconds of lag and cursor queries; vendor fees and coupling vs. connection work we own).
- **Success Metrics** — new section (the HLD previously had none) with freshness margin, 800 concurrent sessions without drops, and resume-after-20-minute-gap.
- **Open Questions** — new section: how the delivery tier authorizes subscription requests against event assignments, and how a browser distinguishes "no changes" from "connection lost."

**Three things for you**

1. **Tenet.** The existing tenet "Self-hosted and managed infrastructure are both permitted" no longer leans anywhere, and the choice you just made leans one way. Candidate: *"Owning the operational burden beats avoiding vendor coupling"* (defensible opposite: prefer the managed service and pay). Do you want that as a tenet, or keep the existing permissive line untouched?
2. **Decision doc?** This choice is a strong candidate for a full decision doc under `docs/decisions/` — the alternatives were traded against several criteria and the three downstream nodes are about to be sized around the result, so a cold reader could re-litigate it. I can write it, or leave it as the Key Design Decisions row alone. Your call — I won't write one unless you say so.
3. **Cross-segment cascade.** `docs/intent/access/access-design.md:10` still describes the change-delivery approach as "still open," and its Audit Boundary says access "does not decide how changes reach browsers." Both are now stale. Access is a separate arrow segment, so I paused rather than editing it — do you want me to update that line now, or leave access untouched for its own segment's pass?