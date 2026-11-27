Overkill, I think. The Decisions & Alternatives row covers it.

The test is whether a cold reader of the landed design would question the choice or be tempted to reverse it.

- **The HLD already settles it.** The tenets say lookup must complete from files on the kiosk, with no runtime network access, and the non-goals rule out remote access and cloud services. That excludes the HTTPS directory and the managed search service. SQLite is the only one of your three options that fits, so one option dominates and an inherited constraint decides the matter.
- **The choice stays inside its own node.** The certificates interface is unchanged, so no other design node is being sized around the result.
- **A cold reader can reconstruct it from the row.** The row names the alternatives, cites the tenets, and states the cost (each kiosk rebuilds its own index). Someone tempted to reverse it would be answered by the HLD itself.

The fact that you went back and forth on it doesn't change this. The rule judges the landed state, not how hard the decision was.

A decision doc would earn its place if the HLD's offline tenets were later relaxed, say by a lab-network route. Then the three options would become genuinely competitive again, and the criteria would be worth writing down at that point.

If you'd still like one for your own records, I can write it, but I'd keep the table row as the pointer.