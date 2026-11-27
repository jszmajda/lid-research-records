Done. Still Phase 1 — here's where things stand for your review.

## Decision doc written

`docs/decisions/change-delivery-transport.md` lays out the choice so a cold reader can re-run it:

- **Context** — why a transport choice exists and why it's load-bearing (it sizes all three downstream nodes).
- **Decision Elements** — two major criteria (update latency, recurring vendor cost) and two moderate ones (operational burden, provider coupling). I noted explicitly that the 15-second goal is a floor all three meet, so it's background rather than a gate, and that no tenet eliminates any option.
- **Options in the Domain** — polling, self-hosted sockets, and hosted realtime, each with a full description and a per-criterion fit verdict.
- **Selection** — self-hosted WebSockets wins because it's the only option strong on *both* major criteria (polling gives up latency, hosted gives up cost); the operational burden is the weak element we knowingly accept. It names the downstream obligations on the three nodes and the one tenet that genuinely engages — "connectivity failures must be visible" drives browser-sync's drop-detection — and foreclosures.

I linked it from the Key Design Decisions entry in the HLD.

**Two things to check yourself if you want:** that the latency/cost weighting in the doc matches how you'd actually trade them, and that the Selection's "we accept the operational burden deliberately" reads the way you meant the tradeoff — those are the judgments the doc now commits to writing.

## Still open from before

The one cross-segment cascade: `docs/intent/access/access-design.md:10` still says authorization is "independent of the **still-open** change-delivery approach" — now stale. May I change it to "independent of the change-delivery transport"? That's the access segment, so I'm holding until you approve.

Once you've reviewed the HLD + decision doc (and answered the access-line question), we can start the three nodes in Phase 2.