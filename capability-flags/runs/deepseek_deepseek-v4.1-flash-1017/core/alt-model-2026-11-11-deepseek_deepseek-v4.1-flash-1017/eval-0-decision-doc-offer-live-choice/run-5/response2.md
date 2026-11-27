Wrote `docs/decisions/self-hosted-websockets.md` and linked it from the HLD's Key Design Decisions entry. It lays out the shared constraints, the weighted criteria (recurring cost, vendor coupling, operational burden, freshness, failure visibility, build effort, delivery auth), each option's strongest case and fit, and the selection reasoning — including when polling or hosted realtime would win instead, so a new reader can re-run the judgment.

Two items still open from my earlier questions:

1. Access's Context still calls delivery "still-open" (`docs/intent/access/access-design.md:10`). Update it now, or when we do the three nodes?
2. Should avoiding vendor coupling become a project tenet, or stay as rationale for this decision only?

Review the decision doc, and let me know on those two — then I'll start the change-store, delivery, and browser-sync nodes.