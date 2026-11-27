# LID Coach — Shelfwise

**Posture line:** Bootstrapping — the design layer is in genuinely good shape; the arrow stops at EARS.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no implementation detail has crept in
- ✓ Tenet quality — `## Tenets` present, real tie-breakers with defensible opposites ("patrons hear once, clearly" has a live opposite), and the expiry/pull-list mechanism even records its tension with Goal 1 in a Decisions row
- ✓ Decision capture — both Decisions & Alternatives tables record chosen/rejected/cost at a depth a cold reader can re-run
- ⚠ Arrow completeness — arrow ends at EARS; no tests or code exist yet
- ⚠ Instruction-file directives — the `## LID` block (mode + version) is present, but the linked-intent-dev directive block is not

**Headline sentence:** The design docs are the strongest part of this project — two clean intent components, tight specs, and unusually good decision capture — and the most valuable next step is wiring the instruction file directives (via `/update-lid`) before the first code lands, so tests-first starts from a complete foundation.

**Findings (5 total · 2 high · 2 medium · 1 low)**

- **F1 (high):** the instruction file carries the `## LID` mode marker but none of the linked-intent-dev directives (no `linked-intent-dev` / "Linked-Intent Development" directive block) · *modes are declared, not inferred* — future sessions won't pick up the workflow from `CLAUDE.md` alone; run `/update-lid` to reconcile
- **F2 (high):** no tests and no code exist for either component — the arrow is not walkable past EARS · *tests before code* (tests preload the target system's use before implementation exists) — this is expected at your stage, but make the first implementation step tests citing HOLDALLOC/PICKUP IDs, not code
- **F3 (medium):** cross-boundary cascade without a pause: `PICKUP-005` re-runs allocation for lapsed copies, and the pickup design describes that behavior, but the hold-allocation design's re-run rule (hold-allocation-design.md:13) covers only cancelled-in-transit copies · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across* — the expiry path changes allocation's trigger surface, so hold-allocation's design should either own or note it
- **F4 (medium):** spec status markers `- [x]` are used, but nothing in the instruction file or skill conventions defines them, and "checked" on specs with no tests is ambiguous — does it mean reviewed, or verified? · *minimum surface, maximum discipline* — consider dropping the checkboxes or defining what they mean
- **F5 (low):** `PICKUP-004`'s "next morning's pull list" and the design's "morning pull list" are the same thing but neither doc says what generates the list or when the day starts — a cold reader has to guess · *docs carry current intent, written to be read cold*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLD design docs, both spec files (6 files total — the complete doc tree)
- 13 EARS specs reviewed across 2 intent components (HOLDALLOC-001–007, PICKUP-001–006)
- No code or test files exist, so no `@spec` sampling was possible (0 annotated files)
- No `docs/arrows/` overlay is installed, so no cascade-status or drift-flag review

**Defaults taken:** where the skill would ask, I proceeded with a full review anchored on the existing artifacts (default Full mode), omitted the capability-flag section (no flags apply to this configuration in `references/capability-flags.md`), and rendered the report inline without persisting anything to disk.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.