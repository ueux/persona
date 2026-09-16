# Project Persona — Development Guides

This folder is the day-by-day build journal for Project Persona.
Each file documents one day of the build: what we set out to do, what
actually happened, and how to verify it worked.

## How to use this

- **Starting fresh?** Read days in order. Each day assumes the previous
  one is verified.
- **Resuming work?** Check [`progress.md`](./progress.md) for current state.
- **Debugging a setup?** Jump straight to [`troubleshooting.md`](./troubleshooting.md).
- **Verifying a clone?** Run [`verification.md`](./verification.md).

## Day index

| Day | Theme                          | Status |
|-----|--------------------------------|--------|
| 1   | Foundation & environment       | ✅     |
| 2   | Docker infrastructure          | ✅     |
| 3   | Database architecture (Prisma) | 🔓     |
| …   |                                |        |

Status key: ✅ verified · 🔓 in progress · 🔒 locked

## Conventions

- Every day has a **Definition of Done** — a checklist that must be
  fully green before the next day unlocks.
- Every day has a **Verification** section — copy-paste commands that
  prove the DoD. Do not rely on "it looked fine."
- **No secrets** in this folder. Dev credentials that appear here are
  throwaway and only reachable on localhost.
- File names are `day-NN-slug.md`. Zero-padded so they sort.