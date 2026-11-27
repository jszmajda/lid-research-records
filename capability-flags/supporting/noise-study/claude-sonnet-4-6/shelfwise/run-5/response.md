---

## Shelfwise — LID Coach Report

**Design-first and coherent; arrow ready to grow into implementation.**

---

### Scorecard

- ✓ **HLD discipline** — clean architecture and rationale; no implementation detail upstream
- ✓ **Decision capture** — decisions tables in both LLDs are substantive and cold-readable
- ✓ **Mutation hygiene** — docs are clean; no change-narration residue, no `[obsolete]` markers
- ✓ **LLD granularity** — two components, two LLDs; scope is appropriate and non-overlapping
- ⚠ **Arrow completeness** — EARS phase is settled; test and code phases have not been established yet
- ⚠ **LLD sufficiency** — a hold-cancel edge case and the patron contact channel interface are underspecified
- ⚠ **Configuration** — `## LID` block present with mode marker, but no LID directive declaration in the instruction file

The HLD and both LLDs are well-formed and cleanly linked, with substantive decisions tables that a cold reader can follow; the fastest wins before implementation begins are wiring up the instruction-file directive declaration, closing the hold-cancel edge case, and surfacing the patron-data interface assumption.

---

### Findings (8 total · 1 high · 4 medium · 3 low)

- **F1 (high):** CLAUDE.md has a `## LID` block and mode marker but no LID directive declaration (`linked-intent-dev` / `Linked-Intent Development` absent) · *modes are declared, not inferred*
- **F2 (medium):** Arrow is at the EARS stage — no test or code files exist in the project; `[x]` markers on specs signal the design is settled, making this the natural next phase to build · *canonical arrow shape*
- **F3 (medium):** Hold-cancel edge case unspecified — HOLDALLOC-007 covers in-transit cancellations, but neither the design narrative nor any spec addresses what happens when a patron cancels a hold that is already allocated and sitting on the holds shelf · *LLDs close enough of the solution space*
- **F4 (medium):** Patron contact channel ownership is implicit — pickup-notices assumes patrons have a "chosen channel" with no indication of where that data is stored, who owns it, or how Shelfwise reads it; a fresh author implementing PICKUP-002 would be guessing at the interface · *docs carry current intent, written to be read cold*
- **F5 (medium):** HLD Goal 1's 4-business-hour SLA is ambiguous for cross-branch holds — courier transit "runs once a day," which can exceed the goal window; the doc is silent on whether transit holds are excluded from the SLA or held to a different metric · *docs carry current intent, written to be read cold*
- **F6 (low):** "Hold history is not kept" reads as a Key Design Decision (a choice already made, with tradeoffs) rather than a forward-looking tie-breaker tenet; it fits better as a Decisions & Alternatives row in the HLD, which would name what was rejected and the accepted cost · *tenets capture forward-looking preference*
- **F7 (low):** HLD has no explicit target users or non-goals sections — a cold reader knows the system handles patron holds but not who specifically is served (staff? patrons? both?), and what Shelfwise explicitly does not do (fine management, cataloging, patron account management) · *HLD is architecture and rationale*
- **F8 (low):** The specific hold cap of 15 is unattributed in the decisions row — whether 15 is library policy, a configurable default, or an arbitrary number is not stated; noting its source would let a future agent know whether it is load-bearing · *LLDs close enough of the solution space*

---

### What Was Audited

- **Read fully:** CLAUDE.md, `docs/high-level-design.md`, `docs/intent/hold-allocation/hold-allocation-design.md`, `docs/intent/hold-allocation/hold-allocation-specs.md`, `docs/intent/pickup-notices/pickup-notices-design.md`, `docs/intent/pickup-notices/pickup-notices-specs.md`
- **Enumerated:** 2 LLDs, 2 spec files, 13 specs total (7 `HOLDALLOC-*`, 6 `PICKUP-*`)
- **Arrow-maintenance overlay:** not installed (`docs/arrows/` absent); no drift index to sample
- **Code and test sampling:** no source or test files present in the project; `@spec` annotation coverage cannot be assessed
- **Cold-read pass:** performed across all six LID docs

---

### Capability-Flag Note

The `references/capability-flags.md` file from the core `linked-intent-dev` skill was not accessible in this session. I cannot assess which capability flags apply to this model class. **Worth a second look:** please check the tenet-vs-KDD boundary yourself (F6) and verify that the four tenets remain coherent tie-breakers as the implementation phases develop — models in the Sonnet class can misplace the line between live tenets and captured decisions.

---

Want me to walk through any of the findings in detail, focus on a theme or priority tier, or work through a specific item together?

If you have broader questions about using LID for this project — how to structure the test phase, when to introduce a `docs/arrows/` overlay, or what to do as the system grows beyond two components — I can help with those too.