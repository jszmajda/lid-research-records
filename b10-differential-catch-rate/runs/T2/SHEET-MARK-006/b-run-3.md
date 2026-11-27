**Concern: transport failure during the marks settle/read-back pass**

**Ubiquitous.** `SheetsViewClient::read_price_pass` returns `Result<PricePass, ViewError>`. A transport-level failure (workbook unreachable) is surfaced as `Err`, distinct in kind from a per-symbol `PriceReading::Transient`/`Permanent` value carried inside an `Ok` pass.

**Event-driven.** WHEN any poll of the settle loop (`read_marks`'s call to `client.read_price_pass()`) returns `Err` — whether on the first poll or a later one, and regardless of how many polls remain in the bounded window — the system shall immediately abort the poll loop and propagate that `Err` as `read_marks`'s own return value, producing no `MarksProduced`.

**Unwanted behavior.** IF `read_price_pass` fails, THEN `read_marks` shall NOT return `Ok` with an empty/default `MarksProduced`. An empty result is indistinguishable from "every requested symbol degraded" and would wrongly null out live positions on the next replay.

**Unwanted behavior.** IF `read_price_pass` fails, THEN `read_marks` shall NOT itself merge, retain, or return the caller-supplied `prior` marks map as a fallback. Carrying the previous cycle's cached marks (with their quote-date stamps) forward on transport failure is the caller's (`runtime`'s) responsibility, performed outside `read_marks` on receipt of the propagated `Err` — `read_marks` performs no carry-forward of its own on this path.

**State-driven (boundary vs. transient retry).** WHILE the settle pass is within its bounded retry window (`SettleConfig::max_polls`, default `8`), a transport `Err` on any single poll shall end the pass at that poll immediately — it is never treated as a retryable transient reading (unlike `PriceReading::Transient`, which is retried up to `max_polls` and only then degrades per-symbol to `TimedOut`), and it is never absorbed into the poll budget as a retry.

**Unwanted behavior (boundary vs. cold start).** A missing view tab (fresh/uncreated workbook) shall NOT be classified as a transport failure for this pass: `read_price_pass` returns `Ok` with an empty `PricePass`, and `read_marks` over the resulting empty pass completes as an empty, non-error `MarksProduced` rather than propagating `Err` — mirroring the store side's 400-vs-unreachable classification split, applied here to the price read-back rather than row reads.