**The Decisions & Alternatives row is enough here.**

A standalone decision doc earns its place when a future reader could reasonably reopen the choice and would need the full competing criteria to understand it. How difficult the decision felt isn’t, by itself, the test.

GaugeDesk’s HLD already requires local-file lookups with no runtime network access. That rules out both service-backed options as described. SQLite’s main tradeoff—each kiosk validates and rebuilds its own index—is captured in the registry’s table, and the choice stays inside the registry without changing the certificate contract.

So I’d keep the row already written. It preserves the reasoning a future maintainer needs without duplicating the design.