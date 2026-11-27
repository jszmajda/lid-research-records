# LID Coach — printfarm

**Posture:** Bootstrapping — clean upper arrow, lower half not yet walked, one live tenet conflict.

**Scorecard**
- ✓ Configuration & mode fit — Full mode, clean `linked-intent-dev` directives and `- Mode:` marker
- ✓ Linkage & EARS hygiene — unique, grep-friendly IDs (`QUEUE`/`REG`) matching `prefix:` frontmatter; clean "When … SHALL" specs
- ✓ Mutation hygiene — no history residue, no `[obsolete]` or `[inferred]` markers
- ⚠ Tenet cascade — the in-memory queue works against "a submitted job is a promise" under restarts
- ⚠ Decision capture — that durability choice has no Decisions & Alternatives row
- ⚠ Arrow completeness — Tests → Code (and `@spec` annotations) not yet walked

The HLD, both LLDs, and all eight EARS specs are clean, well-linked, and written to be read cold; the most valuable next step is to settle how accepted jobs survive a restart, since that choice currently works against your "upload and walk away" tenet and isn't captured in any Decisions row.

**Findings (5 total · 2 high · 2 medium · 1 low)**
- **F1 (high):** Accepted jobs live only in process memory and are lost on restart — under the power blips / unattended OS updates the job-queue LLD itself describes, that defeats Tenet 1 ("a submitted job is a promise… upload and walk away") and the "evening upload, overnight print, morning pickup" goal, with no recorded exception naming the tenet traded away · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets and goals say to lean
- **F2 (high):** That durability choice sits only in the Architecture prose with no Decisions & Alternatives row (the three rows that exist are well-formed), so a cold reader can't reconstruct what was weighed or why they shouldn't reverse it · *decision capture* — a choice that stays live once landed needs its rejected alternative and accepted cost on the page
- **F3 (medium):** The job-queue LLD describes two-class FIFO prioritization and class-based acceptance (and the registry LLD describes staff *registering* printers) with no corresponding EARS spec · *effective intent-tree alignment* — LLD behaviors with no spec are unnamed intent with nothing to test against
- **F4 (medium):** The three tenets are unordered even though "upload and walk away" and "the service stays small" pull opposite ways on durability, and Tenet 1 reads as a restatement of Goal 1 · *tenets capture forward-looking preference* — real tie-breakers with a defensible opposite, ordered when they could conflict
- **F5 (low):** All eight specs are marked `[x]` while the repo contains no test or code files and zero `@spec` annotations · *tests carry `@spec` annotations* / *tests before code* — consider whether `[x]` means "authored" or "walked to code," since the Tests → Code half hasn't started

**What was audited**
- Read fully (all 6 files): `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 EARS specs (`QUEUE-001`–`005`, `REG-001`–`003`), 5 Decisions & Alternatives rows swept
- Small project (no sampling threshold met — no `docs/arrows/index.yaml` overlay, 2 LLDs, 0 `@spec`-carrying files), so every LID doc was cold-read in full
- Linkage metric: 0 `@spec` references — 0 test files, 0 code files exist in the repo; single commit (`fixture`), so no cascade history to inspect

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.