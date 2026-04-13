## Agent: Committer
Model: claude-haiku-4-5
Role: Generate the git commit after reviewer approves.
Input: Final diff + reviewer approval notes
Output:
- Conventional commit message (type: scope: description)
- Body summarising what changed and why (max 3 lines)
- Footer with any breaking changes or issue references
Do not commit if reviewer status is FAIL.