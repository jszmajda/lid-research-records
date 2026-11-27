It would be overkill. A row in the Decisions & Alternatives table is the right level here.

Under LID's earns-its-place heuristic:
1. **An inherited constraint settles it**: The HLD tenets already establish that kiosks are air-gapped with no runtime network access permitted. The remote options (HTTPS directory and managed search) violate that standing constraint, so a cold reader looking at the landed system does not need a full trade study to understand why they were eliminated.
2. **It affects only its own node**: Storage and query mechanics remain completely private to `registry`. The `certificates` node and its interface are unchanged.
3. **One line settles it**: A cold reader wondering "why SQLite?" is fully answered by the rationale row in `registry-design.md`.

Unless you want to deliberately override and write a standalone decision doc, keeping it as a table row fits the methodology best.