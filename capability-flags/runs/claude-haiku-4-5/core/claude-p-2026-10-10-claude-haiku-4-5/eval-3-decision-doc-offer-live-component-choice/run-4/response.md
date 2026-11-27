Now let me run an LLD-level edge-case probe to identify gaps that should be addressed or explicitly deferred:

**LLD-Level Edge-Case Probe — Record Store**

1. **Accepted revision + new submission on same base**: If revision A is the current (accepted) revision and a tablet submits a new edit from that same base, the submission becomes unresolved by rule REC-002. Is this the intended behavior, or should a submission against an already-accepted current revision be treated as a new edit of the current state?

2. **Concurrent coordinator resolution**: If two coordinators simultaneously resolve the same unresolved visit (one accepting a revision, one discarding it), which decision wins? Is there optimistic locking or should the second coordinator see a conflict?

3. **Manual combination and further conflicts**: When a coordinator manually combines two revisions into a new revision, if a third independent submission arrives for that same visit in the meantime, does the manually-combined revision now become another competitor to that third submission?

4. **Revision retention and pruning**: The design does not specify how long revision histories are retained. Should very old unaccepted revisions (rejected after weeks) be pruned, or retained forever for audit?

5. **Revision ordering in conflict display**: When multiple unresolved revisions exist, what sort order should the coordinator interface present them? (Arrival order, author, base revision date, or another criterion?)

6. **Base revision communication**: After a submission is accepted, how does the server communicate the new revision ID back to the tablet so it can use it as the base for the next edit? Is this in the submission response, or does the tablet query separately?

7. **Bounds on competing revisions**: Is there a maximum number of unresolved revisions per visit before the system rejects new submissions, or is that unbounded?

8. **Plot reference changes**: Can a submission change the plot ID of a visit, or is the plot ID fixed at visit creation?

**Findings to surface to user:**

These gaps are normal and expected — they either represent design choices the LLD should make or deferred decisions that belong in the "Open Questions" section. I'm presenting them now so you can triage which should be addressed in the LLD, which should move to open questions, and which can stay deferred for now.

---

Which of these would you like to address in the LLD now, and which should move to the Open Questions section?