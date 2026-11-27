**LID Coach — Shelfwise**

## 1. Executive summary

**Posture:** Healthy design arrow, cleanly written — the tenet layer and the implementation half haven't caught up to it.

**Scorecard**
- ✓ Mutation hygiene — docs read as current intent; no changelogs, no `[obsolete]` residue, no `[inferred]` backlog
- ✓ Decision capture (where rows exist) — Decisions tables name the rejected option *and* the accepted cost, including a cost measured against a stated goal
- ⚠ Tenet cascade — the allocation rule leans against Tenet 1 under a condition the design itself describes
- ⚠ Configuration — the `## LID` block declares mode and version but no LID directives
- ✗ Arrow completeness — Tests and Code phases are absent, yet every spec is marked done
- ⚠ Spec precision — "checked in" and "fails to deliver" each carry more than one meaning

**Headline:** Two components, two design docs, two spec files, thirteen EARS specs that trace cleanly to the HLD's Components list — the intent half of this arrow is in genuinely good shape, and the `Expiry handling` row in `pickup-notices-design.md` is a model of how to record an accepted cost. The highest-value next step is reconciling the tenets with what allocation actually does: branch-first routing quietly reorders the queue that Tenet 1 promises to honor, and nothing on the page records that trade.

## 2. Findings inventory

**Findings (12 total · 4 high · 5 medium · 3 low)**

- **F1 (high):** `CLAUDE.md` carries a `## LID` block with `Mode`/`Version` but no LID directive block, so the methodology itself is never loaded · *modes are declared, not inferred* — the mode marker alone leaves the rigor it configures unstated; `/update-lid` reconciles this
- **F2 (high):** Tenet 1 says nobody's wait is lengthened by a patron who asked later, but `HOLDALLOC-003` gives the copy to a same-branch hold ahead of an older county-wide one · *tenets capture forward-looking preference* + *coherence is adjacency* — the condition is described right in `hold-allocation-design.md:11`, so a future session reading the tenet and the spec gets opposite answers
- **F3 (high):** The branch-first-then-county-wide priority rule has no Decisions & Alternatives row, though the table covers granularity, trigger, and cap · *docs carry current intent* (keep-side) — this is the one choice in the component a cold reader would want to reverse, and the courier-van reasoning survives only as a half-sentence in body prose
- **F4 (high):** All 13 specs are marked `[x]`, but the repo contains no tests and no code — the arrow stops at EARS · *canonical arrow shape* + *intent leads; code is compiled output* — a done marker with nothing citing the spec means the next session can't tell what is built from what is merely agreed
- **F5 (medium):** "Checked in" means three different events — a desk check-in, a transit arrival (`HOLDALLOC-007`), and a lapsed-copy scan (`PICKUP-005`) — but `HOLDALLOC-003`/`-004` define it only for the first · *scope disambiguation* — the re-entry contract is asserted from the pickup leaf into allocation's territory without allocation acknowledging it
- **F6 (medium):** `PICKUP-006` fires on failed delivery, but the design names only bounced email and undeliverable SMS; the automated dialer's failure condition is undefined · *LLDs close enough of the solution space* — "no answer," "busy," and "disconnected number" are three defensible readings
- **F7 (medium):** Hold cancellation is specified only for the in-transit case; no spec covers a patron cancelling, or cancelling while the copy sits on a holds shelf · *effective intent-tree alignment* — the design mentions cancellation as a given, so the behavior exists but is unnamed
- **F8 (medium):** The four tenets are unordered, yet Tenet 1 (sequence) and Tenet 2 (staff attention / automation economy) pull opposite ways on exactly the allocation decision in F2 · *tenets capture forward-looking preference* — ordering is what makes a tenet set usable as a tie-breaker
- **F9 (medium):** Tenet 3 says each event produces one message, but window lapse and cancellation produce no patron notice anywhere in `pickup-notices-specs.md` · *tenets capture forward-looking preference* — either the silence is deliberate and belongs in a Decisions row, or the specs are short two entries
- **F10 (low):** Tenet 4 ("Hold history is not kept") is a triggered rule and a non-goal rather than a lean, and `PICKUP-003`/`-005` already fix it · *tenets capture forward-looking preference* (lean-not-trigger test)
- **F11 (low):** Neither spec file carries `prefix:` frontmatter, so `HOLDALLOC` → `hold-allocation` and `PICKUP` → `pickup-notices` hold by convention only · *specs are grep-anchored linkage* — cheap to make authoritative now, awkward once a third component arrives
- **F12 (low):** The HLD has no target-users or non-goals section, and the six-branch scope that frames the whole system lives only in `CLAUDE.md` · *HLD is architecture and rationale*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 13 EARS specs, 6 Decisions & Alternatives rows, 4 tenets, 2 goals
- Arrow-path walked: both segments end-to-end (HLD Components entry → design doc → spec file → tests → code); both terminate at EARS
- Linkage metric: 0 `@spec` annotations across 0 test files and 0 source files — the repo currently contains only `CLAUDE.md` and the five docs
- Overlay: `docs/arrows/` is not installed, so no `index.yaml` guided sampling and no structural enumeration was attempted
- Cold-read pass: completed over all five LID docs. Cross-references (`Goal 1`, `Goal 2`, the `allocated` state, the morning pull list) resolve on the page — no in-conversation-only meaning or conversational fossils surfaced. The gaps found were open edges (F5, F6, F7), not residue.
- Dispatch note: `CLAUDE.md` has no LID directives but the project is clearly LID-shaped, so per the coach's dispatch table this ran as a **full review** anchored on the existing artifacts, with the missing directives raised as F1. Mode defaulted to the declared `Full`; this non-interactive run took that stated default rather than asking.

---

Want me to walk through the findings in detail, focus on a theme — the tenet/allocation conflict in F2–F3 and F8 is one thread, spec precision in F5–F7 another — or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on Shelfwise — when to promote a component to a sub-HLD, how to sequence tests and code now that the specs are settled, where a PRD would fit, or whether the arrow-maintenance overlay is worth installing at this size — I can help with those too.