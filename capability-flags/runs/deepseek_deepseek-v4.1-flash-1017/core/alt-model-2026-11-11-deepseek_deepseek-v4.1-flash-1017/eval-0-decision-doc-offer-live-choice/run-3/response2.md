Wrote `docs/decisions/delivery-approach.md` and linked it from the HLD's Key Design Decisions row.

The doc lays out the five elements that carry the decision — vendor independence and connection operation burden (major), plus update latency, repeated read load, and failure visibility — then each option's strongest case and its fit against those elements. The selection records that self-hosted WebSockets was the only option strong on both vendor independence and repeated read load while also giving subsecond updates, and that the accepted cost is owning capacity, session lifetime, reconnect, and publication for up to 800 browsers. It also names the two tenets that become obligations downstream: one authoritative revision regardless of delivery route, and disconnected sessions surfaced rather than looking like an unchanged board.

Still open from my last message: `docs/intent/access/access-design.md` says authorization is independent of the "still-open change-delivery approach." Update that stale phrase now, or leave it for the node work?

Once you approve the decision doc and answer that, I'll start the three node designs.