It would be overkill — the Decisions & Alternatives row in `registry-design.md` is the right weight here.

The test for a decision doc is whether a cold reader of the *landed* design would still see a live trade-off they might re-litigate — not how much back-and-forth it took to settle. Here:

1. **Inherited HLD constraints settle it:** `docs/high-level-design.md` prohibits runtime network access and cloud/remote services on kiosks, which eliminates both the on-site HTTPS directory and the managed search service outright. A cold reader wouldn't reopen those without changing the HLD first.
2. **Contained to one node:** The backend is private to `registry`; `certificates` isn't sized around it and its interface doesn't change.

A single table row in `registry-design.md` gives a future reader everything they need without adding an extra doc to maintain. (If you still want a standalone decision doc anyway, say the word and I'll draft one.)

Whenever you're ready, let me know how you'd like to triage the Phase 2 probe items (1–7) and whether `registry-design.md` is good to move to Phase 3.