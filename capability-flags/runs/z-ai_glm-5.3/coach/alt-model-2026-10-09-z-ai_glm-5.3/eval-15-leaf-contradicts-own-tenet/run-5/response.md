# LID Coach — Shelfwise (Full mode)

**Posture:** Bootstrapping — the arrow is authored cleanly through the EARS layer, but two truth-carriers (spec status markers, instruction-file directives) already drift from repo reality, and the system's central policy trades against a tenet unrecorded.

**Scorecard**
- ✓ Mutation hygiene — docs read as authored fresh today; no residue, no narration
- ✓ Tenets — four real tie-breakers with defensible opposites, not platitudes
- ✓ LLD granularity — two clean leaves, cross-referenced rather than duplicated
- ✗ Linkage truth — all 13 specs claim an implementation that doesn't exist
- ⚠ Tenet cascade — core allocation policy works against Tenet 1, unrecorded
- ⚠ Configuration — instruction-file directive and LLD frontmatter missing

**Headline:** The design layer is unusually clean — terse, residue-free, well-sized, with tenets that actually tie-break — so the most valuable next steps are small: make the truth-carriers true (flip 13 status markers, add the workflow directive, add `prefix:` frontmatter) and record the branch-first allocation decision with its Tenet-1 trade **before** implementation starts.

---

**Findings (7 total · 3 high · 3 medium · 1 low)**

- **F1 (high):** CLAUDE.md carries the `## LID` mode block (Full, 1.4.0) but no directive naming the `linked-intent-dev` workflow — future sessions won't know to walk the arrow once code exists · *modes are declared, not inferred* (the declared foundation should name the methodology it declares) → `/update-lid` to reconcile
- **F2 (high):** All 13 EARS specs are marked `[x]` — "code and tests exist" per LID's marker convention — but the repo contains zero code and zero tests · *intent leads; code is compiled output* (specs are the source of truth; a marker claiming compiled output that doesn't exist misleads every future session into skipping implementation) → flip to `[ ]` (active gap)
- **F3 (high):** Local-priority allocation (HOLDALLOC-003 taking precedence over HOLDALLOC-004) hands a checked-in copy to a *later*-placing local patron while an *earlier* hold waits for another branch — under exactly that condition, the mechanism works against Tenet 1, "Waiting is honored in sequence," and no Decisions row records the exception · *tenets capture forward-looking preference* (tenets govern choices the arrow hasn't reached; an unrecorded trade silently erodes one)
- **F4 (medium):** The branch-first-vs-strict-county-wide-FIFO choice — the system's load-bearing policy — survives only in hold-allocation body prose ("keeps most copies off the courier van"); no Decisions & Alternatives row names the rejected alternative and the accepted Tenet-1 cost · decision capture under *docs carry current intent* (a fresh author choosing this design would record it as a row)
- **F5 (medium):** Both LLDs lack `parent:`/`prefix:` frontmatter — the authoritative bridge from spec ID to design doc — and both prefixes are lossy abbreviations (`PICKUP` ← "pickup notices", `HOLDALLOC` ← "hold allocation"), exactly where the bridge is most needed · *specs are grep-anchored linkage* (a reader should resolve ID → owning doc without guessing)
- **F6 (medium):** The Full-mode HLD skips the template's Non-Goals (and Target Users / Success Metrics) sections · *HLD is architecture and rationale* — an explicit non-goal ("not a catalog/discovery tool," etc.) constrains future surface growth more than a vague goal
- **F7 (low):** Tenet 3 says "each event produces one message," but only window-start has a message spec; whether hold placement, expiry, or cancellation produce a patron message is unstated anywhere · *scope disambiguation* / cold-read ambiguity — one clarifying line settles it

**What was audited**
- Read fully: CLAUDE.md, `docs/high-level-design.md`, both LLDs, both spec files (all 13 EARS lines), and the LID core references (EARS syntax, HLD/LLD templates, capability flags)
- No code or test files exist to sample — 0 `@spec` annotations, 0 tests, 0 `docs/arrows/` overlay
- Cold-read pass: all 5 LID docs; Decisions-table sweep: all 7 existing rows (each passes — source or cost named); spec IDs: 13, globally unique, zero-padded, grep-clean

---

**Defaults taken in this non-interactive run:** the skill's advisory posture (no file edits — the report renders inline and `/update-lid` / direct edits apply it); dispatch defaulted to a full review anchored on the existing LID-shaped artifacts; the capability-flag section was omitted because `capability-flags.md` lists no flagged configurations.

Want me to walk through any finding in detail — F3/F4 (the allocation trade) is where I'd start — or work through specific items together?

If you have broader questions about using LID for this project — where tests-first should begin, when a `docs/arrows/` overlay earns its keep, how to handle the transition from docs-only to implementation — I can help with those too.