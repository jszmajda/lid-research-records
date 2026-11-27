Updated the HLD to reflect the self-hosted WebSockets decision:

**Approach section** — Changed from "still open" to the chosen approach with its rationale: fast updates without vendor bills, accepting ownership of connection and reconnect operations.

**Architecture section** — Updated the three pending nodes (change-store, delivery, browser-sync) with their WebSocket-specific responsibilities.

**Key Design Decisions** — Added entry documenting the choice and naming the rejected alternatives (polling for latency/overhead, hosted services for vendor coupling).

The HLD now commits to self-hosted WebSockets as the delivery mechanism. Please review these changes before I proceed to draft the three LLDs.