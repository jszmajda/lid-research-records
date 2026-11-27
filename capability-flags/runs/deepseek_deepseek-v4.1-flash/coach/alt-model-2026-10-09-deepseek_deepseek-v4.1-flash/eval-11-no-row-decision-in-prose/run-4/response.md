**LID Coach review — printfarm**

**Bootstrapping — the arrow is in place and coherent through EARS; the tests and code phases aren't there yet, and one load-bearing tenet conflict sits unrecorded.**

**Scorecard**
- ⚠ Arrow shape — HLD → LLD → EARS present and linked; Tests and Code phases absent
- ✓ Linkage — `parent`/`prefix` frontmatter and `**LLD**:` header tie each level to the one above
- ✓ Mutation hygiene — every doc reads as current intent; no changelog residue, no `[obsolete]` markers
- ⚠ Tenet alignment — the "job is a promise" tenet is defeated by the design with no recorded exception
- ⚠ Spec coverage — several behaviors the LLDs state have no EARS spec
- ⚠ Decision capture — the queue's lossy-on-restart choice lives only in Architecture prose

Headline: the two-node split is clean and the specs are well-formed EARS with stable IDs; the fastest wins are deciding the promise-vs-small-hardware trade on the record and closing the spec gaps before code starts.

**Findings (7 total · 2 high · 3 medium · 2 low)**
- **F1 (high):** job-queue's in-memory queue drops accepted jobs on restart — under the LLD's own "unattended updates and the occasional power blip" context this defeats the HLD tenet *a submitted job is a promise*, and no Decisions row records the trade · *tenets capture forward-looking preference* (hold each tenet against each mechanism)
- **F2 (high):** the arrow has no Tests and no Code — nothing verifies or implements the 8 specs, yet each is marked `[x]` · *canonical arrow shape* / *tests before code*
- **F3 (medium):** the lossy-queue choice and its accepted cost ("members resubmit them") never appear as a Decisions & Alternatives row — only in Architecture prose · *docs carry current intent* (decision capture)
- **F4 (medium):** the three HLD tenets can conflict ("job is a promise" vs "the mini-PC stays small") but are unordered; the F1 trade is exactly that conflict meeting a mechanism · *tenets capture forward-looking preference*
- **F5 (medium):** job-queue LLD states behaviors with no spec — the staff/member priority ordering and the "class must have a registered printer" acceptance precondition; printer-registry covers retirement (REG-003) but not registration · *effective intent-tree alignment* / *specs are grep-anchored linkage*
- **F6 (low):** the HLD has no Key Design Decisions section and its goals ("fair access") carry no measurable target · *HLD is architecture and rationale*
- **F7 (low):** spec prefixes `QUEUE` and `REG` abbreviate rather than echo their leaf nodes (`job-queue`, `printer-registry`), so grepping the node name won't surface its specs · *semantic legibility as cheap linkage*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/job-queue/job-queue-design.md`, `docs/intent/job-queue/job-queue-specs.md`, `docs/intent/printer-registry/printer-registry-design.md`, `docs/intent/printer-registry/printer-registry-specs.md`
- Enumerated: 1 HLD · 2 leaf LLDs · 2 spec files · 8 specs (5 `QUEUE-*`, 3 `REG-*`)
- Code/test files present: 0 — the repository contains only the instruction file and 5 docs
- Overlay: `docs/arrows/` absent; no arrow-path sampling needed at this size
- Cold-read pass: every LID doc read as if context-free

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.