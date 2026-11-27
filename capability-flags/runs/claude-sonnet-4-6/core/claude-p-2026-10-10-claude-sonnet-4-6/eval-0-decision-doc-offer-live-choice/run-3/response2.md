**Phase 1 stop — HLD update + decision doc for review.**

`docs/decisions/delivery-approach.md` is written to be read cold. It covers:

- **Two gates** — freshness target and browser concurrency (all three options pass both, so they don't eliminate anything but establish the playing field).
- **Four criteria** — update latency and operational independence as major, operational burden and recovery after disconnection as moderate.
- **Per-option analysis** — each option described at its strongest, with a verdict on each element and a one-line trade summary.
- **Selection** — explains why the hosted service is eliminated first (major criterion: vendor coupling), then why WebSockets beats polling on the other major criterion (latency), and names the accepted trade-off explicitly (connection-capacity and reconnect operations on the moderate criterion).
- **Downstream obligations** — three concrete obligations for change-store, delivery, and browser-sync, which we'll carry into the LLD phases.

The HLD's Key Design Decisions row is condensed to a summary + link.

Please review — once you're happy with this I'll move to the three LLD nodes.