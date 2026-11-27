# `/lid-coach` report — printfarm

## 1. Executive summary

**Posture:** *Small and coherent; design layer is clean, arrow stops at specs.*

**Scorecard**
- ✓ Configuration — CLAUDE.md carries LID directives, Full mode, version 1.4.0
- ✓ HLD discipline — architecture and rationale; no schemas or code leaked upstream
- ✓ Mutation hygiene — no obsolete markers, no changelog residue, no `[inferred]` backlog
- ✓ Mode fit — Full matches a two-node project the user clearly intends to grow into
- ⚠ Coherence — a few LLD behaviors have no EARS spec, and printer-polling ownership straddles both nodes
- ⚠ LLD sufficiency — auth/roles, dispatch protocol, and the "printer class" concept are used without a home

**Headline:** The arrow you have — HLD → two LLDs → EARS — is well-shaped, tenets are real tie-breakers, and decision rows mostly hold up cold; the fastest wins are closing a handful of design-to-spec gaps and clarifying which node owns polling the printers.

## 2. Findings (6 total · 2 high · 3 medium · 1 low)

- **F1 (high):** Several `job-queue` design behaviors have no EARS spec (accept-only-if-class-has-printer; FIFO within staff/member classes; staff vs. member as a role) · *coherence is adjacency* — each level of the arrow agrees with its neighbor
- **F2 (high):** Printer-polling ownership straddles job-queue and printer-registry (QUEUE-004 polls printers directly for current job; printer-registry design owns heartbeats/state) · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F3 (medium):** LLD gaps — no design or spec for member/staff authentication, upload API, dispatcher protocol, or how a "printer class" is defined (referenced in both LLDs and HLD but never introduced) · *LLDs close enough of the solution space*
- **F4 (medium):** `printer-registry` "Registry store" decision row names neither the rejected alternative nor the accepted cost · *docs carry current intent* (the keep-side — decision capture)
- **F5 (medium):** HLD tenets are unordered; with three tenets that could realistically conflict (e.g., "members can walk away" vs. "service stays small" on a large-file queue day), the tie-breaker order is itself a tie-breaker · *tenets capture forward-looking preference*
- **F6 (low):** All specs carry `[x]` while no code or tests exist in the tree — worth confirming the convention (accepted-spec vs. implemented) so a future session doesn't read `[x]` as implementation evidence · *specs are grep-anchored linkage* (status-marker hygiene)

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 EARS specs total (5 QUEUE-*, 3 REG-*), 3 tenets, 5 Decisions & Alternatives rows
- Sampled: no code or test files exist in the project tree; no `docs/arrows/` overlay present, so arrow-index cross-checking not applicable
- Cold-read pass: performed across HLD and both LLDs

## 4. Worth a second look

I could not read the core skill's `references/capability-flags.md` from this sandbox, so I'm treating the flags as applying. Models in my class are known to miss designs that quietly contradict a project's own tenets — please sanity-check the two LLDs against the HLD's tenets yourself (particularly the "service stays small" tenet against any implicit dependency, and "no silent reordering" against QUEUE-005's phrasing).

## 5. Offer to help

Want me to walk through the findings in detail, focus on a theme (say, the LLD-to-spec gaps in F1/F3), or work through a specific one together? Pick any finding and we can dig in.

If you'd rather step back and ask broader LID-usage questions — where a PRD might fit before this HLD, when to add a third design node vs. grow one of these two, how the arrow changes once implementation starts and the tests/code phases come online — I can help with those too.