I wrote the decision doc at `docs/decisions/change-delivery-approach.md`. It's still the Phase 1 stop. The HLD's Key Design Decisions row now links to the doc.

**What the doc contains**
- **Context:** why delivery has to be chosen before the three nodes. It names the workload and goals the choice must satisfy: 800 browsers, bursts of 20 edits per second, 20-minute recovery, and 99.5% availability.
- **Decision elements:** no option fails a gate, so it is weighted criteria only.
  - Major: vendor independence.
  - Moderate: operating burden, recurring cost, availability exposure, and change-store/browser complexity.
  - Minor: update latency beyond the 15-second ceiling.
- **Three options, each described as its advocate would:** polling, self-hosted sockets, and hosted realtime, with a fit verdict per criterion.
- **Selection:** self-hosted WebSockets. It states plainly that polling wins on operability and complexity, and that operating burden is the criterion this option is weakest on. That trade-off is the one you accepted. It also lists what the choice obligates in the change store, delivery, and browser sync.

**Please check these three judgments**
1. **Weights.** I ranked vendor independence as major, operating burden as moderate, and latency as minor, based on your reasoning that fast updates without a vendor outweigh the extra ops work. Please confirm that ordering; it drives the Selection.
2. **No tenet cited.** No existing tenet decides this choice, since both self-hosted and managed infrastructure are permitted. The doc says so instead of inventing one. That is still the open question about recording a vendor-independence tenet.
3. **Qualitative cost.** I included no dollar or capacity figures, because none exist in the project docs. If you have rough numbers for the vendor fees or socket hosting, they would make the cost criterion firmer.

The `access-design.md` wording about the "still-open" approach is also still waiting on your answer.

Reply with numbered feedback or approve. On approval I'll start Phase 2 with the change-store LLD.