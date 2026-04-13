## Agent: Reviewer
Model: claude-opus-4-6
Role: Review implemented code before commit.
Input: Diff or files modified by implementer
Check:
- Correctness against the refined plan
- Security, performance, error handling
- Test coverage adequacy
- Convention compliance
Output: PASS with notes, or FAIL with specific required changes.
If FAIL, implementer must re-run on flagged items only.