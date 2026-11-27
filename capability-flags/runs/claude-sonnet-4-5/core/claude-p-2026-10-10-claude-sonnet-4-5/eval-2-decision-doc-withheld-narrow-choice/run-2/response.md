Now running an LLD-level edge-case probe to identify gaps in the 2Q design:

**Edge cases and gaps identified:**

1. **Queue membership tracking**: How is "accessed exactly once" vs "more than once" tracked? The design says new admissions enter A1 and are promoted on second access, but doesn't specify the data structure maintaining access counts or queue membership.

2. **Concurrent promotion and eviction**: What happens when a preview in A1 is being accessed (triggering promotion to Am) at the same moment that A1 needs to evict it to make room for a new admission?

3. **Variable preview sizes**: The queue capacities are stated in GiB (3 GiB and 9 GiB), but previews may vary in size. How is the "at capacity" check performed - by total bytes or by entry count? What happens when a single 4 GiB preview needs admission to the 3 GiB A1 queue?

4. **Render completion for cached key**: What happens if a render job completes for a preview that was already cached (possibly re-admitted or promoted) while rendering was in progress?

5. **Cache corruption**: What happens if a preview is listed in Am but its JPEG file is missing or corrupted on disk? Does a hit attempt trigger re-rendering, or does it surface an error?

6. **Eviction and admission atomicity**: When promoting from A1 to Am requires evicting from Am first, what's the atomicity guarantee? Can a concurrent request observe a state where the preview exists in neither queue?

7. **Queue size enforcement across varying file sizes**: If Am holds many small previews and A1 holds few large ones, the 25%/75% capacity split might not align with the number of evictions needed. How is this balanced?

8. **Warm cache startup**: When the preview worker restarts with cached files on disk, how are they distributed between A1 and Am? Are they all cold-started into A1, or is prior queue membership persisted?

Which of these gaps should be resolved in the LLD before moving to EARS specs?