## printfarm LID coach report

**Executive summary**

**Posture:** Clean and compact, still bootstrapping. The design layer is well-written, but one load-bearing decision cuts against the project's own first tenet.

**Scorecard**
- ✓ Configuration: `CLAUDE.md` carries the LID directive and a `Mode: Full` marker, and the layout follows the standard `docs/intent/` structure.
- ✓ Cold-readability and mutation hygiene: no changelog residue, no `[obsolete]` specs, no "as discussed" leaks, and the Decisions tables give rejected alternatives and accepted costs.
- ✓ Spec format: all 8 specs are EARS-shaped, with unique IDs (`QUEUE-`, `REG-`) matching each LLD's `prefix:` frontmatter, and every one is marked `[x]`.
- ⚠ Design coherence: the in-memory queue sits in tension with the "a submitted job is a promise" tenet.
- ⚠ Spec coverage: several LLD behaviors and the queue-to-registry seam have no spec.
- ⚠ LLD sufficiency: how the service talks to three printer models is left open.

**Headline:** The two-node design is small and clear, and the HLD includes real tenets. The most valuable next step is to reconcile the in-memory queue with the "promise" tenet, either by changing the design or by recording the tradeoff in a fuller Decisions row.

**Findings (8 total · 2 high · 4 medium · 2 low)**
- **F1 (high):** The job queue is held only in memory, so accepted jobs vanish on restart. The mini-PC takes unattended OS updates and power blips, and the first tenet says members can upload and walk away. This is a design concern in its own right. · *intent leads; code is compiled output* (specs and design should express what the project actually promises) and *tenets capture forward-looking preference* (a tenet should actually steer decisions)
- **F2 (high):** The in-memory choice, and the "members resubmit" consequence, appear only in Architecture prose. There is no Decisions & Alternatives row naming the rejected alternative (persisting the queue, e.g. in the registry's existing SQLite file) or the accepted cost. A cold reader would question or try to reverse this choice. A fuller row is enough. No decision doc is warranted. · *docs carry current intent, written to be read cold* (decision capture)
- **F3 (medium):** The three tenets are unordered, yet "a job is a promise" and "the service stays small" pull against each other, and F1 is exactly that conflict. Consider ranking them. · *tenets capture forward-looking preference*
- **F4 (medium):** QUEUE-003 has the queue mark a printer "suspect", but the registry design defines only idle, busy and unreachable. The registry owns printer state, so this crosses a node boundary without a matching REG spec or state definition. · *intent attaches at the lowest node that dominates it; cascade within a segment, pause across* (a cross-node obligation needs a note at the owning node)
- **F5 (medium):** Some design behaviors have no spec. In the queue LLD these are accept-only-if-the-class-has-a-printer, the staff/member priority with FIFO order, and content-hash file storage. Across the two nodes, the registry reporting a printer idle to the queue (the trigger for QUEUE-002) is unowned. · *effective intent-tree alignment* (each LLD behavior should trace to a spec so it can be tested)
- **F6 (medium):** The LLDs say jobs are dispatched over "local network APIs" and that state comes from a "status endpoint". With three hardware models, two agents could reasonably build incompatible adapters. Consider naming the protocol or adapter contract per model. · *LLDs close enough of the solution space*
- **F7 (low):** The HLD promises a member and staff web UI, but no design node owns it. Upload and reorder are covered under job-queue, but the UI itself has no design home. Consider whether it belongs in job-queue or in a node of its own. · *effective intent-tree alignment*
- **F8 (low):** The HLD goal "fair access to the popular printer classes" isn't backed by the design. FIFO within two priority classes is fair between classes, and the Decisions row admits one long job can hold a class for hours. Consider either a spec or an added note tying fairness to what the design actually delivers. · *intent leads; code is compiled output*

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design LLDs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 8 EARS specs (5 QUEUE, 3 REG).
- Arrow-path sampling: not applicable. The project is far below the size thresholds, and there is no source or test code yet, so the tests and code phases are unreviewed rather than gaps. When implementation starts, put `@spec` annotations on the tests and on the entry-point functions.
- `docs/arrows/index.yaml`: absent. That is a legitimate choice at this size, so it isn't a finding. If the project grows, `/arrow-maintenance` can enumerate structural drift.
- Mode: Full, as declared and consistent with a small whole-repo design.

**Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.