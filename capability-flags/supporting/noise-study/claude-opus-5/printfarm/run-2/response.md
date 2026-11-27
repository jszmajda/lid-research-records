# LID Coach — printfarm

## Executive summary

**Posture:** *Early and real — a clean two-node arrow through specs; the lower phases and one load-bearing decision aren't on the page yet.*

**Scorecard**
- ✓ Mutation hygiene — no history residue, no `[obsolete]` or stale `[inferred]` markers anywhere
- ✓ Spec linkage IDs — `QUEUE-`/`REG-` match their leaves' `prefix:` frontmatter, unique, zero-padded, each file backlinked to its LLD
- ✓ Mode fit — Full matches a two-node project of this size
- ✗ Arrow completeness — all 8 specs read as complete, but no tests or code exist in the repo
- ⚠ Cross-node coherence — printer state ("suspect") is authored in the queue node, unknown to the registry
- ⚠ Decision capture — the in-memory-queue durability choice shapes the whole design but isn't in any Decisions table

**Headline:** The bones here are good — two well-separated design nodes, EARS specs that actually trace to them, prefixes that match their frontmatter, and not a scrap of changelog residue in any doc. The highest-value next step is writing down the durability decision (the queue lives in process memory and drops undispatched jobs on restart), because that single unrecorded choice sits directly against your own tenet that a submitted job is a promise.

## Findings (12 total · 4 high · 7 medium · 1 low)

- **F1 (high):** All 8 specs carry `[x]` but the repo holds no tests or code, and nothing declares this docs-only · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code
- **F2 (high):** The in-memory queue / "members resubmit" choice appears only in `job-queue-design.md` body prose, with no Decisions & Alternatives row naming what was rejected or what cost was accepted · *docs carry current intent, written to be read cold*
- **F3 (high):** That same volatile queue works against the tenet "a submitted job is a promise" and the goal of unattended overnight prints, on a mini-PC the LLD itself says takes unattended updates and power blips · *coherence is adjacency* — each level agrees with the one above it
- **F4 (high):** QUEUE-003 marks a printer "suspect," but printer state belongs to `printer-registry`, which never defines or acts on that state · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across*
- **F5 (medium):** "class" means both printer class and priority class in `job-queue-design.md` and in QUEUE-002/003 ("head job of that printer's class") · *scope disambiguation* — a spec must be unambiguous to an agent that greps it out of context
- **F6 (medium):** Several LLD behaviors have no spec: accept-only-if-the-class-has-a-printer, the two priority classes and FIFO, printer *registration* (REG covers only retirement), telling members their job was dropped, content-hash file retention and 90-day slug recycling · *effective intent-tree alignment*
- **F7 (medium):** QUEUE-003's "return the job to the head of its class queue" is under-specified against two priority classes — two agents would order a failed staff job and a failed member job differently · *LLDs close enough of the solution space*
- **F8 (medium):** QUEUE-004 has the queue poll printers directly at startup, duplicating the registry's ownership of printer polling and state · *one LLD per intent component*
- **F9 (medium):** The HLD's Architecture section points at two directories rather than carrying architecture-level rationale, and there are no Key Design Decisions or success metrics behind goals like "fair access" · *HLD is architecture and rationale*
- **F10 (medium):** Tenet 2 bundles a tie-breaker ("staff override members") with a triggered rule ("no silent reordering") already fixed by QUEUE-005; the three tenets are unordered although 1 and 3 can pull against each other · *tenets capture forward-looking preference*
- **F11 (medium):** Nothing in either node says what happens to a job already printing when its printer misses three heartbeats, or how "suspect" and "unreachable" interact · *effective intent-tree alignment*
- **F12 (low):** No `@spec` annotation convention is established yet and `docs/arrows/` isn't installed — worth deciding before the first code lands rather than retrofitting · *specs are grep-anchored linkage*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design nodes (`job-queue`, `printer-registry`) and both spec files — the entire repository is 6 files
- Enumerated: 2 leaf LLDs, 2 spec files, 8 EARS specs (5 `QUEUE-`, 3 `REG-`), 5 Decisions & Alternatives rows, 3 tenets
- Arrow-path attempted end-to-end on both segments: HLD § Architecture → LLD → spec → **tests: none found** → **code: none found**; no `@spec` annotations exist in the project
- Structural overlay: `docs/arrows/index.yaml` absent, so findings here come from direct reading rather than an index; `/arrow-maintenance` isn't available until that overlay is installed
- Decisions-table sweep: all 5 existing rows read as reconstructable by a cold reader; the two job-queue rows that name a rejected alternative and an accepted cost are a good model — the finding is about a decision with no row at all
- Configuration: LID directives, `- Mode: Full`, and version marker all present and well-formed; nothing needing `/update-lid` to reconcile
- Non-interactive run: no clarifying questions were asked; the review proceeded under the declared Full mode with no defaults substituted

## Worth a second look

I couldn't load the core skill's capability-flags reference from this session, so I'm treating the flags as applying to me. Models in my class are known to miss designs that contradict a project's own tenets — F3 is one instance I did catch, but please read both leaf designs against your HLD tenets yourself, particularly the "stays small" tenet against the durability and notification work F2/F6 imply.

## Where to go next

Want me to walk through the findings in detail, focus on a theme (the durability cluster F2/F3, or the queue/registry seam F4/F8/F11), or work through specific items together? You can also pick a single finding and we'll dig into it.

If you have broader questions about using LID on printfarm — when to write specs for behavior you haven't built yet, how `@spec` annotations should land when the first code arrives, whether a two-node project wants the arrow overlay at all — I'm happy to work through those instead.