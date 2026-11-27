**Shelfwise · LID coaching review**

**Posture:** Healthy design foundation, with configuration and one design-edge gap to close.

**Scorecard**
- ✓ HLD discipline — problem, approach, tenets, and goals cleanly separated; no schema or code detail bleeds upstream
- ✓ Mutation hygiene — docs read as current intent; no `[obsolete]` markers, no change-narration, no changelog residue
- ✓ Linkage hygiene — spec IDs are grep-friendly, zero-padded, and prefix-stable across both spec files
- ⚠ Configuration — the `CLAUDE.md` `## LID` block carries a mode marker but no directive block pointing at the `linked-intent-dev` plugin
- ⚠ Tenet quality — three tenets read as real leans; one is a fixed policy dressed as a tenet
- ⚠ LLD sufficiency — allocation's entry-point trigger (how a hold gets placed) has no design node

**Headline:** The arrow is coherent from HLD through EARS across both components with clean tenets and disciplined specs; the fastest wins are reconciling the instruction file and closing the hold-placement entry point.

---

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` has a `## LID` block with `- Mode: Full` but no `linked-intent-dev` directive block · *modes are declared, not inferred*
- **F2 (high):** Hold-placement flow (what triggers `HOLDALLOC-001`, what channel it enters on) is unaddressed in the hold-allocation LLD · *LLDs close enough of the solution space*
- **F3 (medium):** Tenet "Hold history is not kept" reads as a fixed policy / non-goal, not a tie-breaker lean · *tenets capture forward-looking preference*
- **F4 (medium):** Hold cap decision row records "15 per patron" but doesn't defend the number (why 15, not 10 or 20) · *docs carry current intent* (decision capture)
- **F5 (medium):** "Re-run allocation as a check-in" is invoked from both `HOLDALLOC-007` and `PICKUP-005` without a named contract at the allocation boundary · *coherence is adjacency*
- **F6 (low):** Spec files carry no `prefix:` frontmatter — the `pickup-notices/` → `PICKUP-*` and `hold-allocation/` → `HOLDALLOC-*` mapping is inferred from the ID string · *effective intent-tree alignment*
- **F7 (low):** Tenets are an unordered list; the "patrons hear once" vs. staff-exceptions-list flow shows the tenets can pull against each other · *tenets capture forward-looking preference*

---

**What was audited**
- Read fully: `CLAUDE.md`; `docs/high-level-design.md`; both LLD design files under `docs/intent/hold-allocation/` and `docs/intent/pickup-notices/`; both `*-specs.md` files
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs total (7 HOLDALLOC, 6 PICKUP), 4 tenets, 7 decision rows
- Sampled: N/A for tests or code — no test files or implementation code exist yet in the tree
- Overlay: `docs/arrows/` not present, so no `index.yaml` cascade signals to draw on
- Dispatch note (non-interactive default taken): the instruction file omits the LID directive block but the project is LID-shaped (populated HLD, LLDs, and specs), so per the skill's dispatch table I proceeded with a full review anchored on the existing artifacts and surfaced the missing directives as F1

---

**Worth a second look:** models in my class are known to miss designs that quietly contradict the project's own tenets. Please spot-check the leaf designs against the four HLD tenets yourself — especially "patrons hear once, clearly" against the failed-delivery / exceptions-list flow, where the staff-callback loop can be read as a second contact attempt in disguise.

---

Want me to walk through the findings in detail, focus on a theme or priority (e.g., the two high-priority items), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID for Shelfwise — where a product spec fits above the HLD, how to organize once a third component appears, when to add the arrow-maintenance overlay, or how to prepare the arrow for the tests-and-code phases — I can help with those too.