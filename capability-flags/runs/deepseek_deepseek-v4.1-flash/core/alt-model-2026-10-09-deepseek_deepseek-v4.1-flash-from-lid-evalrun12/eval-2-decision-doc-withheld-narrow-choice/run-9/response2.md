Honest answer: I don't think it clears the bar for a full decision doc, and the fact that it took three meetings and 180 messages doesn't change that — the test is applied to the *landed* design, not to how hard it was to reach.

Two of the three conditions hold: the options were credible and traded against several criteria (bookkeeping, retention, scan resistance, tuning). The third doesn't. A decision doc earns its place when the choice stays live *for a cold reader of the result* and other design nodes get sized around it. Here the eviction policy is private to the preview worker — the review API explicitly never reads eviction metadata, the HLD keeps replacement bookkeeping private, and no other node is built on top of 2Q. Nothing downstream would re-litigate it; the Decisions & Alternatives row I added already names the alternatives and the rationale a cold reader would need to reconstruct the choice.

The skill is explicit on this one: don't write one for a choice that affects only its own node, however long the debate ran. A directory of decision docs for node-local calls is itself a smell.

That said, you're the user and always right — if you still want one, say so and I'll write `docs/intent/previews/decisions/2q-eviction.md` and link it from the row.

Either way I'm still holding at the Phase 2 stop. Approve the LLD as drafted (plus your calls on probe gaps 1–5), and I'll move to Phase 3 — the EARS draft.