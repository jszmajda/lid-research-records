It would be overkill. I'd record it as a row in the registry LLD's Decisions & Alternatives table.

A decision doc is for a choice that stays live: credible options traded against several criteria, with other nodes sized around the result. This one doesn't meet that bar:

- **Two of the three options are excluded by existing tenets.** The on-site HTTPS directory and the managed search service both break "no runtime network access" and "no network route." A cold reader doesn't need a debate record to see why they're out.
- **The choice affects only the registry node.** Certificates still call `findBySerial` and never see the backend, so no sibling is sized around it.

The row will say that SQLite was chosen, that the other two were rejected because the tenets exclude them, and that the index is rebuilt and validated on each kiosk inside the registry. That's enough for someone to understand the choice later.

Still waiting on your approval of the HLD edit before I draft the registry LLD.