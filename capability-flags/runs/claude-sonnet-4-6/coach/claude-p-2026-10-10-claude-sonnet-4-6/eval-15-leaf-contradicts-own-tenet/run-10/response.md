---

## Shelfwise — LID Coach Report

**Posture:** Bootstrapping well — design and spec layers complete, implementation not yet started.

---

### Scorecard

- ✓ **HLD discipline** — architecture stays clean, no implementation detail bleeding upstream
- ✓ **LLD sufficiency** — both LLDs close the solution space well; decisions tables are solid
- ✓ **EARS specs** — IDs are correctly namespaced (HOLDALLOC-, PICKUP-), format is clean, no obsolete markers
- ⚠ **Tenet quality** — one tenet reads as a hard design constraint, not a forward-looking lean; 4 tenets are unordered
- ⚠ **Cold-read clarity** — pickup-notices Design prose has one context gap that leaves a cold reader uncertain
- ⚠ **Decision capture** — a load-bearing architectural choice (hold history) has its *what* stated but its *why* unrecorded

**Headline:** The arrow's design and spec layers are clean and well-reasoned; the fastest wins are a tenet rewrite to restore lean-not-rule phrasing and a brief decision-capture note on the hold-history choice.

---

### Findings (5 total · 0 high · 3 medium · 2 low)

- **F1 (medium):** Tenet "Hold history is not kept" is phrased as a hard constraint ("is not kept… is deleted"), not a forward-looking lean — a fresh author would write "prefer not retaining patron history" rather than a rule; its behavioral content is already covered by PICKUP-003 and PICKUP-005 · *tenet quality — tenets capture forward-looking preference*
- **F2 (medium):** `pickup-notices-design.md` Design prose names "bounced email, undeliverable SMS" when enumerating failed delivery, but the Context section names three channels (email, SMS, phone); a cold reader can't tell whether a failed automated-dialer call follows the same path · *docs carry current intent, written to be read cold*
- **F3 (medium):** The hold-history decision (delete closed hold records; never retain reading history) has no captured *why* — the tenet asserts the policy but records no rationale; a cold reader holding the HLD sees the rule but not what was weighed against it (e.g., analytics, debugging, legal) · *decision capture*
- **F4 (low):** 4 tenets are unordered; if a future decision puts "waiting honored in sequence" against "staff attention to exceptions," the lean priority is unspecified · *tenet quality — tenets capture forward-looking preference*
- **F5 (low):** HLD has no non-goals section; what Shelfwise explicitly won't own (catalog management, copy tracking, physical shelf layout beyond routing slips) isn't stated, leaving scope boundaries implicit · *HLD discipline*

---

### What Was Audited

- **Read fully:** CLAUDE.md, docs/high-level-design.md, docs/intent/hold-allocation/hold-allocation-design.md, docs/intent/hold-allocation/hold-allocation-specs.md, docs/intent/pickup-notices/pickup-notices-design.md, docs/intent/pickup-notices/pickup-notices-specs.md
- **Enumerated:** 2 LLDs, 2 spec files, 13 total specs (HOLDALLOC-001–007, PICKUP-001–006)
- **Arrow-path sampled:** both components end-to-end through the design and spec layers; implementation layers (tests, code) not yet present in the repo
- **Arrow-maintenance overlay:** not installed (`docs/arrows/` absent)
- **@spec annotations:** none expected; no code or test files exist yet

---

Want me to walk through any of the findings in detail, focus on a theme, or work through specific items together? You can also pick a finding by number to dig into.

If you have broader questions about using LID for Shelfwise — how to approach the tests-first phase as implementation starts, where the hold-history decision capture should land, or how mode might evolve as the project grows — I can help with those too.