I wrote the decision doc at `docs/decisions/change-delivery-approach.md` and linked it from the HLD's Key Design Decisions entry. Nothing is committed.

The doc sets out the context, the gates all three options pass, the weighted criteria, each option with its strongest case, and the selection. It also names what the choice forecloses and what it obligates for the change store, delivery, and browser sync. It records the trade plainly: operational burden is a major criterion, and it cuts against the choice. Session authorization complexity is also a real cost that favors polling.

Two things need your decision:

1. **Missing tenet.** The doc says no tenet leans toward this choice. The weighting comes from your stated priority against vendor coupling, which is not in the HLD. Do you want a tenet for it, such as a line on owning infrastructure versus paying a vendor? If so, what is the lean?
2. **Latency goal.** The HLD still says 15 seconds. This is the same question as before, and it still needs your answer.

The git index shows `docs/high-level-design.md` as staged. I did not stage it, so you may want to check it before committing.

Please review the HLD changes and the decision doc at this stop. Once you approve, I'll move on to the change-store node.