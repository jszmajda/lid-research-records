Now I'll perform the LID Coach review according to the skill's instructions:

# LID Coach Review — printfarm

## Executive summary

**Posture: Bootstrapped — HLD and LLDs present and well-shaped; tests and code not yet started.**

**Scorecard**
- ✓ HLD architecture — clear problem/approach, two named nodes, good tenets
- ✓ LLD granularity — two clean leaf nodes trace to HLD
- ✓ Design content — both LLDs name context, architecture, Decisions rows
- ⚠ Tenet ordering — three tenets could conflict but aren't ordered
- ✗ Arrow completeness — EARS present but tests and code missing
- ✗ Linkage hygiene — no test or code layer to audit for `@spec` coverage
- n/a Most dimensions — nothing to flag in a design-only project

**The HLD and LLD layer are genuine, coherent, and bootstrapped correctly. The fastest value now comes from walking one feature through tests-first → code to validate that the design is walkable.**

## Findings (3 high · 3 medium)

- **F1 (high):** tests and code not yet present · *arrow completeness*
- **F2 (high):** no artifact to validate that designs close enough solution space · *LLD sufficiency*
- **F3 (high):** design specifies FIFO scheduler but queue-head return-on-failure creates priority inversion when one printer's class has flaky network · *coherence across adjacent levels of intent; tenet cascade*
- **F4 (medium):** three tenets could conflict and aren't ordered · *tenet quality*
- **F5 (medium):** QUEUE-002 and QUEUE-003 live in an accept-then-dispatch race · *scope disambiguation*
- **F6 (medium):** spec status markers are checkboxes, common but not LID-canonical · *minimum system*

## What was audited

- Read fully: CLAUDE.md, docs/high-level-design.md, both LLD design files, both spec files
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 specs total
- Verified: no arrow-maintenance overlay, no tests, no code, no git history beyond bootstrap
- Project state: design-only bootstrap — the HLD and LLD layer exist; tests and code do not

## Findings detail

### F1 (high): Tests and code not yet present

**Principle:** *Canonical arrow shape* — `HLD → LLDs → EARS → Tests → Code`.

**What I see:** Complete and coherent HLD/LLD/EARS layers. No tests, no code.

**Why it matters:** The design layer looks good on the page, but until tests and code exist the project has no evidence that these designs are *walkable* — that two agents reading the same LLD would land on compatible implementations, that the specs close enough of the solution space. Designs feel complete in conversation but reveal gaps the moment implementation starts. Tests-first is when that validation happens.

**Next step:** Pick one behavioral spec — `QUEUE-002` (dispatch head job to idle printer) is a good candidate — and walk it through Phase 5 (tests-first) and Phase 6 (code). The LLD will either hold up or surface edges that need tightening, and you'll know whether the arrow works before authoring the rest.

---

### F2 (high): No artifact to validate that designs close enough solution space

**Principle:** *LLDs close enough of the solution space* — specific enough that two reasonable agents would land on compatible implementations.

**What I see:** Both LLDs carry context, architecture paragraphs, and Decisions rows. The text is clear. But neither LLD has tests or code, so there's no forcing function yet to discover where the solution space is still open.

**Why it matters:** The gaps that matter show up during implementation. A design that reads well in isolation often leaves edges open — interface shapes, error paths, concurrency edges — that the agent fills in, and the fills drift from session to session. Tests-first is the discipline that closes those edges before code exists to embed the drift.

**Where to look for the gaps (once you implement):**

- **job-queue:** how do reordering commands encode priority (is "staff job" a boolean on the job, or two separate lists)? What does "return to head" mean when the original job was at position 3? Does dispatch pull synchronously or does the registry push idle events?
- **printer-registry:** what's the schema for the state enum (unreachable / idle / busy — anything else)? When a heartbeat sees state "printing job X" and the queue thinks it dispatched job Y, who wins?

Neither LLD is *wrong* — they're just untested. Walk one feature through and tighten where you find open edges.

---

### F3 (high): Design contradicts the project's own tenet under a condition the design itself describes

**Principle:** *Tenet cascade* — designs lean the way tenets and goals say to lean. When they don't, and no Decisions row records the exception, flag it.

**The tenet:** "A submitted job is a promise: members should be able to upload and walk away."

**The mechanism:** job-queue-design.md:21 — "On dispatch failure (printer rejects or times out), the job returns to the head of its class queue."

**The condition:** A printer class with one flaky printer and one stable printer. Job A dispatches to the flaky printer, times out, returns to head. Job B (arrived later) is now blocked behind A even though the stable printer in the same class went idle. Job A will retry the flaky printer on the next idle event for that class, fail again, return to head again — job B waits indefinitely while A monopolizes dispatch attempts. The member who submitted B uploaded and walked away, but their job isn't a promise under this design — it's stuck behind a retry loop.

**Why it matters:** The tenet says the queue should be load-bearing enough that members trust it. The design as written creates a priority inversion the moment network flakiness enters the system, which the HLD's context (mini-PC taking "the occasional power blip") says is expected. Future sessions implementing this design will encode the inversion, and it will surface as a user-visible bug ("my job sat in the queue for an hour even though printers were idle").

