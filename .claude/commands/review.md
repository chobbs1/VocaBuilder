## /review
Perform a code review on the selected file or function.
Check for:
- Unhandled errors or missing null checks
- Security issues (SQL injection, exposed secrets, unvalidated input)
- Performance bottlenecks (N+1 queries, unnecessary re-renders)
- Violations of .claude/context/conventions.md
Output as: Critical / Warning / Suggestion grouped list.