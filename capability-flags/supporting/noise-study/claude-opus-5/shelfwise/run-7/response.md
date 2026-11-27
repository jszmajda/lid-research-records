## LID Coach — Shelfwise

**Posture:** Well-formed young arrow, stopping at EARS — with one design that leans against its own tenet.

**Scorecard**
- ✓ **Intent-tree shape** — two clean leaf components, HLD → LLD links resolve, no overlap or lumping
- ✓ **Spec form** — EARS-compliant throughout, stable zero-padded IDs, zero obsolete residue
- ✗ **Arrow completeness** — tests and code phases absent, yet all 13 specs are marked `[x]`
- ⚠ **Tenet coherence** — the allocation rule runs against "waiting is honored in sequence"
- ⚠ **Decision capture** — the branch-priority tradeoff, the most consequential choice in the design, isn't on the page
- ⚠ **Configuration** — `CLAUDE.md` carries the mode marker but not the LID directives

**Headline:** For a project this early, the intent layer is genuinely good — the two components are the right two, the specs are crisp EARS with clean prefixes, and the LLDs cite HLD goals by number, which is real bidirectional linkage most projects never get to. The highest-value next move is reconciling the local-branch-first allocation rule with Tenet 1 (either the rule or the tenet has to move), and recording that tradeoff in the Decisions table where the next session will find it.

**Findings (12 total · 4 high · 7 medium · 1 low)**
- **F1 (high):** `CLAUDE.md`'s `## LID` block carries `Mode` and `Version` but no LID directives · *modes are declared, not inferred* — the mode must be read, not defaulted
- **F2 (high):** All 13 specs marked `[x]` satisfied while no test or code file exists in the repo · *coherence is adjacency* + *tests before code* — each arrow level agrees with its neighbor
- **F3 (high):** Branch-first allocation (`HOLDALLOC-003`/`-004`) lets a later local hold precede an earlier county-wide one, against Tenet 1 · *tenets capture forward-looking preference* — tenets pre-narrow the lean so sessions don't re-guess
- **F4 (high):** No Decisions & Alternatives row for branch-priority-over-strict-FIFO; the rationale lives in one body-prose clause about the courier van · *docs carry current intent* — a cold reader must be able to reconstruct what was given up
- **F5 (medium):** The printed-slip → scanned-onto-holds-shelf handoff is owned by neither component; nothing covers a copy never scanned · *coherence is adjacency*
- **F6 (medium):** Hold cancellation is relied on by both designs but no spec defines the operation outside the in-transit case · *effective intent-tree alignment* — LLD behavior with no spec is unnamed intent
- **F7 (medium):** Goals 1 and 2 have no downstream specs, and deleting hold records at close leaves nothing to compute them from · *effective intent-tree alignment*
- **F8 (medium):** Tenets 3 and 4 are triggered rules already encoded in EARS rather than leans, and the list is unordered though Tenet 1 and courier efficiency can conflict · *tenets capture forward-looking preference*
- **F9 (medium):** HLD has no target users, non-goals, or key design decisions · *HLD is architecture and rationale*
- **F10 (medium):** Neither leaf design carries `prefix:` frontmatter, so `HOLDALLOC`/`PICKUP` resolve to their leaves by convention only · *specs are grep-anchored linkage*
- **F11 (medium):** Dialer-channel delivery failure, "4 business hours," and "next morning's pull list" each leave an edge for the implementing agent to fill in · *LLDs close enough of the solution space*
- **F12 (low):** Body-prose negations ("No reminder follows," "does not trigger a fallback channel") restate rows already in the Decisions table · *docs carry current intent* — the same content is present intent in the table, a defensive aside in prose

**What was audited**
- Read fully: all 6 files in the repo — `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/hold-allocation/{hold-allocation-design.md,hold-allocation-specs.md}`, `docs/intent/pickup-notices/{pickup-notices-design.md,pickup-notices-specs.md}`
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 4 tenets, 2 goals, 7 Decisions & Alternatives rows
- Arrow-path sampled: both segments end-to-end — HLD component link → leaf design → spec; the test and code legs terminate with no files
- Linkage metric: 0 `@spec` annotations, because no code or test files are present
- Grep sweep: no `docs/arrows/` overlay, no `## LID Scope` section (not needed in Full mode), no `[inferred]` markers, no `[obsolete]` markers, no `prefix:` frontmatter
- Cold-read pass: completed over all four LID docs plus the instruction file
- Default taken (non-interactive run): I could not read the core skill's `references/capability-flags.md` — it sits outside this session's allowed paths — so per the skill's own instruction I treat the capability flags as applying

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets. F3 is exactly that shape, so please check both leaf designs against the HLD tenets yourself — particularly whether Tenet 4's "hold history is not kept" leaves you able to measure Goal 2 at all.

Want me to walk through the findings in detail, focus on a theme or priority (the four high-priority ones make a coherent first pass), or work through specific items together? You can also pick a single finding to dig into — F3 and F4 are entangled and worth taking as a pair.

If you have broader questions about using LID for Shelfwise — when to add the arrow-maintenance overlay, how to sequence the tests-and-code legs from here, where a library PRD or the circulation-system integration contract would fit, or what to do as hold allocation grows past one leaf — I can help with those too.