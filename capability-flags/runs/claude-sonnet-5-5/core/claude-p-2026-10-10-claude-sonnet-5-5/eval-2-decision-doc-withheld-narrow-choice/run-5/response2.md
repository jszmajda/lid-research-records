Honestly, I'd keep it as the Decisions row and skip the standalone doc, though it's your call and I'll write one if you want it.

**Why the row is enough**
- **One node only.** Everything 2Q touches stays inside the preview worker. The review API, render queue and HLD contract are untouched, so no other node is being sized around this choice.
- **No one-sided tradeoff.** You picked 2Q because scan resistance matters more to you than the extra bookkeeping. A cold reader can follow that from the row and the Replacement Policy section without re-running the debate.
- **The debate isn't the artifact.** The three meetings and the 180-message thread explain why it was contentious, but a decision doc is meant to carry criteria and options a future reader would otherwise have to rebuild. It shouldn't be the record of how long we argued.

**When a doc would earn its place**
- You expect someone to propose "just use LRU" once the two-queue bookkeeping looks heavy. A doc can record the criteria, such as scan-resistance for comparison sheets, and the evidence that would reverse the call.
- You want the revisit triggers written down, for example "if pilot hit-rate data shows the protected queue rarely fills, reconsider." That is the strongest argument for a doc, and it would also give the open probation-fraction question a proper home.

If you want it, it goes in `docs/intent/previews/decisions/` and the Decisions row links to it. I'd keep it short: criteria, the three options with their consequences, the selection, and what would make us revisit.

Do you want the doc, or the row alone? Either way, I still need your answers on the probation fraction and ghost list length before I move to the specs.