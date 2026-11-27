The key issue is **what “accepted” promises a member**. Your HLD says they can upload and walk away; the queue design currently requires them to notice a restart and resubmit.

### F1 — Restart behavior conflicts with that promise

`docs/intent/job-queue/job-queue-design.md:10–14` describes unattended OS updates and occasional power blips, then specifies that pending jobs live entirely in memory and disappear on restart. An evening upload could therefore be accepted, lost overnight, and never printed. Polling printers at startup recovers information about running jobs, but cannot recover jobs that never reached a printer. This is a *tenet cascade* concern — the mechanism should carry out the HLD’s declared priorities. The consequence is more than inconvenience: members must monitor submissions despite the upload-and-walk-away promise. Consider resolving that conflict explicitly before implementing recovery behavior.

### F2 — The tradeoff is missing from the decision record

The volatile queue is stated clearly, but its rationale is absent from the Decisions & Alternatives table. A cold reader would reasonably ask why accepted work is disposable when the registry already uses SQLite and uploaded files already survive on disk. Under *docs carry current intent* — preserve reasoning future readers need to understand a consequential choice — this deserves a decision row. Otherwise, future sessions may alternately preserve or reverse the choice without understanding your preference. Consider recording the chosen storage approach, the alternative rejected, and the cost accepted; a separate decision document seems unnecessary here.

### What I’d recommend doing next

First, settle the intended promise. You have three legitimate ways to resolve the conflict:

- **Change the queue design:** preserve accepted, pending jobs across service restarts, keeping the HLD’s promise.
- **Record an exception:** retain the volatile queue but explain why restart loss is acceptable, explicitly naming the upload-and-walk-away tenet being traded against. That also resolves F2.
- **Revise the promise:** make submission best-effort and clarify that members must check whether their jobs remain queued.

If you choose durability, **SQLite is a practical option to evaluate** for this small service. Persisting queue metadata would fit the existing deployment approach without requiring a separate database service. The LLD would need to settle a few behavioral details:

- A submission becomes “accepted” only after its file and queue record are durably stored.
- Restart recovery preserves pending jobs and their scheduling order, including staff reordering.
- Jobs whose dispatch outcome is uncertain are reconciled with printer state before retrying; durable storage alone does not prevent duplicate prints.
- Storage failures produce a clear rejection rather than a success response for work the service cannot retain.

Those decisions should then cascade through EARS, failing tests, and implementation using `/linked-intent-dev`. The existing startup spec, `QUEUE-004`, covers printer polling; it does not yet specify pending-queue recovery.

**Which promise do you want to keep: accepted jobs survive restarts, or submission remains best-effort with an explicit exception or revised HLD promise?**