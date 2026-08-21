# Brain: webhook retry queue

Slug: webhook-retries · Branch: feat/webhook-retries · Updated: 2026-08-21
Status: enqueue + backoff work end to end; dead-letter handling is half-built, worker untested.

## Goal
Outbound webhooks currently fire once and are lost on any 5xx. Add a retry queue with
exponential backoff and a dead-letter table so no delivery is silently dropped.

Done when:
- [ ] failed deliveries retry 5x with backoff, then land in `webhook_dead_letters`
- [ ] `pnpm test:webhooks` green, including the timeout case

## Constraints & invariants
- Delivery order per endpoint must be preserved; the queue is keyed by endpoint id.
- No new infra: reuse the existing pg-boss instance, not a new broker.
- Payloads are already signed; the retry path must not re-sign (receivers dedupe on signature).

## Decisions
| Decision | Why | Rejected alternative |
|---|---|---|
| pg-boss over BullMQ | already a dependency, one less service | BullMQ: needs Redis we don't run |
| backoff in the job, not cron | pg-boss retryDelay does it natively | cron sweep: adds a polling loop and a second code path |

## Dead ends
- **HTTP keep-alive agent shared across workers** → connections leaked under load → agent is per-worker now, see `src/webhooks/client.ts:18`

## Files that matter
| Path | Role in this feature |
|---|---|
| `src/webhooks/queue.ts` | enqueue + retry policy, the core of this feature |
| `src/webhooks/worker.ts` | delivery attempt, half-finished dead-letter branch |
| `migrations/0042_dead_letters.sql` | new table, already applied locally |

## Where we are
- Done: enqueue, backoff policy, migration
- In progress: `src/webhooks/worker.ts`, the `onFailedFinal` branch writes the row but doesn't mark the job complete
- Not started: metrics counter, docs

## Next actions
1. Finish `onFailedFinal` in `src/webhooks/worker.ts:74`: mark job complete after the dead-letter insert, then delete the TODO above it.
2. Add the timeout case to `test/webhooks/retry.test.ts`.

## Verification
- Run: `pnpm test:webhooks`
- Green looks like: 14 passing, including "retries then dead-letters on persistent 503"
- Known-failing, expected: the timeout test (not written yet)
