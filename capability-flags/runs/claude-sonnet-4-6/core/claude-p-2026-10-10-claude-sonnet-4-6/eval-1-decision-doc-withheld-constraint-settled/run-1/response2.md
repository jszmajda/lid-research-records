No decision doc needed here. The skill's test is: *would a cold reader of the landed design be tempted to reverse the choice?* — not *was the deliberation hard?*

A cold reader who sees "kiosk with no runtime network access, SQLite index" and then reads the HLD tenet ("all serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted") would recognize that the other two candidates were ruled out by an inherited constraint, not a close tradeoff. They wouldn't re-litigate it; they'd just see the only option that fits.

The D&A row is exactly right for this: it names the alternatives, records that the tenet settles it, and gives a future reader enough to reconstruct the reasoning. A full decision doc earns its place when the choice stays live for a cold reader — credible options weighed against multiple criteria with no prior constraint settling it. This one doesn't clear that bar.

The fact that you went back and forth on it doesn't change the landed state. Once the offline-only tenet is on the page, the choice reads as obvious.

Ready to move on to Phase 3 — shall I proceed with the EARS spec update? And before we go there, would you like to close any of the probe gaps from Phase 2 (particularly gap 3 on NULL date fields and gap 7 on zero-record snapshots)?