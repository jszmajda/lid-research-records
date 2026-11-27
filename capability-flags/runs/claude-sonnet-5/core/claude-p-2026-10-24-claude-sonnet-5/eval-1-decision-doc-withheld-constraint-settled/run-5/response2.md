Overkill here — I'd skip the decision doc.

The decision-doc test runs from the *landed* state: would a cold reader find the choice genuinely re-litigatable, with credible options traded against more than one criterion? Here they wouldn't — the HLD already commits to "no runtime network access" and "no network route during normal operation" (docs/high-level-design.md:18-19). That inherited constraint eliminates the HTTPS directory and managed search options outright; SQLite isn't winning a close multi-criteria tradeoff, it's the only one left standing. The felt back-and-forth was real, but it was about discovering that constraint applied, not about weighing live options against each other.

That's exactly the "an inherited constraint settles it" case the skill calls out as *not* earning a doc — a Decisions & Alternatives row that names the rejected options and points to the tenet is enough for a future reader to see why, which is what I already recorded at registry-design.md:26-30.

If you'd still like the fuller writeup for some other reason (e.g. documenting the deliberation itself for the team), say so and I'll draft one — but on the merits of the choice alone, the row covers it.

Separately, the edge-case probe from my last message is still open — want to work through those five questions before I fold any into the LLD?