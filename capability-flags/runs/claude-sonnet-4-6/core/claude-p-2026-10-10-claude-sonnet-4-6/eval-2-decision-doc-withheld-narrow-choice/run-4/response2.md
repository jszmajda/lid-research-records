Good — the link is already there (`See decisions/eviction-policy.md`). The LLD row and doc are properly connected.

---

**Phase 2 — updated stop**

Three artifacts are now in place:

- **`docs/high-level-design.md`** — "eviction policy remains open" updated to "using 2Q replacement."
- **`docs/intent/previews/previews-design.md`** — Private Cache section replaced with the full 2Q design (A1/Am queues, admission, promotion, eviction order, A1 capacity default and rationale); Decisions & Alternatives table; Deferred questions.
- **`docs/intent/previews/decisions/eviction-policy.md`** — full decision doc: gate, four weighted criteria, per-option analysis (LRU / frequency-aging / 2Q), and selection with the tenet closure.

The edge-case probe surfaced two gaps still open for your triage:

1. **A1 size limit valid range**: the LLD doesn't yet state minimum/maximum valid values. Degenerate values (0 GiB or the full 12 GiB) would make 2Q behave as a single-queue policy. Should the worker reject these at startup, and what are the stated bounds?

2. **Concurrent eviction during an Am-hit read**: when Am's LRU end is evicted during a promotion, the LLD doesn't address what happens if that entry is currently being read to serve a pending 200 response. This is an I/O ordering question — worth settling before specs are written against it.

Please review and triage those two gaps (fix in the LLD, or move to Deferred), and say the word when you're happy with Phase 2. I'll move to Phase 3 (EARS specs) on your approval.