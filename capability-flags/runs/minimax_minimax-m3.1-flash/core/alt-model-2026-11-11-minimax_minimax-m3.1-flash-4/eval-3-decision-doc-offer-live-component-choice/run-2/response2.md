The decision doc is written and verified. Here's what landed.

**New file — `docs/intent/record-store/decisions/concurrency-mechanism.md`**

The choice earns a full decision doc rather than a table row, because a cold reader's obvious question is "why not merge disjoint fields automatically?" — that's exactly the question a decision doc exists to answer. It's owned by record-store, where the mechanism's substance lives, and carries no EARS IDs.

- **Decision Elements** — one gate that actually eliminates something (the mechanism must not require the system to judge whether two observations are scientifically related), plus six weighted criteria, four major and two moderate, each tagged with the tenet it derives from.
- **Both options get their strongest honest representation.** Field-aware merge is written as its advocate would write it, and eliminated on a real ground rather than a strawman: to merge at all, its rules must decide that two edits are independent, and that decision is scientific judgment the project doesn't encode.
- **Selection** names the three tenets the decision turns on, says what it forecloses, and what it obliges downstream.

**Why we'd still consider the other approach** is answered as three concrete revisit conditions rather than a vague "we might change our minds": the coordinator queue becoming unsustainable against the Friday deadline; the payload schema gaining structure that makes relatedness mechanical rather than scientific (stable species identifiers, structured observer lists); or the catalog taking on authoritative species identity. Each states what would have to be true, and the doc closes by saying a reconsideration is a new decision, not an amendment.

**The tablet and export obligations** are spelled out concretely in both the decision doc and the record-store design's new "Obligations on Tablet-Sync and Review-Export" section — what the tablet must retain, send, and treat as normal rather than as failure; what review-export must present side by side, withhold from the CSV, and keep retrievable afterward.

**Two corrections worth flagging**, both found by review and fixed in the design as well as the decision doc:

- The tablet obligation had said an unrecognised base revision means "the visit moved on while the tablet was offline." That's wrong — a base the visit *once held* isn't rejected, it's held as a competing revision for review. Rejection means the submission couldn't be placed in the visit's history at all.
- The rejected option was described as keying species entries by name so a changed cover estimate and a changed identification would escalate together — but a changed identification changes the key, so name-keying can't do that. The doc now says so plainly, which makes the gate's force clearer rather than weaker.

One thing I did not do: the decision doc is written and self-consistent, but nothing has implemented or tested any of it. The 54 record-store specs remain active gaps against a repository that still has no application code.