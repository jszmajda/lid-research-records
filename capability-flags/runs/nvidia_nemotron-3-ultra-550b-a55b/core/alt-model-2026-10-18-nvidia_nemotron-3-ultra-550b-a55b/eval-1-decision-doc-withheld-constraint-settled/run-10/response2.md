No, a full decision doc would be overkill. The tenets already rule out the network-dependent options:

- **Tenet**: "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"
- **Tenet**: "Kiosks have no network route during normal operation"

Both HTTPS directory and managed search service violate these tenets. The SQLite choice is effectively forced by inherited constraints. The Decisions & Alternatives row with one-line rationale is the right level — a cold reader sees the tenets and the choice settles itself.

Per the earns-its-place heuristic: this is the "A Decisions & Alternatives row" case — inherited constraint eliminated the alternatives. A decision doc is reserved for choices that stay genuinely live for a cold reader.