Under LID, we apply the earns-its-place test looking forward from the landed state:

The question isn't how hard the choice was to decide, but whether a cold reader inspecting the system later would find 2Q non-obvious and be tempted to simplify it back to standard LRU without the full criteria and workload context laid out.

Because LRU is simpler and the external API remains unchanged regardless of policy, a cold reader would very likely ask: *"Why are we maintaining two separate queues and tuning a split parameter instead of plain LRU?"* A standalone decision doc preserves the screening-scan resistance vs. comparison-sheet retention tradeoffs and prevents re-litigating it.

If you'd like to proceed with the doc:
1. Would you like me to draft `docs/intent/previews/decisions/cache-eviction-policy.md` following the standard template (Context, Elements, Options, Analysis, Selection)?
2. Do you have a preferred default for the probationary-to-hot queue split (e.g., 25% / 75%) or should we leave the tuning parameter as an implementation detail / decision element?