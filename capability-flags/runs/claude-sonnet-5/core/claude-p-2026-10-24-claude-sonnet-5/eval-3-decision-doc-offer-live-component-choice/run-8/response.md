I read the skill and the project's current state. The record-store LLD (`docs/intent/record-store/record-store-design.md`) still has the "Open Design Choice: Concurrent Visit Edits" section open with both options sketched, exactly as it stood last session — nothing in the docs reflects a selection yet.

Before I draft the rest of the LLD around "whole-visit revisions," the skill has me settle how this decision gets recorded. This one plausibly earns a full decision doc rather than a one-line table row: it's a genuine multi-criteria tradeoff (review-queue volume vs. implementation burden vs. risk of silently combining scientifically related edits), it determines two other nodes' contracts (tablet-sync and review-export are explicitly sized around whatever record-store decides), and a cold reader of the finished record-store design would plausibly ask "why not merge disjoint edits automatically?" without the full reasoning in front of them.

Do you want this recorded as:
1. **A full decision doc** (`docs/intent/record-store/decisions/concurrent-visit-edits.md`) — options, criteria, and selection laid out so the tradeoff can be re-litigated later if review-queue volume becomes a real problem, or
2. **Just a Decisions & Alternatives row** in the record-store LLD — one line of rationale, no standalone doc?

Once you pick, I'll record it that way and finish drafting the rest of the record-store LLD (submission envelope, current-state response, unresolved-work representation, resolution operation) around whole-visit revisions, then stop for your review per the Phase 2 gate.