A **Decisions & Alternatives row is enough** here.

The test is whether a future reader would need the full tradeoffs to reconsider the choice—not how difficult it felt to decide. GaugeDesk’s HLD already requires kiosk-local lookup with no runtime network access, which rules out the HTTPS directory and managed search service. The choice also stays inside the registry; certificates retain the same interface.

The row records the important tradeoff: SQLite avoids a running service, while each kiosk takes responsibility for validation and index rebuilding. A separate decision doc would mostly repeat that rationale.