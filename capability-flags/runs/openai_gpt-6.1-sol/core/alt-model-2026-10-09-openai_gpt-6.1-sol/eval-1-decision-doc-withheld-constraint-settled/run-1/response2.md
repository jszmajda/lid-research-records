**A Decisions & Alternatives row is enough here.** The deciding factor is whether a future reader would need the full tradeoff analysis—not how difficult the choice felt during discussion.

GaugeDesk’s HLD already requires kiosk-local lookup with no runtime network access. That eliminates the HTTPS directory and managed service under the current architecture. A row can explain SQLite’s fit and its cost: each kiosk must validate and rebuild its own index, with temporary storage during replacement.

A standalone decision doc would earn its place if we reconsidered the offline constraint and genuinely weighed local independence against centralized maintenance. That would be an architectural decision owned by the HLD.

The registry draft already contains the appropriate row.