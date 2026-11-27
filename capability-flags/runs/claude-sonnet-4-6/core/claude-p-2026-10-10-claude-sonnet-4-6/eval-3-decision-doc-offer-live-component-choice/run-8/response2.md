Decision doc written at `docs/intent/record-store/decisions/concurrency-policy.md` and linked from the LLD. Here's what it covers and why each piece is there.

**Context** — sets up why this decision exists from the domain (shared tablets, 48-hour offline windows, concurrent field corrections) without any reference to our conversation. A cold reader understands the stakes: wrong choice either silently corrupts records or buries coordinators.

**Decision elements** — three things do real work as criteria:
- Scientific integrity (major): turns on the inspectability tenet — can every exported value be traced back to a single submitted observation?
- Coordinator workload (major): turns on the "two coordinators, no sysadmin" tenet — but this one cuts toward the other option
- Implementation/maintenance burden (moderate): also the sysadmin tenet — merge rules are a maintenance surface that needs ongoing domain expertise, not just technical upkeep

**Option A analysis** names the essential trade explicitly: *bigger review queue, zero automatic combination logic, complete traceability*. Option B gets its strongest honest representation — the workload reduction is real and significant — before the analysis shows where it fails.

**Selection** explains why the failure modes are the deciding factor: a silent merge error exits the queue and reaches the science partner; a noisy conflict item is visible and correctable before Friday. It also calls out the species-code/cover-class coupling explicitly as the hardest case — the one where field-name-keyed merge rules would silently produce a wrong record — and names what this commits downstream: tablet-sync carries the head revision ID, review-export carries the conflict comparison screen and the export hold.

Still at Phase 2. Ready to proceed to Phase 3 (EARS specs) on your say-so.