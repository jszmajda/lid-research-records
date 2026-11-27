I wrote the decision doc at `docs/decisions/change-delivery-transport.md` and linked it from the HLD's Key Design Decisions entry. I did not run any tests, since this is docs only.

**What it covers**
- **Context:** why the choice exists, the scale (800 browsers, 20 edits/s bursts, 15-second and 20-minute goals), and that all three options meet the freshness goal. It says plainly that the decision turns on who operates the live connection and how much the board depends on a vendor, not on freshness.
- **Decision elements:** no option is eliminated by a gate. The weighted criteria are:
  - Provider independence (major).
  - Update latency, connection and reconnect operations, and recurring cost (moderate).
  - Read load (minor).
- **Options:** each of the three is described in its strongest honest form, with a fit verdict per criterion.
- **Selection:** why self-hosted WebSockets win, and that the weak fit on connection and reconnect operations is accepted deliberately. It states that polling would have met every stated goal with less operating work, and when the choice should be revisited. It also lists what the choice obligates in change store, delivery and browser sync.

**For you to check**
1. **Criteria weights:** I set provider independence as major and the rest as moderate or minor, based on your stated reasoning. If you weigh them differently, the Selection changes.
2. **The revisit condition:** "revisit if the operating work outweighs the value of the speed" is my wording of your tradeoff. Say so if you'd put it differently.
3. **Tenet:** the doc cites the existing "self-hosted and managed infrastructure are both permitted" tenet. I still haven't added a tenet preferring self-operated infrastructure, since that is your call.
4. **Access cascade:** the stale "still-open change-delivery approach" wording in `access-design.md` is untouched, pending your OK.

Reply with numbered feedback or approval. Once you approve, we move to the three node LLDs.