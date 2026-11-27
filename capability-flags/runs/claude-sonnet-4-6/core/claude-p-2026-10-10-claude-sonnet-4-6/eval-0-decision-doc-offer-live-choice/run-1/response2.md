Done. `docs/decisions/delivery-approach.md` is written and linked from the HLD. The doc covers:

- **Context** — why the choice matters and what it drives downstream
- **Decision elements** — the gate (15s freshness) and four weighted criteria: latency (moderate), vendor independence (major), operational surface (moderate), request volume (minor)
- **Options** — all three options at full strength, each scored per element with verdicts
- **Selection** — WebSockets wins on the major criterion (vendor independence); polling loses on latency and read volume; hosted service is eliminated by the vendor gate; the operational burden of WebSockets is explicitly acknowledged as accepted

The HLD's Approach and Architecture sections are also updated to reflect the committed choice and its downstream shape for the three unwritten nodes.

Ready to move to the nodes whenever you are. Which one do you want to start with — change store, delivery, or browser sync?