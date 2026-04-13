## /deploy
Produce a pre-deployment checklist for the current branch.
Check:
- No console.log or debug statements left in code
- Environment variables documented in .env.example
- Database migrations are backwards-compatible
- API changes are versioned or non-breaking
- CHANGELOG.md updated
Flag any item that cannot be auto-verified.