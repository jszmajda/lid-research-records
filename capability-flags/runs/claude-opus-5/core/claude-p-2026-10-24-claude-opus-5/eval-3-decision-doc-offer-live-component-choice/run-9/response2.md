Written: `docs/intent/record-store/decisions/concurrent-visit-edits.md`, linked from the Decisions row (which is now one line plus the pointer, rather than restating the argument) and from References.

**How it's structured**

- **Context** — the domain situation only: 24 workers, 12 shared tablets, 48-hour offline windows, workers comparing notes in the evening. It names what's at stake if the decision is wrong, which is not "delay" but corruption: a record combining two workers' observations into something neither submitted is worse for the science partner than a record arriving a week late.
- **Decision Elements** — one gate (*no submitted edit silently discarded*, inherited from the HLD tenet) which is what eliminates last-write-wins, and seven weighted criteria. Two are major: integrity of scientifically related edits, and inspectability from submission to exported value. Each major criterion names the tenet or non-goal it turns on.
- **Options** — whole-visit revisions, field-aware three-way merge, and last-write-wins. Each gets a per-element verdict (strong/partial/weak, or passes/eliminated for the gate).
- **Selection** — whole-visit revisions, why it wins on the majors, what it forecloses, what it obligates downstream.

**Why we'd still consider merging** — the merge option is written as its advocate would write it, and it genuinely wins three criteria: review workload (**strong**), export timeliness (**strong**), and smaller submissions. Its demonstration shows it resolving the observer-name-plus-new-species case with no human involvement. The case against it is stated as a property of the approach rather than of any particular rule set: its worked example is one worker revising an identification from *Salicornia virginica* to *Sarcocornia pacifica* while the other revises that entry's cover from 15% to 25% against the old identification — field-level rules yield "25% cover of *Sarcocornia pacifica*", a figure neither worker estimated, reported as a clean merge. Making the species entry one merge unit catches that pair and relocates the same question to the next pair whose relationship the rules don't encode. I also kept the point the design doc had already made: requiring manual approval of merged records closes the integrity hole, and closes the workload advantage with it. Selection ends with the conditions under which a reader should re-run the judgment — and notes the question would then be narrower than the one settled here.

**What the tablet and export work has to accommodate** — in Selection, and I also folded the two new obligations into the design's own Downstream Obligations so siblings read them from the contract rather than the decision record:

- **tablet-sync** — retain a base revision ID per draft across restarts and multi-day disconnection; present a contested visit as competing versions, not an editable record; treat a rejected base revision ID as a stale/corrupt local record rather than a transient failure, since retrying it is pointless.
- **review-export** — side-by-side heads with author and receipt time, both resolution forms, contested visits held out of the CSV; and the count of held-back visits is coordinator-facing, because backlog *is* export delay.

**Still open from the last stop** — you went straight to the doc, so these are unanswered and I haven't assumed anything:

1. The eight probe gaps. Four I'd fix in the design now (rejection shapes; replay returning current state; idempotency key scope plus a key on Resolve; reject a missing base on an existing visit; gapless sequence). Three are yours: whether an edit based on a superseded head re-contests the visit, whether a plot UUID may change on an edit, and who is authorized to resolve.
2. Whether `settled` / `contested` / `head` stay in record-store or rise to the HLD, now that the decision doc uses them too.

Say "your recommendations" and I'll apply the four, or answer the three. Either way, Phase 3 — rewriting `record-store-specs.md` — waits for your go.