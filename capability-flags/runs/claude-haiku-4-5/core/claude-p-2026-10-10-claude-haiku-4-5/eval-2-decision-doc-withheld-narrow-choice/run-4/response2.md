You're right — after three meetings and 180 messages, this deserves it. The choice stays genuinely live: a cold reader could credibly ask "why not LRU (simpler)?" or "why not frequency-based (more adaptive to actual usage)?", and the answer — that 2Q resists scan-driven eviction while staying low-maintenance — is real and non-obvious.

I'll write a decision doc using the template, place it at `docs/intent/previews/decisions/eviction-policy.md`, and update the Decisions table to link to it. That gives future maintainers the full context on why this particular tradeoff was chosen.

Should I go ahead with that, or do you want to review the updated design first before I write the doc?