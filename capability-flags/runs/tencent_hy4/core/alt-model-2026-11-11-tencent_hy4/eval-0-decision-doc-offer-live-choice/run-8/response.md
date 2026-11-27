**Phase 1 — HLD check, complete. STOP before the three nodes.** The only file I changed is `docs/high-level-design.md`; I did not create the change-store / delivery / browser-sync LLDs, per "we'll do the three nodes after that."

**Coherence pre-flight (no blocking drift):**
- `ACCESS-001`–`004` in `access-specs.md` each trace to a statement in `access-design.md`. No tests exist yet (all four are `[ ]`), so no test↔spec drift to reconcile.
- `access-design.md` still reflects the HLD architecture: access sits below the HTTPS command boundary and is independent of the delivery route — the chosen approach doesn't change that segment's substance.
- One stale descriptive phrase, cross-segment, **not** fixed: `access-design.md:10` calls the approach "still-open". Flagged as Q4.
- No `docs/arrows/` overlay and no `## LID Tooling` declared, so checks were done in-prompt.

**Updated `docs/high-level-design.md`, in full:**

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision and retains the revision history. Browsers display a revisioned view of the board.

Committed changes reach browsers over self-hosted WebSockets. The delivery component holds each browser's connection and streams committed revisions as they happen; the change store exposes revisions in commit order so a reconnecting browser can replay what it missed; the browser owns subscription, reconnect, and catch-up. This route delivers updates with low latency without coupling the board to a hosted realtime provider. In exchange, the project owns connection capacity, reliable publication, and reconnect handling itself.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Sits below the stable HTTPS command boundary; independent of the change-delivery route.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, ordered read access, and reliable publication of committed revisions for replay.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management and publication of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscription, reconnect, and catch-up from the last-seen revision.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records.

## Goals

- Show committed changes in connected browsers within 15 seconds under normal connectivity.
- Support 800 simultaneous browsers and opening-time bursts of 20 edits per second.
- Recover the latest board after a browser has been disconnected for up to 20 minutes.
- Retain seven days of event revisions for operational investigation.
- Achieve 99.5 percent availability during published event hours.

## Non-Goals

- Offline editing or resolving conflicting offline commands.
- Vendor payments, customer information, or public attendee access.
- Multi-region active-active operation for the pilot.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets deliver committed changes.** Each browser holds a server-owned socket session that streams committed revisions; the change store exposes replayable revisions for reconnect catch-up, and the browser owns subscription and reconnect. Considered five-second HTTPS polling (stateless and simplest to operate, but adds repeated reads and a few seconds of lag) and a hosted realtime service (less connection ops, but recurring fees and provider coupling). Self-hosting gives low-latency updates without a realtime vendor; the project takes on connection capacity, reliable publication, and reconnect handling as its own operational work.
```

I rewrote the Approach cold from the selected option — dropping the "still open / all three meet the target / no criterion declared" deliberation residue — and moved the options-and-rationale into Key Design Decisions, where a fresh author would keep them. Architecture pointers now name settled responsibilities instead of "depending on the approach."

Before I walk the three nodes, I need your rulings:

1. **Decision doc?** This choice stays live for a cold reader — three credible options traded against latency, ops burden, and vendor coupling, no inherited criterion settling it (the old HLD said neither cost nor ops burden was overriding), and the three upcoming nodes will be sized around the result. I recorded it as a Key Design Decisions entry so the HLD stands on its own. Do you want me to expand it into a full decision doc (`docs/decisions/realtime-delivery-approach.md` — options, criteria, selection) and link it from that entry, or is the entry enough? I'll write the doc only if you say yes.
2. **"Fast updates" vs. the freshness goal.** You chose WebSockets partly for fast updates, but the committed goal is "within 15 seconds," and the deliberation note I removed said subsecond is "useful but not required" because all three options met that goal. Should low latency be recorded as a decided criterion / should I tighten the freshness goal, or does the 15-second SLA stay with low latency as a preference only? I left Goals unchanged pending your answer.
3. **Tenet?** Your rationale — accepting connection and reconnect ops work for fast updates and no realtime-vendor coupling — is a lean a different project could reasonably reverse, so it's a tenet candidate that would govern the node-level trade-offs. Want me to add it as a one-line tenet? It would sit alongside "Self-hosted and managed infrastructure are both permitted"; I'd make sure the two don't read as contradictory. I haven't touched the Tenets section.
4. **Cross-segment cleanup.** `access-design.md:10` is in the access segment; touching it crosses a boundary, so I paused. Want me to refresh that one phrase as part of the node work, or leave it since access is intentionally approach-independent?
5. **Approve the HLD.** Read the doc above and either approve or give numbered feedback. I won't start the three nodes (change-store, delivery, browser-sync) until you say go.

Inspection instrument: you're reading the phase output directly (the default). If you'd prefer a delegated or zero-context inspector for the node phases, say so and I'll set it up. I'll stop here.