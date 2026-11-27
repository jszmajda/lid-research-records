A table row is sufficient — this doesn't need a decision doc.

Apply the test from the landed state: once implemented, would a cold reader question this choice or try to reverse it? The HLD tenet "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" rules out both the HTTPS directory and managed search service during normal operation. With that constraint in place, SQLite reads as the natural choice, not a live fork.

The Decisions & Alternatives row you have captures the options considered and why SQLite fits the constraints. That's enough for a reader to understand the choice without re-running the deliberation.

Decision docs are for choices that stay genuinely live even after landing — where credible alternatives remain and a future reader might re-litigate without seeing the full criteria. This one settles cleanly.