It would be overkill. The Decisions & Alternatives row in the registry LLD is enough.

The test for a decision doc is whether a cold reader of the finished design would question the choice or be tempted to reverse it. How hard it was to decide doesn't count, and you did go back and forth on it.

- **The HLD already settles it.** The tenets say all lookup completes from files on the kiosk, with no runtime network access and no network route in normal operation. The HTTPS directory and the managed search service both break that. A cold reader would see the constraint, not a live trade-off.
- **The row carries the reasoning.** It names the two rejected options, why they lose, and what SQLite costs: each kiosk validates and rebuilds its own index per snapshot.
- **It only affects the registry node.** The certificates interface is the same under every option, so no other node is sized around this choice.

Your own sense that the options looked close is mostly because the sketch weighed them on operational trade-offs alone. The HLD's offline tenets had already ruled out two of the three.

A decision doc would make sense if the offline constraint were later relaxed, for example if kiosks gained a lab network route. At that point the HTTPS directory becomes a real contender, and a full write-up of the criteria would help. If you want one anyway, I can write it under `docs/intent/registry/decisions/` and link it from the row.