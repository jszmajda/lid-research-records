**Phase 1 complete** — decision doc written to `docs/decisions/change-delivery-approach.md` (project-level, owned by the root HLD), with the HLD's Key Design Decisions row linking to it.

**How it's structured** (per the decision-doc template — context, decision elements, options in the domain, selection):

- **Context** — the freshness target, load, and disconnect-recovery requirement, framed so a newcomer sees why a delivery route had to be chosen at all.
- **Decision Elements** — two gates (no external realtime dependency; must meet the 15-second target under stated load) and five weighted criteria: vendor coupling (major), freshness margin (major), recurring cost (moderate), operational load (moderate), specialized operating knowledge (moderate). I deliberately included the two criteria that cut *against* the chosen route, with a note that the reasoning is only sound if those costs are stated at their real size.
- **Options in the Domain** — all three, each with a description, a concrete demonstration, and a per-element analysis with verdicts. The hosted service is marked **eliminated** at the first gate rather than merely scored down. The polling option is scored **strong** on operational load and vendor coupling, so the doc doesn't pretend the choice was free.
- **Selection** — the deciding gate was the no-external-dependency boundary, which eliminated hosted delivery outright; the freshness criterion then separated polling from sockets. It states the accepted costs plainly, and adds that the 99.5% availability goal now covers our own socket tier, including capacity exhaustion, reconnection storms, and stalled publishes.

**Two follow-on items the doc names, which are yours to settle:**

1. **Tenet.** The doc's closing paragraph says the project "has not adopted a general tenet stating that preference" — deliberately, so it doesn't assume your answer. The candidate remains: *"Owning the operational burden beats avoiding vendor coupling"* (defensible opposite: prefer the managed service and pay). The current permissive tenet — "Self-hosted and managed infrastructure are both permitted" — lets this decision stand without pushing the next one either way. Adopt the lean, or leave the permissive line?
2. **Access-segment cascade.** `docs/intent/access/access-design.md:10` still calls the change-delivery approach "still open," and its Audit Boundary says access "does not decide how changes reach browsers." Both are now stale. Access is a separate arrow segment, so I paused rather than editing it. Update that line as part of this HLD cascade, or leave access for its own segment's pass?

The three nodes (change-store, delivery, browser-sync) are still unwritten — say the word on those two and I'll move to Phase 2 for them.