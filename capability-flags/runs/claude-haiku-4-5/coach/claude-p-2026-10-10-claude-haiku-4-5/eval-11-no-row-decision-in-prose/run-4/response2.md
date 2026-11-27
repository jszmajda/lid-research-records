**F1 — High. The in-memory queue design loses unstarted jobs on restart.**

The job-queue architecture stores accepted jobs entirely in process memory; on startup, it rebuilds its view by polling each printer for its current job. This means jobs that were accepted but not yet dispatched before a restart are gone — members have to resubmit them. It's a clear architectural choice, made for simplicity on modest hardware. But it's not in the job-queue Decisions & Alternatives table, which currently records three choices (scheduling order, job IDs, upload size limit) but not this one.

Why this matters: The HLD tenet says "A submitted job is a promise: members should be able to upload and walk away." The word "promise" is ambiguous in light of the in-memory design — does it mean the job will eventually run (durability promise), or just that members don't need to babysit the queue after uploading (UX promise)? A cold reader of the HLD alone wouldn't know about the restart loss; it's only when they read the job-queue design that they hit the architecture choice. Without an explicit decision row, the next session reading this design won't know whether the job loss was a considered trade-off or an overlooked consequence. That ambiguity compounds as implementation starts and tests have to decide what "accepted" really guarantees.

**Two remedies**: You can either record the decision in the table, or clarify the tenet itself — or both. Most projects find a Decisions row sufficient. **Recommend adding a row to job-queue-design.md's Decisions table:**

```
| Job persistence across restarts | In-process queue, unstarted jobs lost on restart | Members resubmit on rare restart; accepted cost: no durability, simpler implementation on modest hardware. Tenets prioritize responsive uploads and small footprint; persistence would require disk/DB writes on each accept |
```

This row serves two purposes: it documents the choice for future sessions, and it grounds the tenet by clarifying which promise it makes (UX, not durability). If you later decide you want durability (say, if restarts become frequent), you'll have the option space on record.

Alternatively, if you want to tighten the tenet itself so it's unambiguous from the start, you could revise it to: "Members can upload and walk away without waiting for confirmation — the service takes over from there." That phrasing explicitly carves out system restarts as exceptional. Either way works; the table row is the faster move and leaves the tenet as-is.