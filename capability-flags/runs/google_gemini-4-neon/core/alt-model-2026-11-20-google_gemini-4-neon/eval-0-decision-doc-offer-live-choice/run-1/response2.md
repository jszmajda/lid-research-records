Created `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` under `## Key Design Decisions`.

### `docs/decisions/change-delivery.md`

- **Frontmatter:** `node: high-level-design`
- **Context:** Frames the 40-market / 800-browser / 20-edit-per-second burst domain, baseline goals (15s freshness, 20-minute disconnect recovery, 7-day retention, 99.5% availability), and why the choice couples `change-store`, `delivery`, and `browser-sync`.
- **Decision Elements:** Weighted criteria only (no gates, since all three options meet the baseline goals and tenets):
  - *Update responsiveness* (**major**)
  - *Vendor independence and recurring cost* (**major**, noting the HLD tenet permits both self-hosted and managed infrastructure)
  - *Operational simplicity and connection management* (**moderate**)
  - *Connectivity-failure visibility and authoritative recovery* (**moderate**, tied to the visibility and single-authoritative-revision tenets)
  - *Backend read and publication load under bursts* (**minor**)
- **Options in the Domain:** Full prose profiles (`Description`, per-criterion `Analysis` with `strong`/`partial`/`weak` fit verdicts, and `Summary`) for **Five-second HTTPS polling**, **Self-hosted WebSockets**, and **Hosted realtime service**.
- **Selection:** Records **Self-hosted WebSockets**, why it wins on the two major criteria while accepting weak fit on operational simplicity, the HLD tenets engaged, downstream obligations for `change-store`, `delivery`, and `browser-sync`, and conditions for revisiting the choice.

Please review `docs/decisions/change-delivery.md` and `docs/high-level-design.md` and let me know any edits. Once approved, let me know:
1. Whether to also update the "still-open change-delivery approach" line in `docs/intent/access/access-design.md`.
2. Which of the three nodes (`change-store`, `delivery`, or `browser-sync`) you want to draft first in Phase 2.