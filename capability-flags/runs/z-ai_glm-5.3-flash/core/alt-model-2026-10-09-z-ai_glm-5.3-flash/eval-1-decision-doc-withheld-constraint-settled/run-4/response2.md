Overkill — I'd leave it as the table row it has now.

The test for a decision doc is whether the choice stays genuinely live for a cold reader: would someone re-litigate it without the competing options and criteria written out at length? Here, no. Once landed, the HLD's no-runtime-network tenet rules out both alternatives on its own — the HTTPS directory depends on lab network reachability at lookup time, and the managed service adds credentials and external connectivity, both direct tenet violations. A reader who questions the SQLite choice can trace the answer in one hop to an inherited constraint, which the skill treats as exactly the case that earns a row, not a doc.

The other symptom of a live decision — other design nodes sizing themselves around the result — isn't present either: certificates was explicitly insulated from the selection, and the sibling LLD is unchanged.

The Decisions & Alternatives row already names both rejected options and the tenet conflict, so a future reader who does wonder "why this?" has the short answer in place. The full doc would mostly restate the tenet and add upkeep.

(Also worth noting: the row for *index-per-snapshot with atomic rename* is the one a cold reader is more likely to question — that's a real internal trade-off with no tenet behind it. It's still row-level, but if either choice ever grows a doc, it's that one.)

Does that settle it? If so, give me your rulings on the probe items from the review and I'll move on to the edge audit.