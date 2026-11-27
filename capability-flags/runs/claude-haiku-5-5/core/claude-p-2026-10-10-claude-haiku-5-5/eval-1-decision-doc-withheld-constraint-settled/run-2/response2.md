No, a decision doc would be overkill here. The skill reserves them for choices that stay live for a cold reader, meaning one that would be re-argued without the competing options and criteria. This one doesn't meet that bar, for two reasons:

- **An inherited constraint settles it.** The HLD tenets rule out runtime network access, so the on-site HTTPS and managed-service options are excluded before any tradeoff comes up. The skill says not to offer a doc when an inherited constraint settles the choice.
- **It affects only the registry node.** Certificates sees only `findBySerial`, so the backend choice doesn't reach a sibling. Decisions that stay inside one node get a row, not a document.

A Decisions row in the registry LLD covers what a cold reader would need: SQLite was chosen, the two network options were rejected because the HLD forbids runtime network access, and the local index was picked for predictable lookups with no service to run.

This would change if you decide to revisit the network tenets. Then the choice is live again, with credible options traded against real criteria, and a decision doc would earn its place. Until then, I'd keep it as a row.