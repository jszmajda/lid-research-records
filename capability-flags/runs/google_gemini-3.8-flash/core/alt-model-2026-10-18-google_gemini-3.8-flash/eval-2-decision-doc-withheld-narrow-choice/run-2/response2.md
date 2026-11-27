Under the linked-intent development decision-doc guidance, we evaluate whether to write a full decision doc from the **landed state looking forward**, rather than from the deliberation looking back:

> *Once this lands, would a cold reader of the result find the choice non-obvious — would they question it, or be tempted to reverse it, not knowing why it went this way?*

Here, a full decision doc is likely unwarranted:
- **Scope is strictly local and contained**: The choice of eviction policy changes nothing outside the preview worker's private cache—no APIs, job ticket semantics, disk limits (12 GiB), or review API interactions change.
- **Settled cleanly by workload characteristics**: FrameDesk editors alternate between sequential screenings and repeated comparisons. 2Q directly addresses scan pollution while keeping recent working sets hot; once explained, the rationale is clear and self-evident for this workload.
- **A Decisions & Alternatives row settles it**: A cold reader wondering "why 2Q instead of plain LRU or LFU?" has their question answered directly by the row in `docs/intent/previews/previews-design.md`: 2Q prevents sequential scans from wiping out comparison working sets without carrying the counter-aging baggage of LFU, with all complexity private to the preview worker.

I have updated `docs/high-level-design.md` and `docs/intent/previews/previews-design.md` to specify the 2Q eviction architecture and recorded the choice and rationale in the Decisions & Alternatives table.

**Edge-case probe for the 2Q design in `previews-design.md`:**
1. *Ghost queue memory & lifetime*: What happens if an editor re-requests a clip whose key was evicted from $A1out$? Does $A1out$ track only keys or also file sizes?
2. *Queue capacity thresholds during large admissions*: When an admitted sheet is larger than the remaining budget in $A1in$, does eviction drain $A1in$ below its target fraction before touching $Am$?
3. *Cache re-admission race*: If concurrent requests trigger re-admission for a key in $A1out$, how does deduplication coordinate the transition directly into $Am$?

Would you like to keep this recorded in the Decisions & Alternatives table as drafted, or would you still prefer a dedicated decision doc under `docs/intent/previews/decisions/`?