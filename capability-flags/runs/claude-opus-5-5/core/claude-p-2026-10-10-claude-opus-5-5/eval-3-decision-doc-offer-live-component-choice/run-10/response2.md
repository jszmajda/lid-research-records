The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md` and linked from the concurrency row in the record-store design. Nothing is committed.

## What it says

**The criteria.** There are five, each tied to a tenet or goal where one applies:

| Criterion | Weight | Whole-visit revisions | Field-aware merge |
|---|---|---|---|
| Integrity of the current visit | major | strong | weak |
| Coordinator workload and export readiness | major | weak | strong |
| Logic the team must keep correct | moderate | strong | weak |
| Explaining one exported value | moderate | strong | partial |
| Burden on the tablets | minor | strong | partial |

**Why whole-visit wins.** The two major criteria point opposite ways, so the choice is which failure you would rather live with. A long review queue is visible and recoverable: a held visit goes out the next Friday. A wrongly combined visit carries no mark and is exported as reviewed data.

**Why merge is still worth considering.** It is the only option that keeps review proportional to real disagreement. The doc names three conditions for reopening it:
- Visits are regularly held out of the Friday export because coordinators cannot clear the queue.
- Revision history shows most competing revisions touch different fields. Every revision is kept with its starting point, so this can be measured from real seasons.
- The team gains someone who can own merge rules as the protocol changes.

It also notes that reopening would not mean starting over: the stored history has everything a three-way comparison needs. A narrower version, such as merging only field pairs you have declared independent, or proposing a combined visit for a coordinator to approve, would not change what tablets send.

**What tablet-sync must accommodate.**
- Keep the starting revision ID for each visit and send it with the next edit.
- Send the whole visit on every edit.
- Submit offline edits to one visit in order.
- Tell the worker when an accepted edit is competing, not current.
- Expect a visit it thought was settled to have changed when it reconnects.

**What review-export must accommodate.**
- A side-by-side comparison of complete visits against their common starting point, working out the field differences itself.
- A resolution step that selects one revision or enters a replacement, with a way back when another revision arrived mid-review.
- A CSV of settled visits only, with held visits visible to coordinators before Friday.
- A queue sized for every independent correction, not only real disagreements.

## Things to check

- **The weights are mine.** I rated integrity and coordinator workload as major, maintained logic and explainability as moderate, and tablet burden as minor. Correct any that don't match how you see it.
- **The reopening conditions have no numbers.** I did not invent a threshold for "regularly held out" or "most"; give me figures if you want them pinned.
- **The downstream lists assume the design as drafted.** If your triage of the eight gaps changes the contract, I'll update the doc to match.

## Still open from last time

I still need your approval or numbered changes to the record-store design and your triage of the eight gaps. Once I have those I'll revise the specs for your review.