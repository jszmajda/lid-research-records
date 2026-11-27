I’d keep this as a **Decisions & Alternatives row**, not a full decision doc.

The landed-state test weighs against one: 2Q changes only private preview-cache bookkeeping, while the API, render queue, cache budget, and sibling design remain unchanged. A cold reader may ask “why 2Q?”, but the existing row answers that directly: sequential screenings should not displace repeatedly used comparison sheets.

The length of the debate alone does not make the decision doc-worthy. If you still want the fuller record for team context, say so and I’ll add it, but my design recommendation is to keep the row.