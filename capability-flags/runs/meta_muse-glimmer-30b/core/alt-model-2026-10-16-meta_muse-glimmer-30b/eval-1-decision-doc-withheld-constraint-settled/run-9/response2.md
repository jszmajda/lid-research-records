A table row is sufficient for this choice.

The lookup-backend decision is load-bearing and you traded off three concrete alternatives against the project's tenets — no runtime network, offline-first, cost/credentials — and the rationale is reconstructible from the HLD tenets and the alternatives you sketched. A cold reader can see why local SQLite wins without needing a full decision doc, and the choice is bounded to the Registry leaf.

A decision doc would be warranted if the choice stayed genuinely live — e.g., if you expected future re-litigation across segments, or if the selection criteria involved more than one competing project goal that would need re-weighing later. It’s not the case here: the tenets settle it, and the downstream impact is contained to Registry’s internal index rebuild.

Current recording in the LLD’s Decisions & Alternatives table meets the *docs carry current intent* test. If you want a decision doc for audit trail, I can draft one in `docs/intent/registry/decisions/`, but on the earns-its-place heuristic it would be overkill.
