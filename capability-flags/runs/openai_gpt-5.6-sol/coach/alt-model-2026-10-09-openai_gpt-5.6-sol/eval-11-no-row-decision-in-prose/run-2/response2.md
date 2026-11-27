**F2 — High. The queue’s recovery behavior contradicts the project’s reliability promise.** `job-queue-design.md:10-16` explicitly anticipates unattended OS updates and power blips, but keeps accepted-job metadata only in memory. After a restart, polling printers can recover jobs already running, while accepted jobs still waiting for dispatch disappear and require member resubmission. Under *tenets capture forward-looking preference* — downstream mechanisms should follow the HLD’s declared lean — this works against both “a submitted job is a promise” and the goal of uploading at night and walking away. A member may reasonably believe a successful submission is safe, then discover the next morning that the job silently vanished.

**F3 — Medium. The volatility choice lacks the rationale needed to evaluate that conflict.** The Decisions & Alternatives table discusses scheduling, identifiers, and upload limits, but not whether accepted jobs survive process restarts. Under *docs carry current intent* — a cold reader should be able to reconstruct consequential tradeoffs — this is precisely the kind of choice that needs a row. Durable storage has an obvious cost in state management and recovery logic, while volatile storage has an obvious cost in reliability; neither is inherently invalid, but the current docs do not say why reliability was traded away or whether that trade was intentional.

The key distinction is between the uploaded file and the accepted job. The file survives on disk under its content hash, but the queue record containing ownership, target printer class, priority, order, and dispatch state does not. Retaining the file makes resubmission cheaper, but it does not fulfill the submitted-job promise.

I recommend settling the intended guarantee before choosing storage mechanics. There are three coherent directions:

1. **Make acceptance durable.** Persist the queue record before reporting the job as accepted. On startup, reconcile durable queued records with jobs currently reported by printers, taking care not to dispatch a recovered job twice. This preserves the current HLD tenet and overnight-printing goal.

2. **Narrow the meaning of acceptance.** Define submissions as best-effort until dispatch, make that limitation visible to members, and revise the HLD promise accordingly. This keeps the in-memory architecture but changes the product guarantee.

3. **Record an explicit exception.** Keep “a submitted job is a promise” as the general lean, but document why this small deployment accepts restart loss. Add a Decisions & Alternatives row naming durable queue storage as the rejected alternative and member resubmission as the accepted cost. This resolves the missing rationale, though the operational conflict remains deliberate.

Whichever direction you choose, cascade it in order:

1. Update `docs/high-level-design.md` only if the promise or an architectural exception changes.
2. Update `docs/intent/job-queue/job-queue-design.md`, including a Decisions & Alternatives row.
3. Add or revise EARS requirements for acceptance and restart recovery.
4. Mark those requirements `[ ]` until tests and implementation exist.
5. Write failing recovery tests before implementing persistence or best-effort behavior.
6. Add `@spec` annotations to the tests and queue entry points.

A dedicated decision document would be excessive here; one complete Decisions & Alternatives row should be enough unless evaluating several persistence and reconciliation strategies becomes a substantial design exercise.

Which guarantee do you want: durable acceptance, best-effort submission, or an explicit small-system exception?