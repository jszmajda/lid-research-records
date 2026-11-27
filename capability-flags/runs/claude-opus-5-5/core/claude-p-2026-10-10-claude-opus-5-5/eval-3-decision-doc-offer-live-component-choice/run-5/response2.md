The decision doc is written at `docs/intent/record-store/decisions/concurrent-visit-edits.md`, and the record-store design's Decisions row now links to it instead of carrying the full argument.

- **Why whole-visit revisions:** a merge rule fails invisibly, by exporting a visit nobody observed. Whole-visit revisions fail visibly, as a long review queue and visits listed as held out. The doc states plainly that this is chosen against review workload and export readiness, where merge is better.
- **Why we'd still consider merge:** reopen if contested visits are routinely unresolved at Friday's export, or if review crowds out the coordinators' other work. The stored history lets you count, after a season, how many contested visits had edits to entirely different fields. Whole-visit history already holds what a merge needs, so switching later needs nothing new from tablets.
- **What tablet-sync must accommodate:**
  - generate revision IDs and keep each draft's base revision ID, with no snapshot of the starting values;
  - always submit the whole visit, and submit offline edits in order;
  - present "accepted but competing" as a normal outcome and not an error to retry.
- **What review-export must accommodate:**
  - a queue of contested visits and a whole-visit comparison screen;
  - export from settled visits only, with held-out visits visible before Friday;
  - a queue where many resolutions are obvious, so the screen should make those quick.

One thing to check when you read it: the doc says the frequency of concurrent corrections has never been measured, because the old spreadsheet process overwrote them. If you do have a sense of that number, it belongs in the Context section.

The design itself is still waiting on the eight questions from my last message, plus whether to fix the stale sentence in the site-catalog design. The ones that most shape the contract are:

1. Can a coordinator write a replacement revision, or only keep one of the competing ones?
2. Should only the author be able to supersede their own competing revision?
3. Should the history record each state change with its time, so a past export can be traced after a late edit re-contests a visit?
4. On shared tablets, should a draft carry its author from when it was written?

Questions 5–8 are the plot change, the mid-chain rejection, the contract gaps and the duplicate first revision. I'll revise the design and move to the specs once you've answered.