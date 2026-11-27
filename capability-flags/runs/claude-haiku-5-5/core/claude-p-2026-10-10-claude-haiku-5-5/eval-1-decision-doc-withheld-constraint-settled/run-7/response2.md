I'd skip the decision doc. The Decisions row in `registry-design.md` is enough, for three reasons:

- **One option is ruled out by the HLD.** Both alternatives need a network route during kiosk operation, which the HLD tenets prohibit. A cold reader won't find the choice live, because the tenets already settle it.
- **It affects only the registry node.** The certificates node sees only `findBySerial`, so nothing else is sized around the backend. The skill reserves decision docs for choices that other nodes depend on.
- **The remaining cost is already accepted.** Per-kiosk index rebuilds on import were part of the trade-off you chose, so there's no open debate to record.

If you expect someone to revisit this, for example a future move to a shared server, the row already names the alternatives and the tenet they conflict with. That's the point where a decision doc would start to earn its place. If you'd still like one now, I can write it, but I'd recommend against it.