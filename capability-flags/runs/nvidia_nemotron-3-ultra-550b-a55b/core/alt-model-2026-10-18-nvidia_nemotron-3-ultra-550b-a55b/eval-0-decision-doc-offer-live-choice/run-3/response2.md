Done. Created **`docs/decisions/realtime-delivery-approach.md`** — a full decision doc that a cold reader can use to re-run the judgment.

**What it contains:**
- **Context** — three options, why the choice isn't trivially reversible
- **Gates** (binary eliminators): subsecond updates, no vendor bill, no vendor coupling, capacity/burst/recovery goals
- **Weighted criteria**: operational burden (major), implementation complexity, latency headroom (moderate), debuggability, scaling path (minor)
- **Three options with strongest honest representation** — each analyzed against every gate/criterion with verdict + factual basis
- **Selection** — why self-hosted WebSockets wins (only option passing all gates), which tenet it turns on ("Self-hosted and managed infrastructure are both permitted"), what it forecloses and obligates downstream

**Linked from four places:**
- HLD Key Design Decisions
- Change Store LLD Decisions & Alternatives
- Delivery LLD Decisions & Alternatives  
- Browser Sync LLD Decisions & Alternatives

The cascade is complete — all three LLDs and their 82 EARS specs are written against this decision.