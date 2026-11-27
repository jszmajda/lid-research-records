I wrote the decision doc at `docs/decisions/change-delivery-approach.md` and linked it from the HLD's Key Design Decisions entry. I haven't started on the LLDs yet.

**What it contains**
- **Context:** why the choice has to be made at the HLD, since it shapes the change store, delivery, and browser sync together. It includes the load figures and the data-sensitivity note that kept a hosted option viable.
- **Gates:** the HLD's freshness, scale, recovery, single-revision, and visible-connectivity requirements. All three options pass these, so they don't decide the choice.
- **Weighted criteria:**
  - Provider coupling (major)
  - Update latency (moderate)
  - Connection and reconnect operations burden (moderate)
  - Recurring cost (minor)
  - Statelessness (minor)
- **Options:** each of the three, described as its advocate would, with a fit verdict per criterion.
- **Selection:** self-hosted WebSockets wins because it is the only option strong on both coupling and latency. The doc says plainly that the operations burden was accepted knowingly, and that polling would also have met the 15-second goal.

**Please check**
1. **Criteria weights:** I set provider coupling as major, latency and operations burden as moderate, and cost and statelessness as minor. These come from your stated reasoning, not from anything the HLD declares. Reweighting any of them could change the Selection narrative.
2. **No tenet decides this:** the doc says the choice rests on a preference for owning the delivery path, since the existing tenet permits both self-hosted and managed infrastructure. If you want that preference to guide future choices like this one, say so and I'll propose a one-line tenet.
3. **Fallback:** I wrote that polling is the fallback if the operations burden proves too heavy, because replayable revisions and catch-up already serve it. Confirm that matches your intent, or I'll remove it.
4. **Polling load figure:** I included about 160 requests per second for polling at full attendance. That is my arithmetic (800 browsers every five seconds), not a figure from your notes.

**Still pending from earlier**
- The wording fix in `docs/intent/access/access-design.md` ("still-open change-delivery approach") is waiting for your go-ahead, since it's in another segment.
- Your answers on the tenet wording and whether to tighten the 15-second freshness goal.

Once you approve the HLD and this doc, I'll start the change-store LLD (Phase 2).