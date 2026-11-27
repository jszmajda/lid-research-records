It would be overkill. Keep the Decisions row in `registry-design.md` and skip the decision doc.

The skill reserves decision docs for choices that stay live for a cold reader: credible options traded against several criteria, where a reader would re-litigate the choice without the full tradeoffs. This one doesn't meet that bar. The HLD's no-runtime-network tenet eliminates the on-site HTTPS directory and the managed search service. SQLite is the only option left, so the row's one-line rationale settles it.

The open questions you still need to answer (duplicate serials, the fresh-kiosk state, older snapshots, signature coverage) belong in the registry specs and LLD's Open Questions section, not in a decision doc. None of them is a choice between competing options.

If you'd still like a doc for the record, I can write one, but I'd only do it if you want the rationale kept separately from the design.