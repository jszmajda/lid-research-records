No, a decision doc would be overkill. Two of the skill's tests point the same way:

- **It affects only the registry node.** The certificates component sees the same `findBySerial` interface whichever backend is chosen, so no sibling design has to be sized around this result.
- **The HLD tenets settle most of it.** The on-site HTTPS directory and the managed search service both need network access during kiosk operation, which the "no runtime network access" tenet rules out. Only the local index options are left.

What remains is a single row in `registry-design.md`'s Decisions & Alternatives table. It should name SQLite as the choice, list the other two options as rejected, and give the reason. Its rationale is that a local file index meets the no-network tenet with no service to run, and that rebuilding the index on each kiosk when a snapshot arrives is an acceptable cost. A cold reader who asks "why this?" gets the answer from that row.

I'd only reconsider if the index-rebuild cost on the kiosks turns out to be a real constraint that needs a measured comparison across options.