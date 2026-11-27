Per the decision doc guidance in linked-intent-dev, we evaluate whether to write a decision doc from the **landed state looking forward**, rather than from how hard it was to deliberate looking back:

> *Once this lands, would a cold reader find the choice non-obvious — would they question it, or be tempted to reverse it, not knowing why it went this way?*

Here:
- The decision is **purely internal** to the preview worker. Per the HLD tenets and API boundaries, no other node inspects cache files, pins entries, or consumes eviction metadata.
- Standard LRU is simpler and often the default choice developers reach for, so a cold reader encountering a multi-queue 2Q implementation (with ghost caches, tuning splits, and extra bookkeeping) might reasonably ask *"why not plain LRU?"*.
- The row in `previews-design.md`'s **Decisions & Alternatives** table directly answers that question in one sentence: plain LRU gets flushed by sequential screening scans, while 2Q protects comparison sheets without the counter aging issues of LFU.

However, if you feel that future maintainers will repeatedly question why plain LRU or frequency aging wasn't used, and need the formal trade-offs, gates, and criteria laid out to prevent re-litigating it, we can create a standalone decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md`.

Which would you prefer:
1. **Keep the Decisions & Alternatives table row** in `previews-design.md` (the standard LID approach for node-internal choices where a short rationale suffices).
2. **Draft a full decision doc** under `docs/intent/previews/decisions/cache-eviction-policy.md` detailing the criteria, competing options, and selection analysis.