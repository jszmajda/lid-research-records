Yes. This clears the decision-doc threshold: LRU, aged frequency, and 2Q remain credible choices with materially different behavior under screening scans, project switches, and operational overhead. A cold reader could reasonably revisit the choice without the full tradeoff record.

The doc should be owned by the preview segment at `docs/intent/previews/decisions/cache-replacement.md`, with the LLD linking to it. It would record the workload assumptions, selection criteria, each policy's strongest case, 2Q's 3 GiB/9 GiB split, and the pilot telemetry that could justify revisiting the split.

Should I create it before we continue the LLD review?