Updated the preview design for 2Q. The HLD preview node now reads "private 12 GiB cache managed by 2Q replacement," and `previews-design.md` replaces the open-policy paragraph with the chosen design:

- **A1in (probationary, FIFO):** first admission after a single request.
- **Am (protected, LRU):** a second hit promotes from A1in; A1out hits enter directly.
- **A1out (ghost history):** keys only, bounded to A1in's entry count, so a sheet evicted before its second use is still recognized as reused.
- Initial split 25% A1in / 75% Am, tunable; admission and promotion order written out; total JPEG data stays within 12 GiB; all queue state private to the worker.
- Decisions & Alternatives records 2Q versus LRU/aged frequency, the split, the ghost representation, and replacement-state ownership. Split tuning and hit-rate instrumentation are deferred.

The LLD edge probe found these gaps in the new replacement design. My proposed defaults are in brackets; tell me which to fold in now and which to defer:

1. Are 3/9 GiB hard per-queue caps or targets that promotion may cross? [targets; 12 GiB total is the hard bound]
2. On an A1out hit, is the key removed from A1out when the sheet enters Am? [yes]
3. Is an A1out key admitted to Am at request time or only after rendering completes? [after completion, when data exists]
4. When A1in shrinks, which end of A1out is discarded? [oldest first]
5. Which rule wins for a reused-but-oversize sheet: straight to Am, or A1in because of its size? [straight to Am]
6. What happens to a sheet larger than the full 12 GiB budget? [served uncached]
7. When Am evicts an entry, is its key forgotten so a later request restarts in A1in? [yes]

The probe also flagged existing gaps unrelated to 2Q: polling behavior after a failed job, ticket expiry, admission-before-response ordering, 404/202 body shapes, and deduplication of concurrent A1out hits. Should those be deferred to the implementation pass, or fixed now?

Approve this LLD as the basis for the EARS spec update, or redirect any of the above?