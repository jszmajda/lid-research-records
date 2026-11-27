**Phase 1 — HLD update complete. Stop for review.**

Two files changed:

**`docs/high-level-design.md`**
- Approach: states self-hosted WebSockets as the delivery mechanism with its three downstream obligations (outbox, session tracking, browser catch-up).
- Architecture: per-component descriptions updated to name their WebSocket-specific responsibilities.
- Key Design Decisions: new entry with link to the decision doc.

**`docs/decisions/delivery-approach.md`** (new)
- Context: frames the problem a cold reader needs.
- Decision Elements: one major gate (all three pass the freshness target), then five criteria — update latency and vendor independence at major weight, operational complexity / recurring cost / read load at burst at moderate.
- Options: all three described at their strongest honest case, each scored per criterion with verdict + factual basis.
- Selection: explains why WebSockets beats the hosted service on vendor independence (the deciding criterion and the tenet it applies), why polling falls short on latency and read load, and lists the three downstream obligations accepted.

Does this look right to you? Once you approve, we can move on to the three LLD nodes.