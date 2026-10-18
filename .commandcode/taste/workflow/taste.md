# Workflow

- Researches and gathers thorough "recon" before making any changes; do the investigation/context-gathering first. Confidence: 0.8
- Produces a plan before editing anything, to keep track of the work and avoid losing the thread. Confidence: 0.8
- Tries things in a sandbox first before touching the real system. Confidence: 0.8
- Treats git as strictly read-only by default: never runs commit/push/add/stage/stash/checkout/reset or creates branches/tags; handles all staging and committing manually unless explicitly commanded to commit in a specific prompt. Confidence: 0.9
- When explicitly asked to commit, wants plain, concise commit messages with no AI attribution (no Co-Authored-By lines, no "Generated with..." trailers). Confidence: 0.9
- Requires documentation to be synced after any change to code, config, or scripts, and wants responses to end with an explicit docs-check status line listing what was updated. Confidence: 0.8
