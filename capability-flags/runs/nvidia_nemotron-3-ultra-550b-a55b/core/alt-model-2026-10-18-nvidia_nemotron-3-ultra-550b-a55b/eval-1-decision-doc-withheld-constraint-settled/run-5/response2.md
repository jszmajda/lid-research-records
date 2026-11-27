This is **not a decision doc case** — it's a table row (which I already added). The earns-its-place test from the landed state:

- **HLD tenet already constrains it**: "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted."
- The other two options (HTTPS directory, managed search service) require network connectivity kiosks don't have.
- A cold reader sees the tenet → immediately understands why SQLite is the only viable choice.
- No live tradeoff remains once the tenet is in place.

The table row in the LLD captures it adequately. A decision doc would be residue — documenting a choice that the architecture already forced.