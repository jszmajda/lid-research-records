Table row is right; a decision doc would be overkill.

The test: *would a cold reader of the landed design re-litigate this choice without seeing the alternatives?* Probably not. The HLD's tenets say "All serial-number lookup SHALL complete using files on the kiosk" and "no runtime network access is permitted" — that rules out the HTTPS directory and managed search service on constraints alone. SQLite reads as the native fit once you see those constraints.

The table row is worth keeping because it shows you considered the more sophisticated options and chose the simpler one deliberately, not by default. But the choice doesn't stay live enough to warrant a full decision doc — it's settled by the HLD's constraints, and the certificates node doesn't size around it (the interface is fixed regardless of backend).

The Decisions & Alternatives row does its job: a cold reader wondering "why not a search service?" finds the answer right there.