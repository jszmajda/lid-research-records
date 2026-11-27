No, a decision doc would be overkill. The skill's test is: *would a cold reader of the landed result question this choice, or be tempted to reverse it?*

Looking at the design as it lands:

- The Decisions table row clearly names the choice (SQLite), the alternatives (HTTPS, managed service), and the rationale (predictable lookups, offline, no service, independent per-kiosk validation).
- The rationale addresses the tradeoffs directly (each kiosk validates, needs disk space, but that's acceptable).
- This decision affects only the registry component — no cascade into certificates or elsewhere.
- The design prose integrates the SQLite choice naturally; it's not mysterious or non-obvious as a result.

A decision doc earns its place when a choice stays genuinely live for a cold reader — when they'd want to re-litigate it and would need the full criteria and options to make the judgment themselves. Here, the Decisions row gives enough context. A fresh reader would accept this landing as reasonable, not question it.

**The Decisions table row is what it needs.** Move forward to the edge-case probe resolution.