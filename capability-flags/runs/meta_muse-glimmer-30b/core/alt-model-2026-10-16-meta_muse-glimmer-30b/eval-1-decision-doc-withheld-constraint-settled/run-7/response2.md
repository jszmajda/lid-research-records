The lookup backend choice is recorded in the LLD Decisions & Alternatives table with chosen option, alternatives considered, and rationale tied to the offline tenet and per-kiosk rebuild.

Using the decision-doc heuristic: a cold reader can reconstruct why local SQLite was chosen from the table row — predictable offline lookups, no service, maintenance stays inside registry, and the certificate interface is unchanged. The alternatives are credible but the HLD tenets already make the choice native; other design nodes aren’t sized around weighing cost vs. network vs. search richness.

That lands as a table-row decision, not a full decision doc. A decision doc earns its place only when a future reader would re-litigate the trade-offs without the competing options and criteria in front of them.

Do you want me to keep it as the table row only, or create a full decision doc in docs/intent/registry/decisions/ for deeper traceability?