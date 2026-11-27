# LID Coach — printfarm

## 1. Executive summary

**Posture:** *Solid design docs; a few load-bearing choices need lifting from prose into their proper capture form, and the arrow does not yet extend past specs.*

**Scorecard**
- ✓ Configuration — instruction file carries the LID block, `- Mode: Full`, and current version
- ✓ LLD granularity — clean 1:1 between HLD's two design nodes and the two leaf LLDs
- ✓ Linkage — spec IDs (`QUEUE-*`, `REG-*`) are grep-anchored and match each leaf's `prefix:` frontmatter
- ⚠ LLD → spec coverage — several LLD behaviors have no matching EARS spec
- ⚠ Decision capture — a load-bearing architecture choice lives only in body prose; two Decisions & Alternatives rows would leave a cold reader guessing
- ⚠ Cold-read clarity — "heartbeat" terminology and queue↔registry coupling are ambiguous on a fresh read
- ⚠ Arrow shape — Tests and Code phases are not visible in the project

**Headline:** The design tree is well-shaped and the EARS specs trace cleanly to their leaves; the fastest wins are (a) capturing the in-memory-queue decision — which is in real tension with the "job is a promise" tenet — and (b) lifting a handful of LLD-only behaviors into EARS.

## 2. Findings inventory

**Findings (7 total · 2 high · 4 medium · 1 low)**
- **F1 (high):** the in-memory queue's restart-loss behavior — in tension with the "job is a promise" tenet — is only in body prose, not in `job-queue`'s Decisions & Alternatives table · *docs carry current intent* (the keep-side: rationale + rejected alternative + accepted cost belong on the page)
- **F2 (high):** several `job-queue` LLD behaviors have no EARS spec — priority-class dispatch (staff over member, FIFO within), acceptance requires ≥1 registered printer of the target class, content-hash upload dedup · *effective intent-tree alignment* (specs are the grep-anchored contract for LLD behaviors)
- **F3 (medium):** `printer-registry` calls its mechanism "heartbeats" but describes the registry *polling* each printer — cold reader can't tell push vs. pull · *docs carry current intent, written to be read cold*
- **F4 (medium):** two Decisions & Alternatives rows are thin — `printer-registry`'s "Heartbeat interval: 15 s" names no rejected alternative or accepted cost, and the "three consecutive missed heartbeats" threshold isn't in the table at all · *docs carry current intent* (decision-capture keep-side)
- **F5 (medium):** the queue↔registry coupling isn't spelled out — `job-queue` says dispatch is "event-driven: when the registry reports a printer idle," but `printer-registry` describes polling on an interval; how the queue learns about the state transition is unstated · *docs carry current intent, written to be read cold*
- **F6 (medium):** the arrow stops at EARS — no tests, no code, no `@spec` annotations visible in the project · *canonical arrow shape* + *tests before code* (if implementation lives in another repo, link it from the HLD; if pre-implementation, that's fine — worth naming it)
- **F7 (low):** the HLD's three tenets are an unordered list, and tenet 2 ("queue explains itself") sits in real tension with tenet 3 ("service stays small") — worth ordering them so the tie-breaker is deterministic · *tenets capture forward-looking preference*

## 3. What was audited

- **Read fully:** `CLAUDE.md`; `docs/high-level-design.md`; `docs/intent/job-queue/job-queue-design.md`; `docs/intent/job-queue/job-queue-specs.md`; `docs/intent/printer-registry/printer-registry-design.md`; `docs/intent/printer-registry/printer-registry-specs.md`
- **Enumerated:** 1 HLD, 2 LLDs, 2 spec files, 8 EARS specs total (5 `QUEUE-*`, 3 `REG-*`), 5 Decisions & Alternatives rows across both LLDs
- **Arrow-path sampling:** not applicable — no tests or code found under the project root, so end-to-end HLD → LLD → spec → test → code sampling was not possible
- **Overlay:** `docs/arrows/` not present; no `index.yaml` to consult
- **Cold-read pass:** completed against all four LID docs

## 4. Worth a second look

Models in my class are known to miss designs that quietly contradict a project's own tenets and to under-weight linkage gaps that are visible only by comparing docs to each other rather than reading each on its own. F1 was a hit on the first flag; please spot-check both LLDs against the HLD's tenets yourself, and consider whether other LLD behaviors deserving specs slipped past F2.

## 5. Offer to help

Want me to walk through the findings in detail, focus on the two high-priority ones, or work through a specific finding together? You can also point me at any single finding to open a working session on it.

If you have broader questions about using LID for this project — where a PRD would fit above the HLD, when to promote a leaf LLD into a sub-HLD, how the arrow would extend once implementation lands, or how to handle multi-repo layouts if this ever grows past one service — I can help with those too.