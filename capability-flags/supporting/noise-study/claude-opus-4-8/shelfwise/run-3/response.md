I have everything I need. One note: the sibling-skill `references/capability-flags.md` sits outside this run's readable paths, so per the skill's rule ("if you cannot place yourself, treat the flags as applying") I include the capability-flag note.

---

## LID Coach — Shelfwise

### Executive summary

**Posture:** *Solid design layer; configuration catch-up and one uncaptured tenet tradeoff are the open items.*

**Scorecard**
- ✓ **HLD discipline** — architecture and rationale only; no schemas, signatures, or algorithm detail bleeding upstream
- ✓ **EARS specs** — clean event/state/conditional forms, unique namespaced IDs, well-scoped WHEN clauses
- ✓ **Mutation hygiene** — no history residue, changelogs, or `[obsolete]` markers anywhere
- ✓ **Decision capture (mostly)** — Decisions & Alternatives tables are unusually good; one gap (F2)
- ⚠ **Configuration** — the instruction file carries the `## LID` mode block but not the linked-intent-dev directive block
- ⚠ **Arrow completeness** — HLD → LLD → EARS is walkable; the tests and code phases aren't present in the repo

**Headline:** The design layer here is genuinely strong — a lean HLD with real tie-breaker tenets, two cleanly separated LLDs, well-formed EARS specs, and Decisions & Alternatives tables that name the rejected option *and* the accepted cost (the exception, not the rule). The two highest-value next steps are reconciling the instruction file with `/update-lid` and capturing the branch-locality-vs-sequence routing tradeoff in the hold-allocation LLD.

### Findings (5 total · 2 high · 1 medium · 2 low)

- **F1 (high):** `CLAUDE.md` declares `## LID` (Mode: Full, Version 1.4.0) but has no linked-intent-dev directive block telling an agent how to operate under LID · *modes are declared, not inferred* — the mode is visible but the operating directives are a default rather than on the page
- **F2 (high):** The branch-locality rule (HOLDALLOC-003 preferring a local hold over an earlier county-wide one in HOLDALLOC-004) is in tension with the "Waiting is honored in sequence" tenet, and that tradeoff appears nowhere in hold-allocation's Decisions & Alternatives · *docs carry current intent* (decision capture) — a later local requester can be served before an earlier remote one, and no row records that this was chosen for courier efficiency
- **F3 (medium):** All 13 specs are marked `[x]` complete, but no tests or code in the repo cite them; the tests and code phases of the arrow aren't present to walk · *tests before code* / *coherence is adjacency* — either implementation lives outside this repo (arrow's lower half not walkable here) or the completion markers are ahead of reality
- **F4 (low):** Spec files carry no `prefix:` frontmatter to anchor the leaf path (`HOLDALLOC`, `PICKUP`) authoritatively · *specs are grep-anchored linkage* — prefix→LLD resolution currently rests on filename convention alone
- **F5 (low):** The four HLD tenets are an unordered list, though two can brush against each other ("Patrons hear once" vs. the staff-exceptions call path) · *tenets capture forward-looking preference* — ordering says which leans wins if a future tenet genuinely conflicts

### What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/hold-allocation/{hold-allocation-design.md, hold-allocation-specs.md}`, `docs/intent/pickup-notices/{pickup-notices-design.md, pickup-notices-specs.md}`
- **Inventory:** 2 components · 2 LLDs · 2 spec files · 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`)
- **Overlay:** none — `docs/arrows/` absent (a valid choice, not a gap); no tests or code files present in the repo
- **Sampling:** small project — the arrow-path sampling thresholds (>15 LLDs or >200 `@spec` annotations) were not reached, so review was exhaustive rather than sampled

### Worth a second look

I can't read this environment's `capability-flags.md`, so per the skill I treat the flags as applying. Models in my class are known to miss designs that quietly contradict a project's own tenets — F2 is exactly that shape. Please sanity-check the allocation ordering against the "Waiting is honored in sequence" tenet yourself, and skim the other three tenets against their leaf designs.

### Where to take fixes

- **F1** → `/update-lid` (reconciles the instruction file's directive block against the declared Full mode)
- **F2, F4, F5** → direct edits to the LLD / spec / HLD; F2's remedy is a new Decisions & Alternatives row naming the rejected strict-FIFO alternative and the accepted cost (earlier remote patrons occasionally wait a cycle to keep copies off the daily courier van)

---

Want me to walk through the findings in detail, focus on a theme or priority (say, just the two high-priority items), or work through a specific one — F2's decision row is a good candidate to draft together?

If you have broader questions about using LID on Shelfwise — when the arrow overlay is worth installing, where a PRD would sit above this HLD, or how the tests/code phases should attach as you build — I'm happy to think through those too.