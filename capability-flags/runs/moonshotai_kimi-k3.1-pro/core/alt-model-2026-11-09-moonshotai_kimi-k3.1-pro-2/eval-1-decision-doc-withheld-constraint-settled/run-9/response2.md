A standalone decision doc would be overkill here.

The kiosk’s offline constraint eliminates the HTTPS and managed-service options despite their operational advantages, so SQLite is the clear fit. The **Decisions & Alternatives** row in `registry-design.md` already preserves that reasoning and the trade-off accepted: each kiosk validates snapshots and rebuilds its own index.

A full decision doc would only be warranted if the network-based options remained credible and future maintainers were likely to re-litigate the choice across several competing criteria.