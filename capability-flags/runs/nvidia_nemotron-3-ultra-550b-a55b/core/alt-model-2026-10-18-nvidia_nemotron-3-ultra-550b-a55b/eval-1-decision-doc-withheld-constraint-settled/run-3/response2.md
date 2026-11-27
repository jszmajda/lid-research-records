A table row is sufficient — this would be overkill for a decision doc.

The HLD tenets already constrain the choice:
- "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"
- "Kiosks have no network route during normal operation"

Only the local SQLite index satisfies those. A cold reader who sees the tenets won't question the choice — it reads as native, not contested. The row in the Decisions & Alternatives table captures the "why" for anyone who skips the tenets.

Per the skill: offer a decision doc only when the choice *stays genuinely live* (a reader would re-litigate it). This one doesn't clear that bar.