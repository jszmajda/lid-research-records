Overkill, I think. The Decisions row is enough.

The skill's test is whether a cold reader of the landed design would question the choice or be tempted to reverse it. Here they wouldn't:

- **An inherited constraint settles it.** The HLD tenets say lookup completes from kiosk files with no runtime network access, and the non-goals rule out cloud services during operation. The HTTPS directory and managed search service fail that before any trade-off weighing starts. Those options were only sketched as live ones in the earlier session, and they aren't live in the HLD as it stands.
- **It stays inside one node.** The certificates side is unaffected because the `findBySerial` interface is fixed, so no other design node is being sized around the result.
- **The row already carries the rationale.** It names the alternatives and the cost (each kiosk rebuilds its index on import), so a future reader can reconstruct why SQLite.

The fact that you went back and forth on it doesn't change this. The test looks at how the choice reads once landed, not at how hard it was to make.

A full doc would earn its place only if the network constraint were relaxed, for example if kiosks gained a route to an on-site service. At that point the HTTPS option would be a real contender again, and the criteria and trade-offs would be worth laying out in a doc. If you'd like one anyway, I'll write it and link it from the Decisions row, but I don't recommend it.