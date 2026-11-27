The decision doc is written at `docs/decisions/change-delivery-approach.md` and linked from the HLD's Key Design Decisions entry.

Structure, per the template:

- **Context** — why the choice exists and what it shapes (the three nodes), with the load bounds (800 browsers, 20 edits/sec bursts).
- **Decision Elements** — five weighted criteria: update latency, recurring operating cost, in-house operational burden (major); provider coupling, change store complexity (moderate). The self-hosting tenet is named where it engages; latent criteria (implementation time, browser compatibility) are noted as considered and dropped.
- **Options in the Domain** — five-second HTTPS polling, self-hosted WebSockets, hosted realtime service, each described on its own terms with a verdict-by-verdict analysis (no option dominates every element).
- **Selection** — self-hosted WebSockets, judged on the criteria and the tenet it turns on, with what it forecloses and the obligations it writes into the change store, delivery, and browser sync nodes.

Take a read — the Analysis and Selection sections are where a cold reader will judge whether the tradeoff holds, so check those hardest. If it reads right, one outstanding item from before: `docs/intent/access/access-design.md` line 10 still calls the delivery approach "still-open" (stale since the choice landed). May I update that one line in the access segment, or leave it for when access is next worked on?

After your review, we'll move to the three nodes — Phase 2, starting with whichever LLD you want first (change-store, delivery, or browser-sync).