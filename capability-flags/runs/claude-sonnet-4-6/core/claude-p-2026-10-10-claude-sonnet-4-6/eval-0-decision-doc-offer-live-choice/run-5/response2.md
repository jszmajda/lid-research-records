Done. Here's what landed:

**`docs/decisions/delivery-mechanism.md`** — a full decision doc covering:
- **Context**: why the delivery choice is upstream of three unwritten components, and the one invariant (single authoritative revision) that all options must respect
- **Decision Elements**: two gates (15-second freshness, 800-browser scale) and five weighted criteria — latency and read amplification and vendor independence as major, operational complexity as moderate, recurring cost as minor
- **Options in the Domain**: all three options described at their strongest, with per-criterion verdicts; polling gets full credit for simplicity, hosted service gets full credit for outsourced connection management
- **Selection**: self-hosted WebSockets wins on all three major criteria; the accepted tradeoff (owning connection and reconnect complexity) is named plainly, and the downstream obligations to change-store and browser-sync are stated

**`docs/high-level-design.md`** — the Key Design Decisions entry now summarizes the choice and links to the doc.

Ready to move to the three nodes whenever you are.