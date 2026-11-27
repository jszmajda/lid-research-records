# Shelfwise — LID Coach Review

## 1. Executive summary

**Posture:** *Healthy docs, thin arrow* — the design layer is unusually clean; the arrow simply stops at EARS.

**Scorecard**
- ✓ HLD discipline — architecture-level, tenet- and goal-bearing, no implementation detail upstream
- ✓ Decision capture — each LLD's key choices carry a named rejected alternative and an accepted cost
- ✓ Mutation hygiene — no history residue, no obsolete markers, no changelog sections anywhere
- ⚠ Arrow completeness — EARS is the deepest layer present; no test or code phases exist
- ⚠ Cascade health — one LLD/spec disagreement (expiry), plus two LLD behaviors with no spec
- ⚠ Configuration — mode marker present, workflow directive missing from the instruction file

**Headline:** The design layer is in good shape — real tenets, real rationale, clean mutation hygiene — and the fastest wins are configuration reconciliation (`/update-lid`) plus one adjacent-level fix at expiry handling.

---

## 2. Findings (12 total · 4 high · 4 medium · 4 low)

- **F1 (high):** `CLAUDE.md` carries `## LID` (Mode: Full, Version: 1.4.0) but no directive block naming the `linked-intent-dev` workflow — a cold session has no route from the instruction file into the methodology · *modes are declared, not inferred* / *minimum surface, maximum discipline* → run `/update-lid`
- **F2 (high):** The arrow terminates at EARS: 13 specs, zero test files, zero code files, zero `@spec` annotations anywhere in the repo — the Tests and Code phases are absent, not merely thin · *canonical arrow shape*
- **F3 (high):** `pickup-notices-design.md:11` says a lapsed window closes the hold and re-runs allocation; `PICKUP-004`/`PICKUP-005` say the hold closes only when staff scan the copy off the shelf — the LLD and the spec disagree about when the hold closes · *coherence is adjacency* / *intent leads; code is compiled output*
- **F4 (high):** The local-first allocation rule (`hold-allocation-design.md:11`) hands a copy to a later-placed local hold ahead of an earlier county-wide hold — the HLD's tenet "Waiting is honored in sequence" says no wait may be lengthened by a later requester, and no Decisions row records the exception · *tenets capture forward-looking preference* / *tenet cascade* (the trade-off belongs in a row naming the tenet given up)
- **F5 (medium):** LLD behaviors with no spec behind them: a copy becoming `allocated` (referenced by `HOLDALLOC-006` but never specified), hold cancellation (`HOLDALLOC-007` presumes "its hold was cancelled" — cancellation is never specified), and "No reminder follows" · *effective intent-tree alignment* — unnamed intent drifts silently
- **F6 (medium):** Every spec is marked `- [x]` with no legend anywhere; with no implementation in the repo, a cold reader cannot tell whether `[x]` means "current" or "implemented" · *docs carry current intent, written to be read cold* — status markers need to resolve on the page
- **F7 (medium):** `pickup-notices-design.md` invokes "allocation" as a behavior it depends on, without linking to `hold-allocation-design.md` — the cold reader has to guess where that behavior is owned · *intent attaches at the lowest node that dominates it* — a dependency belongs as a reference to the owning node
- **F8 (medium):** The local-first rule is the one genuinely reversible choice in `hold-allocation` and it survives only as prose ("This keeps most copies off the courier van, which runs once a day") · *docs carry current intent* (keep-side) — a live decision wants a Decisions-table row
- **F9 (low):** The HLD has no non-goals and no named target users, so a cold reader cannot tell what Shelfwise deliberately does not do · *HLD is architecture and rationale*
- **F10 (low):** No LLD↔spec links in either direction and no design-tree index under `docs/intent/` — the arrow is walkable only by folder convention · *verticalize intent* (a tree index aids the one axis rather than adding a second)
- **F11 (low):** The daily staff call for a failed notice is a second patron touch under the "Patrons hear once, clearly" tenet, and no row records how the two reconcile · *tenet cascade*
- **F12 (low):** No `docs/arrows/index.yaml` — the arrow-maintenance overlay is not installed, so structural checks (reverse orphans, index drift) have no enumeration tool · *coherence is adjacency* → consider `/arrow-maintenance` if structural auditing is wanted

---

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation-design.md`, `pickup-notices-design.md`), both spec files
- Enumerated: 2 LLDs, 2 spec files, 13 spec IDs — all unique, grep-friendly, no collisions or reuse
- Scanned for residue markers (`[inferred]`, `[obsolete]`, change-narration, conversational fossils) — none present
- Sampled code and tests: none exist — 0 source files, 0 test files, 0 `@spec` references
- Arrow overlay: absent (`docs/arrows/index.yaml` not present)
- Cold-read pass over all five LID docs, plus a Decisions-table sweep of all seven decision rows with the HLD in hand

---

*Defaults taken (non-interactive run):* the skill is advisory and explicitly does not edit project files, so I produced the report only and made **no file changes**; where the skill would have asked which remedy to pursue, I recommended the specific command (`/update-lid` for F1, `/arrow-maintenance` for F12) instead of applying anything. No overlay was installed, and no out-of-scope section applies because the project declares Full mode.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.