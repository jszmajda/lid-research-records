Done. Here's what landed:

**`docs/decisions/websocket-delivery.md`** — a full decision doc with:
- **Context** explaining why this decision reaches across three downstream nodes
- **Gate**: meets the 15-second freshness goal
- **Four weighted criteria**: update latency (major), vendor independence (major), operational burden (moderate), cost predictability (moderate)
- **Three options** in full honest representation — polling, self-hosted WebSockets, hosted service — each scored per criterion
- **Selection** section making the reasoning explicit: polling loses on latency and read load at scale; the hosted service loses on the vendor-independence criterion at major weight plus burst-cost unpredictability; WebSockets wins by accepting the connection-management burden in exchange for no vendor dependency

**`docs/high-level-design.md`** — the Key Design Decisions row now links to the doc.

Ready to move on to the three nodes whenever you are.