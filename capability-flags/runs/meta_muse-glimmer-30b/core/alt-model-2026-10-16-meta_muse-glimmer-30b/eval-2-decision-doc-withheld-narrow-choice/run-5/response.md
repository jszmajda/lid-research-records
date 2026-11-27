Phase 1 – HLD check

HLD `docs/high-level-design.md` covers the preview worker domain and remains coherent. The tenet *Keep cache paths and replacement bookkeeping private to the preview worker* is maintained. No architectural change is required; 2Q is an internal replacement policy change only.

Phase 2 – LLD updated

`docs/intent/previews/previews-design.md` now records the 2Q decision:

* Private Cache section updated to 2Q with Q1 first-use FIFO, Q2 reused FIFO, promotion on second access, eviction Q1 before Q2, 12 GiB total budget private to the worker.
* Decisions & Alternatives table added:

  * Decision: Eviction policy – Chosen 2Q; Alternatives LRU, frequency-based eviction with aging; Rationale: protects repeatedly accessed comparison sheets from one-off screening scans, extra bookkeeping acceptable.
  * Decision: Queue size split – Chosen 6 GiB Q1 / 6 GiB Q2 configurable; Rationale: balanced start point, tunable without interface change.

Phase 3 – EARS specs updated

`docs/intent/previews/previews-specs.md` now contains:

* PREVIEW-006: When a preview is admitted to cache for the first time, the system SHALL place it in Q1.
* PREVIEW-007: When a preview currently in Q1 is requested again, the system SHALL promote it to Q2.
* PREVIEW-008: When eviction is required to admit a new preview, the system SHALL evict entries from Q1 before evicting entries from Q2.
* PREVIEW-009: The system SHALL maintain separate size budgets for Q1 and Q2 that sum to 12 GiB, with replacement metadata kept private to the preview worker.

Consistency check:
* Coverage: LLD’s 2Q flow is covered by PREVIEW-006/007/008/009.
* Contradiction: none found.
* Implicit scoping: none; specs stand alone.

Phase 4 – Intent-narrowing edge audit, needs your resolution before tests

1. Queue size split: 6 GiB / 6 GiB is a starting point. Do you want to lock this split, allow runtime configuration, or use a different ratio e.g., 4 GiB Q1 / 8 GiB Q2?
2. Eviction ordering within queues: LLD states FIFO. Should PREVIEW-008 be narrowed to “evict the oldest entry in Q1 first, then oldest in Q2” explicitly?
3. Promotion semantics on concurrent hits: If two requests hit a Q1 entry simultaneously, promotion to Q2 should happen once. Acceptable?

Confirm the split/ratio and the two edge clarifications, and I will proceed to Phase 5 Tests-first and Phase 6 Code with `@spec` annotations.