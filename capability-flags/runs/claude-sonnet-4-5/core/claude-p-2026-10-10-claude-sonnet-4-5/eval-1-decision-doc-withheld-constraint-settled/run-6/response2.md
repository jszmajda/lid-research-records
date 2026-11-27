Table row is sufficient here.

Applying the decision doc test from the landed state: a cold reader will see the HLD tenet "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" and recognize that the HTTPS and managed-service options both violate it. The choice reads as settled by that constraint, even though you deliberated on the rebuild-cost tradeoff.

The Decisions & Alternatives row you have captures the tradeoffs—a future reader who wonders "why not centralize the index?" gets their answer in one line. That's the row's job. A full decision doc is for choices that stay *genuinely live* after they land—where a reader would re-litigate without seeing the competing criteria. The tenet closes this one.

If the tenet weren't there, or if multiple design nodes were being shaped around this choice (they're not—certificates is unaffected), it'd be worth the doc. Here it's residue from a real deliberation that landed obvious.

---

Now, **back to the edge-case probe**: which of those 12 gaps should be resolved in the LLD now versus deferred?