## LID Coach — printfarm

### Executive summary

**Posture:** *Design layer is clean and genuinely reasoned; the arrow stops at EARS, and the headline design choice works against the project's own tenet.*

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ✓ LLD granularity — two nodes, each one real intent component, cleanly mirroring the HLD's Architecture section
- ✓ Mutation hygiene — no change-narration, no obsolete markers, no planning residue; the docs read cold
- ✗ Arrow completeness — no tests or code anywhere, yet all 8 specs carry `[x]`
- ⚠ Tenet cascade — the in-memory queue defeats "a submitted job is a promise" under a condition the LLD itself describes
- ⚠ Decision capture — the durability model, the load-bearing choice in this design, has no Decisions row in either node

**Headline:** The hard part is done well — the HLD carries real tenets with defensible opposites, both LLDs trace cleanly to it, and the Decisions tables already do the thing most projects skip (the FIFO row names the rejected alternative *and* the accepted cost). The fastest wins are recording the durability decision and closing the gap between it and the "upload and walk away" promise.

### Findings (9 total · 4 high · 4 medium · 1 low)

- **F1 (high):** `job-queue-design.md:14` holds accepted jobs in process memory and loses undispatched ones on restart, while the same paragraph names unattended OS updates and power blips — under that condition the HLD's tenet *"a submitted job is a promise: members should be able to upload and walk away"* and the goal *"evening upload, overnight print, morning pickup — with no member present"* both fail, with no row recording the trade · *tenet cascade / keep the arrow coherent*
- **F2 (high):** that same volatility choice — memory-only queue, resubmit after restart — has no Decisions & Alternatives row; a cold reader holding the tenets would question it immediately · *decision capture*
- **F3 (high):** the arrow runs HLD → LLDs → EARS and stops; no tests or code exist, yet all 8 specs are marked `[x]` · *canonical arrow shape*, *tests before code*
- **F4 (high):** `QUEUE-003` marks a printer "suspect", but `printer-registry` defines no suspect state — the queue segment wrote a state into the registry's territory without the pause a node boundary warrants · *cascade within a segment, pause across*; *coherence is adjacency*
- **F5 (medium):** the durability model differs between the two nodes (registry on SQLite, queue in memory) with nothing at the HLD recording why — substance that governs both siblings sitting in neither · *intent attaches at the lowest node that dominates it*
- **F6 (medium):** LLD behaviors with no spec anywhere — accept-only-if-the-class-has-a-registered-printer, content-hash G-code storage, 90-day slug recycling, the 15 s heartbeat poll, printer registration (retirement has `REG-003`) · *effective intent-tree alignment*
- **F7 (medium):** read cold, `QUEUE-004`'s startup rebuild leaves two agents free to diverge — what happens to a running job the service has no record of? — and "two priority classes: staff and member" doesn't say whether that means the submitter's role or a staff promotion · *LLDs close enough of the solution space*
- **F8 (medium):** the three tenets are an unordered list, but tenets 1 and 3 ("a submitted job is a promise" / "the mini-PC is modest, the service stays small") collide exactly where F1 landed, so the list gives no lean · *tenets capture forward-looking preference*
- **F9 (low):** `QUEUE-001` is scoped to "a member uploads" in a system with two actor classes — if staff upload, is the 64 MB limit theirs too? · *scope disambiguation*

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), 2 arrow segments
- Arrow-path walked: both segments end-to-end (HLD section → LLD → specs → tests → code); both terminate at the spec level
- Linkage: 0 `@spec` annotations — no source or test files present in the repository
- Overlay: `docs/arrows/` absent, so no `index.yaml` cross-check; structural enumeration was done by hand at this size
- Cold-read pass: performed over all four LID docs; both prefixes (`QUEUE`, `REG`) resolve to their declared leaf `prefix:` frontmatter, no orphans

---

Want me to walk through the findings in detail, focus on a theme (the durability thread — F1, F2, F5 and F8 are really one knot) or a priority tier, or work through specific items together? Pick any finding and I'll go deeper on what it costs and how to close it.

If you have broader questions about using LID on printfarm — when the tests phase is worth standing up, how spec status markers should behave before code exists, whether this project would benefit from the arrow-maintenance overlay — I can help with those too.