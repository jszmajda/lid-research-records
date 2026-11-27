The table row is sufficient — no decision doc needed.

Applying the test: an inherited constraint settles this. The HLD tenets state "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" and "Kiosks have no network route during normal operation." Those rule out the HTTPS directory and managed search service options. A cold reader sees that SQLite is the only choice compatible with the architecture, so the decision reads as resolved by the context rather than staying live.

The Decisions & Alternatives row captures why SQLite was chosen and what was considered — that's enough to answer "why this?" without re-litigating the choice.

Back to the edge-case probe: which of those 15 gaps should I address in the LLD now vs. defer?