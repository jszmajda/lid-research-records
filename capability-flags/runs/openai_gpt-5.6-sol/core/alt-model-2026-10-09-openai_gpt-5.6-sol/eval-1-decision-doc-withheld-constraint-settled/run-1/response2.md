A standalone decision doc would be overkill.

For the missing/unreadable registry state, a **Decisions & Alternatives table row in the registry LLD** is sufficient. A cold reader may ask why the chosen error model was used, but one concise rationale can settle it. The decision’s substance belongs to the registry; the certificate node only receives a cascaded obligation to block export and display the failure.

The SQLite choice also does not need a decision doc: the HLD’s offline-only constraint largely eliminates the networked alternatives, and the existing table row preserves enough rationale.

The Phase 2 choice remains open: I recommend **option 1, `Unavailable(reason)`**, because it keeps the fixed interface explicit and distinguishes registry failure from a legitimate `NotFound`.