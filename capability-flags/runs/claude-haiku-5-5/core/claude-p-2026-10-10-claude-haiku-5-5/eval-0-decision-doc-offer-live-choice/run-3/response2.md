I wrote the decision doc at `docs/decisions/committed-change-delivery.md` and linked it from the HLD's delivery decision row.

It covers the three options against the criteria that separate them: operations burden, provider coupling, recurring cost, freshness, repeated-read load, and reconnect/replay complexity. It names the tenet that makes the accepted costs manageable: connectivity failures must be visible. The selection explains why self-hosted sockets win and what the project takes on: connection capacity, reconnect and replay, the publication outbox, and socket uptime. It also notes that a later move to a managed provider would replace the delivery component and browser client, while the change store and revision model would stay.

The doc describes the decision as it stands, without referring back to this session. The HLD edit is the only other change, and both files are uncommitted.

The stale line in `docs/intent/access/access-design.md` is still there. It will be fixed when we walk the access node.