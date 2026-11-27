Under the decision-doc heuristic (*earns-its-place*), we test from the **landed state looking forward**:

> *Once this lands, would a cold reader of the result find the choice non-obvious — would they question it, or be tempted to reverse it, not knowing why it went this way?*

Here, **a table row is the better fit, and a full decision doc does not earn its place**:

1. **The debate was about the choice, but the landed result reads naturally**: The trade-off between LRU scan-vulnerability and 2Q scan-resistance is textbook for workloads alternating sequential scans and working-set re-reads. Once 2Q is in place, the rationale is cleanly captured in a single row without deep downstream systemic tension.
2. **All changes are completely private to one node**: The preview API contract, HTTP interface, render queue, and storage budget remain 100% unchanged. No other subsystem or team consumes or depends on this choice.
3. **Avoid memorializing deliberation residue**: The 180-message debate and three meetings are history from the deliberation, not forward-looking domain complexity that a cold reader would need to reconstruct.

That said, per the LID tenet *the user is always right (with warning)*, if you still want a full decision doc at `docs/intent/previews/decisions/cache-eviction-policy.md`, I can draft it for you. 

Do you want to proceed with the Decisions & Alternatives table row as-is, or would you like me to write the full decision doc anyway?