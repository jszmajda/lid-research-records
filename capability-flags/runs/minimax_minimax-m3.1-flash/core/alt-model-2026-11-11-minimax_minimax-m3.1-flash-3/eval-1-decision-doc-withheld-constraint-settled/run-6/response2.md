No — a decision doc would be overkill here.

The test is the landed state, not the debate: would a cold reader question the choice? They wouldn't, because the HLD tenet "no runtime network access is permitted" eliminates the HTTPS directory and the managed search service outright — a kiosk with no network route can't be served by either. The option set collapses to one survivor, which is exactly the "one line of rationale settles it" case for a Decisions & Alternatives row (`registry-design.md:64`).

It also stays inside one segment: the certificate interface is unchanged, so nothing in the certificates node leans on the reasoning, and no other node is sized around the result. The residue that *does* stay live is the cost the choice buys — per-kiosk rebuild on every snapshot, and what happens when an index is lost — and that already has a row (retained snapshot) and an open item (rebuild trigger).

If you want the reasoning preserved more durably, the row is the place to widen it, not a new file under `docs/intent/registry/decisions/`.