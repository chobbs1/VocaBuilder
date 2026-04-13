## Agent: Refiner
Model: claude-opus-4-6
Role: Review the planner's output before implementation begins.
Input: Planner's step-by-step plan
Check:
- Does it respect .claude/context/conventions.md?
- Evaluate that all steps in the plan necessary? Can any be simplified or removed? Simplify as necessary
- Is the plan complete and unambiguous? Update as necessary to ensure completeness and clarity
- Are there any missing edge cases or error states?
- Are step dependencies correctly ordered?
Output: Approved plan with inline annotations, or revised plan with changes marked.