Honestly, I don't think it earns one — and the reason is the one the LID test is most explicit about: it's judged from the **landed design looking forward**, not "was this hard to decide?" Three meetings and a 180-message thread are a *symptom*, not the test. The template says it plainly: "a table row can come out of a long argument."

Applied to this decision:
- **It affects only its own node.** Every change stays inside the preview cache — API, render queue, fixed interface, and 12 GiB budget untouched, and the HLD tenet keeps replacement bookkeeping private to the worker. No other design node is sized around the result. The skill says not to create a decision doc for such a choice, *however long the debate ran*.
- **A cold reader won't re-litigate it.** The HLD Problem already states the workload (long sequential screenings alternating with repeated comparisons of a small set), and the Decisions & Alternatives row I recorded answers "why 2Q and not LRU?" in one line. That's the "a line settles it" case, not one needing weighted criteria a future reader must re-run. (The template even flags that a decision citing no tenet is a signal of a purely local choice — which this is.)
- **A doc here would be residue.** It would mostly memorialize deliberation that doesn't travel, exactly what *docs carry current intent* strips, and it sets a precedent — "a directory full of decision docs is a smell."

So my recommendation: keep the row (already in the LLD), no decision doc.

That said — you're always right. If you want it anyway, I'll write it with the cost visible: it'd live at `docs/intent/previews/decisions/cache-replacement-policy.md`, owned by the previews node, carry no EARS IDs, be linked from the Decisions row, and be written cold — context, gates + weighted criteria, all three options at their strongest, a Selection naming the tenet it turns on — with no trace of the thread or "we picked it to stop arguing."

Do you want me to write it anyway, or keep the row?

We're still at the Phase 2 stop: after you rule on this I also need your triage of the probe gaps, your ruling on the HLD line removal, your inspector choice, and explicit approval before Phase 3 (EARS). Nothing downstream has been drafted.