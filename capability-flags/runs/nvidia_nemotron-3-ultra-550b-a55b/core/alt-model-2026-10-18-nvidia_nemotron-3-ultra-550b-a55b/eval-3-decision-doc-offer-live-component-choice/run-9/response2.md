Now I need your decisions on the three forks from the edge audit:

**Fork A — Base revision validity:** When a worker submits an edit, must the base revision ID be the *latest resolved* revision, or can it be any revision in history (including competing/unresolved ones)?
- (a) Accept any existing revision ID — worker may have worked from an older competing copy
- (b) Require latest resolved revision — reject stale submissions, accept only competing-revision-based edits as new competing revisions

**Fork B — Coordinator manual field merge:** Can a coordinator pick fields from multiple competing revisions to build a new resolution, or is resolution strictly "select one" or "provide complete new payload"?
- (a) Resolution = select one competing revision OR provide complete new payload (no field picking)
- (b) Allow field picking from competing revisions, recorded as new resolved revision with all submission IDs as contributors

**Fork C — Post-resolution export eligibility:** Add explicit spec that resolved visits become export-eligible again?
- (a) Implicit (no spec needed — resolution clears the "unresolved" flag)
- (b) Explicit: add REC-015 "When a visit's competing revisions are resolved, the system SHALL make the visit eligible for export again."