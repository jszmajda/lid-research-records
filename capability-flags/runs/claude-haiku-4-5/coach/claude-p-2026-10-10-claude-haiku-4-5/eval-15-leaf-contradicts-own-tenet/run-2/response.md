---

## Shelfwise LID Review

**Posture:** Solid foundation — the design layer is clean and ready for implementation.

**Scorecard**
- ✓ Arrow shape — HLD, LLDs, specs present and phased correctly (Full mode, canonical shape)
- ✓ Spec-to-LLD alignment — all specs trace clearly to their design components
- ✓ HLD discipline — architecture-level rationale, no implementation detail bleeding
- ⚠ Linkage hygiene — spec ID abbreviations lack consistency across components
- ⚠ Tenet precedence — tenets are real tie-breakers but lack explicit ordering for conflicts
- ✓ Mode fit — Full mode matches a project-wide design adoption

**Headline:** The design foundation is strong — clear problem, well-chosen tenets, two well-scoped components with spec-to-design alignment. The fastest wins are in cleaning up ID naming consistency and clarifying tenet precedence.

---

**Findings (4 total · 0 high · 3 medium · 1 low)**

- **F1 (medium):** Spec ID abbreviations lack consistency · *specs are grep-anchored linkage*  
  Hold allocation uses `HOLDALLOC-` (full abbreviation of both words) while pickup notices uses `PICKUP-` (first word only). Consider standardizing to make tree paths explicit in IDs—e.g., `PICKUPNOTICE-001` or `PICKUPNOTICES-001`—so grep results immediately clarify which component owns a spec.

- **F2 (medium):** Tenets lack explicit ordering · *tenets capture forward-looking preference*  
  The tenets are genuine tie-breakers (e.g., "waiting honored in sequence" has a real opposite), but don't rank when they conflict. The Pickup Notices design actually chooses "staff exceptions list" over auto-fallback—honoring "patrons hear once" over "staff attention on exceptions"—but the choice is only visible by reading the decision table, not from the tenets themselves. When multiple tenets could trade off, an ordering clarifies which leans stronger.

- **F3 (medium):** Channel-selection mechanism is implicit context · *docs carry current intent, written to be read cold*  
  PICKUP-002 and the design assume "patron's chosen channel" exists, and the Context mentions patrons choose "at signup," but a fresh reader can't tell when/how patrons set or update it, or what happens if no choice is stored. Consider adding a sentence to Pickup Notices design explaining the selection mechanism and where it's configured.

- **F4 (low):** Arrow overlay not installed · *verticalize intent*  
  The arrow-maintenance overlay (`docs/arrows/index.yaml`) would track component dependencies—e.g., that hold allocation is a prerequisite for pickup notices—and make the arrow walkable at a glance. Full mode doesn't require it, but an overlay adds value once implementation starts. This is an optional enhancement.

---

**What was audited**
- Read fully: CLAUDE.md (mode declaration), high-level-design.md, hold-allocation-design.md, hold-allocation-specs.md, pickup-notices-design.md, pickup-notices-specs.md
- Components reviewed: 2 LLDs, 13 EARS specs (7 + 6), design decisions across both with explicit trade-off capture
- Arrow path sampling: spot-checked spec-to-design alignment across both components; decision tables for tenet/goal coherence
- Project state: bootstrapping (no implementation code or tests yet; no arrow overlay)

---

**Capability note:** This model/effort level is not known to have blind spots in this review area. No caveats apply.

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — when to start implementation, how to wire @spec annotations in tests once code lands, handling the transition from design-heavy phase to maintenance mode — I can help with those too.