I'd skip the decision doc and record the choice as a row in the previews LLD's Decisions & Alternatives table.

The skill reserves decision docs for choices that stay live for a cold reader and reshape other design nodes. This one doesn't. The eviction policy is private to the preview worker. The review API, the render queue, and the 12 GiB budget don't change, and no other node reads eviction metadata. The three options are already written down in `previews-design.md`, so a future reader can see what was rejected and why. A row that names LRU and frequency-with-aging as alternatives, with the scan-resistance rationale, is enough. A decision doc for a choice this local would be the kind of residue the workflow tries to avoid.

This is a judgment about the skill's criteria, not a rule you have to follow. If you want a standalone record anyway, I can write one, but I'd recommend the row.

The open items from the last stop still stand: the 2Q sizing (25/75 proposed), whether to include the ghost list, and the HLD sentence to delete. Once you answer those, I'll draft the previews LLD for Phase 2.