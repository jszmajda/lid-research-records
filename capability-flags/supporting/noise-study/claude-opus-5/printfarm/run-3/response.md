## LID Coach — printfarm

**Posture:** Design layer is clean and coherent in itself; the arrow stops at EARS, and one HLD tenet is already at odds with a leaf design.

**Scorecard**
- ✓ Linkage hygiene — `prefix:` declared in frontmatter on both leaves, IDs unique, zero-padded and grep-clean, each spec file back-links its LLD
- ✓ Mutation hygiene — docs read as present intent; no changelogs, "previously", `[obsolete]`, or `[inferred]` residue anywhere
- ✓ Structure & mode fit — one HLD, two leaves, `parent:` set on both, a single navigation axis; Full mode matches a whole-repo adoption this size
- ✗ Arrow completeness — no tests and no code in the repo, yet all 8 specs carry `[x]`
- ⚠ Coherence — the in-memory queue runs against the HLD's own "a submitted job is a promise" tenet; `suspect` crosses a node boundary undefined
- ⚠ LLD sufficiency — the scheduling rule and the member-facing surface are left open for an implementer to invent

**Headline:** For a two-node project this is unusually disciplined groundwork — the prefixes, frontmatter, back-links and EARS phrasing are all textbook, and the docs are genuinely readable cold. The highest-value next move is settling the queue-durability question in writing, while it is still a two-line edit to a Decisions table rather than a storage migration.

**Findings (11 total · 4 high · 6 medium · 1 low)**
- **F1 (high):** Tests and code have no presence in the repo, yet all 8 specs are marked `[x]` · *intent leads; code is compiled output* — specs drive code, and the arrow has to be walkable end to end
- **F2 (high):** The in-memory queue (undispatched jobs lost on restart, on a mini-PC that "takes unattended OS updates") runs against the tenet "a submitted job is a promise" and the overnight-unattended goal · *coherence is adjacency* — each level agrees with the one above it
- **F3 (high):** The member/staff web surface — upload, queue view, who counts as staff — is named in the HLD Approach but owned by no design node · *one LLD per intent component*
- **F4 (high):** Prioritization (staff vs. member, FIFO within class) has no EARS spec, which already leaves QUEUE-002's "head job of that printer's class" ambiguous · *LLDs close enough of the solution space* — two agents should land on compatible implementations
- **F5 (medium):** The durability stance is captured nowhere — no Decisions & Alternatives row in `job-queue-design.md`, and nothing at the HLD even though the two leaves chose oppositely (SQLite vs. process memory) · *decision capture* + *intent attaches at the lowest node that dominates it*
- **F6 (medium):** QUEUE-003 marks a printer "suspect", a state the registry that owns printer state never defines · *coherence is adjacency* — plus in-conversation-only meaning that never reached the page
- **F7 (medium):** Several LLD behaviors have no spec: printer registration, content-hash dedupe, 90-day slug recycling, the "class must have a registered printer" acceptance rule, the 15 s heartbeat interval · *effective intent-tree alignment*
- **F8 (medium):** "Printer class" is the queue's partition key and the member's upload choice, but is defined nowhere — nor is its relation to the three hardware models · *docs carry current intent, written to be read cold*
- **F9 (medium):** Tenet 2's second clause ("no silent reordering") is a triggered rule already fixed as QUEUE-005, and the tenets are unordered though 1 and 3 can conflict · *tenets capture forward-looking preference*
- **F10 (medium):** The HLD has no Key Design Decisions and no Success Metrics; "fair access to the popular printer classes" can't be checked against anything · *HLD is architecture and rationale*
- **F11 (low):** The content-hashed G-code store on disk has no retention or cleanup intent, on hardware the tenets call modest · *LLDs close enough of the solution space*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `job-queue-design.md`, `job-queue-specs.md`, `printer-registry-design.md`, `printer-registry-specs.md` — the entire repo (9 paths, 6 files)
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), all marked `[x]`
- Arrow-path walked: both segments end to end — HLD §Architecture → LLD → specs → tests → code; both terminate at the spec level
- Searched for: `@spec` annotations (0 matches; no source or test files exist), `docs/arrows/` overlay (not installed, so `/arrow-maintenance` isn't available here), `[inferred]` and `[obsolete]` markers (none)
- Cold-read pass and Decisions-table sweep run over all 5 Decisions rows; 3 rows pass as written (job identifiers, upload size limit, registry store)
- No interactive checkpoints were reached — dispatch resolved cleanly to a full review (directives present, Mode: Full, both standard locations populated)

**Worth a second look:** models in my class are known to miss designs that contradict the project's own tenets — F2 is one such case, so please read both leaf designs against your three HLD tenets yourself rather than taking my sweep as complete. (I also could not open the core skill's `references/capability-flags.md` from this session's working directories, so I'm treating the flags as applying.)

Want me to walk through the findings in detail, focus on a theme or priority (the four high-priority ones are a natural first pass), or work through specific items together? You can also pick a single finding — F2 and F5 are really one conversation about durability, and it's worth having before code exists.

If you have broader questions about using LID on printfarm — where a PRD for the member-facing UI would sit, whether the web surface wants its own leaf or a sub-HLD, when Full mode starts to feel heavy for a six-printer service — I'm happy to work through those instead.