A decision-table row is enough here.

The deciding factor isn’t how much deliberation it took; it’s whether a future reader needs the full comparison to understand the choice. The HLD requires kiosk-local lookup and prohibits runtime network access, so the HTTPS directory and managed service are ruled out by an existing constraint. The row captures the remaining tradeoff: predictable local lookup in exchange for each kiosk validating and rebuilding its index.

A standalone decision doc would make sense if we were reconsidering the offline-only architecture itself. For this registry backend choice, it would be overkill.