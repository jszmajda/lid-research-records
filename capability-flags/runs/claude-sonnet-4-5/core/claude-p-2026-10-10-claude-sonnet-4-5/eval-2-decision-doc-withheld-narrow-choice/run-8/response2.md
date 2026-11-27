You're right to question it. Let me apply the test from the skill's decision doc guidance:

**The deciding question**: Would a future maintainer, looking at this code without our conversation, question the 2Q choice or be tempted to "simplify" it back to LRU?

I think **yes** — 2Q is less common than LRU, has more moving parts, and without the context of the screening-vs-comparison workload pattern, it could look like over-engineering. A maintainer six months from now might see the two queues and think "why not just use LRU?"

The decision has:
- ✅ Three credible options with real tradeoffs
- ✅ Multiple competing criteria (scan resistance, bookkeeping cost, adaptation speed)
- ❓ Other design nodes sized around it — no, it's private to the preview worker
- ✅ Would a cold reader question it — likely yes

That third point argues against a doc (it's a contained choice), but the fourth point argues for one (it's non-obvious). The fact that you had three meetings and 180 messages about it suggests the decision space is genuinely complex.

**My recommendation**: Write the decision doc. The table row captures *what* was chosen, but a doc would preserve *why each option fails for this specific workload*, which is the context most likely to erode. When someone suggests "let's just use LRU," the doc lets them re-run the judgment instead of rediscovering why that doesn't work here.

Should I draft it?