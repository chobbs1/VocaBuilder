## /test
Generate tests for the selected code.
Rules:
- Use Jest + testing-library conventions
- Cover happy path, edge cases, and error states
- Mock external dependencies (DB, APIs) at the service boundary
- Follow naming pattern: `describe('ClassName') > it('should ...')`
- Do not test implementation details, test behaviour