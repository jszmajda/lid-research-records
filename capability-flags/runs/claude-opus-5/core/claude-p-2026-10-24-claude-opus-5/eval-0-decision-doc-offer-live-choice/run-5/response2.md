Written: `docs/decisions/change-delivery-approach.md`, owned by the HLD and linked from its Key Design Decisions entry. Still Phase 1 — same stop.

It's built so a cold reader can re-run the judgment, not just learn the outcome:

- **Context** — why the choice exists from the domain (three nodes shaped by it and nothing else; reversing it later means rewriting all three, not swapping a transport) and what being wrong costs in the aisle at opening time.
- **Decision Elements** — I explicitly demoted the four standing constraints to *background*, with a line saying so: all three options meet the 15-second goal, the 20-minute recovery, 800 browsers, and one-authoritative-revision, so none of them separates the field. That matters for a cold reader, who would otherwise assume the goals drove the decision. No gate eliminates anything; six weighted criteria do the work, two major.
- **Options** — one subhead each, described as its advocate would. Polling gets its real strengths stated plainly (stateless, recovery path *is* the normal path, nothing new in the stack); the hosted service gets credited with the largest ops reduction on offer.
- **Selection** — the two major criteria split the field identically, and the weighing is stated rather than implied.

Two things I want to flag rather than bury:

**I wrote the honest counterweight into the doc, and it reads as a genuine cost.** A latent criterion neither of us had named is *robustness on hostile venue networks* — congested venue wifi, tethering, proxies that refuse or silently half-break WebSockets. On that one the hosted provider is genuinely strong and self-hosted sockets are only partial; it cuts against the option you chose. I kept it in at moderate weight and answered it structurally rather than optimistically: because catch-up is a revision-range read from the last held revision, a dead connection degrades into a query rather than a wrong board, and the same path serves a two-second blip and a twenty-minute absence, so it stays exercised. If you think that mitigation is thinner than I've written it, that's worth correcting now — it's the one place the doc defends the decision rather than just reporting it.

**The Selection section leans on the new tenet, which you haven't ruled on yet.** It's what rules out the hosted option, so if you cut or reword tenet #5 (my question 1 last turn), that paragraph needs rewriting with it.

Still open from last turn, and I'd rather not start Phase 2 without them:

1. **Tenet #5** — keep as drafted, reword, or cut? (Noting the "both permitted" tension above it.)
2. **Freshness goal** — stays at 15 seconds, or a tighter number for connected browsers with 15s as the post-reconnect floor? This shapes delivery and browser-sync specs directly.
3. **The stale line in `access-design.md`** ("independent of the still-open change-delivery approach") — fix now, or leave the access segment alone?

Separately, writing the doc surfaced a question for access that I recorded in the Selection section: a long-lived socket outlives nothing, but an eight-hour session can expire mid-connection — so re-checking authorization on an open connection needs an owner. I'll raise it properly at the delivery node, not now.