**Remedies (your choice):**

1. **Change the design.** Dispatch failure moves the job to *tail* instead of head (you lose retry-promptness but keep FIFO); or the job re-enters at its original position; or dispatch pulls from a smarter scheduler that skips jobs whose target printer was recently marked suspect.
2. **Record the tradeoff.** Add a Decisions row: "Dispatch retry position → head of queue; this can block later jobs when one printer is flaky; accepted because prompt retry is more valuable than strict FIFO under failure." Now the inversion is load-bearing intent, not an oversight, and future sessions won't "fix" it by accident.
3. **Revise the tenet.** Weaken "a submitted job is a promise" to acknowledge that network failures can delay dispatch beyond queue position. (Least likely — the tenet as stated is good; the design can meet it with a position-aware retry or smarter dispatch.)

I don't pick for you — this is your design, and the choice has downstream consequences. But the current state (tenet vs. mechanism, under a condition the docs name, with no Decisions row acknowledging it) is drift.

---

### F4 (medium): Three tenets could conflict and aren't ordered

**Principle:** *Tenet quality* — tenets are tie-breakers; when more than two could conflict, order them.

**What I see:** HLD carries three tenets. Tenet 1 ("a submitted job is a promise") could conflict with Tenet 2 ("staff override members, but the queue explains itself") when a staff reorder delays a member job that was next in line — the member's promise just got broken by staff priority. Tenet 3 ("the mini-PC is modest hardware; the service stays small") doesn't obviously conflict with the others but could in a future design discussion (e.g., should the service log every dispatch event for audit, or does that bloat the mini-PC's disk?).

**Why it matters:** When tenets conflict and the order isn't declared, an agent facing a tied decision samples from its own distribution instead of the project's preference. Ordering the tenets picks which one wins when two pull opposite ways, and the choice is stable across sessions.

**Next step:** Decide which tenet dominates when they conflict, and number them in that order in the HLD. If you judge they don't conflict in practice, note that in a sentence after the list so future readers (including future you) know the ordering question was considered.

---

### F5 (medium): QUEUE-002 and QUEUE-003 live in an accept-then-dispatch race

**Principle:** *Scope disambiguation* — a spec whose scope is narrower than its phrasing must carry that scope in its WHEN clause.

**What I see:**

- **QUEUE-002** (job-queue-specs.md:4): "When the registry reports a printer idle, the system SHALL dispatch the head job of that printer's class to it."
- **QUEUE-003** (job-queue-specs.md:5): "When a dispatch attempt fails, the system SHALL return the job to the head of its class queue and mark the printer suspect."

Both are phrased universally. But what happens when the registry reports idle, QUEUE-002 fires and pulls the head job, the dispatch starts, and *during the dispatch attempt* a second idle event arrives for a different printer in the same class? Does QUEUE-002 fire again with a now-empty queue (the head job is in flight but not yet failed)? Or does the spec's scope silently exclude in-flight jobs?

**Why it matters:** An agent implementing QUEUE-002 out of context — say, after a refactor where dispatch became async — will read the spec as written and dispatch to both printers, then handle the failure per QUEUE-003 when one times out. The code satisfies both specs literally but produces a race the design may not have intended. Scope disambiguation closes the gap: "When the registry reports a printer idle *and that printer's class queue has a job not currently in flight*, the system SHALL…". Now the spec says what it means.

**Next step:** Tighten QUEUE-002's WHEN clause if in-flight jobs should be excluded, or confirm that dispatching the same job to two printers simultaneously (and relying on QUEUE-003 to recover) is intended behavior. Either is defensible; the ambiguity is the problem.

---

### F6 (medium): Spec status markers are checkboxes, common but not LID-canonical

**Principle:** *Minimum system* — use the standard where it exists; custom conventions create learning overhead.

**What I see:** Both spec files use `[x]` checkbox syntax for status (job-queue-specs.md:3–7, printer-registry-specs.md:3–5). The specs are marked complete, which in a design-only project reads as "design is done; implementation not started."

**LID's canonical status markers** are inline tags: `[draft]`, `[active]`, `[obsolete]`. The checkbox syntax is unambiguous in this project but diverges from the standard, and future sessions or tools that expect the canonical markers won't recognize the project's state.

**Why it matters (low in this case):** The project is small and the convention is clear. But as the arrow grows and you start using tools that parse spec files — arrow-maintenance, or a future test-coverage linter — the custom syntax becomes friction. Adopting the standard now is cheaper than migrating later.

**Next step (optional):** Replace `[x]` with `[active]` (or `[draft]` if these specs are still being refined). If you prefer the checkbox syntax for workflow reasons, note the convention in CLAUDE.md so agents and future contributors know to expect it.

---

## Offer to help

Want me to walk through any of these findings in more detail, focus on the high-priority ones, or work through F3 (the tenet-vs-mechanism tension) together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.