The decision doc is written: `docs/decisions/self-hosted-websockets-delivery.md`, linked from the HLD's Key Design Decisions row.

It's structured so a cold reader can re-run the judgment:

- **Decision elements** — two gates (freshness target, availability) that no option fails, so the choice honestly turns on the weighted criteria: latency (deliberately weighted minor), operational burden, recurring cost, vendor coupling, and the two HLD tenets weighted major.
- **Options in the domain** — each of the three routes described as its advocate would, with per-criterion verdicts and a one-line trade summary.
- **Selection** — why self-hosting wins: polling buys simplicity with permanent seconds-scale lag and repeated reads; hosting buys simplicity with indefinite fees and provider-shaped contracts; self-hosting pays a bounded ops investment for subsecond push with no vendor and full connection-state visibility, and the decision is explicitly anchored to the one-authoritative-revision and connectivity-failures-visible tenets.

Please review the doc — in particular whether the criteria weights (latency as *minor*, the two tenets as *major*) match how you actually weighed it, and whether anything you considered last session is missing from the options. Once you're happy with it, I'll start on the three downstream nodes (change-store, delivery, browser-sync), taking them one at a time.