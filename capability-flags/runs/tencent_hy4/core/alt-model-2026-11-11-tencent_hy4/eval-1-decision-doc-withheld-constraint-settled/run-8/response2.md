**Overkill — no standalone decision doc, and I'm not putting it to a vote.**

The earns-its-place test is applied from the *landed* design, not from how close the options felt:

- **An inherited constraint already eliminates two of the three.** The HLD requires every lookup to complete from files on the kiosk with no runtime network access, states kiosks have no network route during normal operation, and lists cloud services as a non-goal. The on-site HTTPS directory (lab-network lookups + timeout handling) and the managed search service (external connectivity, credentials, recurring cost) both conflict with that. Only the local SQLite index is viable — and a choice "that an inherited constraint settles ... however long the debate ran" doesn't earn a doc. "I went back and forth" is deliberation difficulty, which the heuristic treats as a symptom, not the test.
- **It affects only its own node.** `findBySerial`'s result type and the certificate interface are unchanged, so no sibling design node is being sized around this result.

So I recorded it as one **Decisions & Alternatives** row in the registry LLD — the sanctioned home for rejected alternatives and why they were trimmed — rather than a doc, and *without offering* you a yes/no. People offered a doc tend to accept it whether or not it's needed. No decision doc was created.

Coherence pre-flight + Phase 2, done and stopped:
- `docs/high-level-design.md`: dropped the stale "private lookup backend remains open" line.
- `docs/intent/registry/registry-design.md`: rewrote as current intent — local embedded SQLite index rebuilt per kiosk on snapshot activation, normalized serial queried against the index; stripped the "not selected yet / pending the user's choice" residue; added the single Decisions row above.
- Certificates docs untouched — the interface is unchanged, so there's no cross-segment cascade to pause for. EARS specs REG-001–004 stay backend-agnostic; Phase 3 audits their coverage after you approve.

**LLD-level edge-case probe — please triage (fix in the LLD now vs. defer as open questions):**
1. First boot with no active snapshot: what does `findBySerial` return, and what snapshot date accompanies the result?
2. A snapshot imported while a lookup is in flight: does that lookup finish against the old index or see the new one?
3. "Reports a useful error" has no shape — what does the caller actually receive on import failure?
4. Index rebuild fails midway (e.g., disk full) after validation passed: is the previous snapshot retained and the partial index discarded?
5. REG-001 covers surrounding whitespace and uppercase ASCII letters — what about internal whitespace and non-ASCII letters?

I'm stopping at the Phase 2 boundary. Tell me which gaps to fix now vs. defer, and approve before I cascade into Phase 3 (EARS update + intent-narrowing edge audit).