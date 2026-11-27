Overkill, in my read — the row is the right level. Here's the test I'm applying, which is the landed-state one, not how hard it was to decide:

A full decision doc earns its place only when the choice stays **genuinely live for a cold reader** — someone would re-litigate it without the competing options laid out — *and* other design nodes are about to be sized around the result. This choice fails both halves:

- **It lands inside one node.** The `findBySerial` interface and result types are identical under all three options, so nothing downstream gets shaped by the pick. The skill specifically says not to open a doc for a choice that affects only its own node, however long the debate ran.
- **An inherited constraint does much of the settling.** Your no-runtime-network tenet already rules against the HTTPS directory and the managed service — they'd need a tenet change to be viable. That's the other explicit "don't bother with a doc" case.

That said, it *isn't* a nothing — a cold reader landing on `registry-design.md` would reasonably ask "why not the centrally-maintained index?", and the Decisions & Alternatives row answers exactly that: the three options, the tradeoffs, and the tenet that trims two of them. So a row, not silence, and not a doc.

The fact that it felt close while you worked is real, but it's deliberation, not the landed shape — and docs accumulate; a `decisions/` directory full of settled-obvious calls is its own kind of noise.

If you'd still like the fuller artifact — say, because you expect the no-network tenet itself to come under pressure later and want the networked options preserved at full resolution for that day — I'm happy to write one and link it from the row. Otherwise I'd leave it as the row and move on to the Phase 2 triage.