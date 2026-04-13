import os
import sys
import anthropic
from dotenv import load_dotenv

load_dotenv()

client = anthropic.Anthropic()

AGENTS = {
    "planner":     {"model": "claude-opus-4-6",           "instructions": ".claude/agents/planner.md"},
    "refiner":     {"model": "claude-opus-4-6",           "instructions": ".claude/agents/refiner.md"},
    "implementer": {"model": "claude-sonnet-4-6",         "instructions": ".claude/agents/implementer.md"},
    "reviewer":    {"model": "claude-opus-4-6",           "instructions": ".claude/agents/reviewer.md"},
    "committer":   {"model": "claude-haiku-4-5-20251001", "instructions": ".claude/agents/committer.md"},
}

def load_agent(name: str) -> dict:
    agent = AGENTS[name]
    with open(agent["instructions"], "r") as f:
        system = f.read()
    return {"model": agent["model"], "system": system}


def run_agent(name: str, input_text: str, use_advisor: bool = False) -> str:
    agent = load_agent(name)
    print(f"\n▶ Running {name} ({agent['model']})...")

    if use_advisor:
        response = client.beta.messages.create(
            model=agent["model"],
            max_tokens=4096,
            system=agent["system"],
            tools=[{
                "type": "advisor_20260301",
                "name": "advisor",
                "model": "claude-opus-4-6",
            }],
            messages=[{"role": "user", "content": input_text}],
            betas=["advisor-tool-2026-03-01"],
        )
    else:
        response = client.messages.create(
            model=agent["model"],
            max_tokens=4096,
            system=agent["system"],
            messages=[{"role": "user", "content": input_text}],
        )

    return "\n".join(
        block.text for block in response.content
        if block.type == "text"
    )


def run_commit(plan: str, implementation: str) -> dict:
    commit_msg = run_agent(
        "committer",
        f"Plan:\n{plan}\n\nFinal implementation:\n{implementation}\n\nReviewer: PASS"
    )
    print("\n✅ Pipeline complete")
    print("\nCommit message:\n", commit_msg)
    return {"implementation": implementation, "commit_msg": commit_msg}


def run_pipeline(task: str) -> dict:
    # 1. Plan
    plan = run_agent("planner", task)

    # 2. Refine
    refined_plan = run_agent(
        "refiner",
        f"Task:\n{task}\n\nPlan:\n{plan}"
    )

    # Add loop here to allow for multiple rounds of refinement

    # 3. Implement — Sonnet with Opus advisor
    implementation = run_agent(
        "implementer",
        f"Refined Plan:\n{refined_plan}",
        use_advisor=True
    )

    # 4. Review
    review_result = run_agent(
        "reviewer",
        f"Plan:\n{refined_plan}\n\nImplementation:\n{implementation}"
    )

    # 5. Gate on reviewer pass/fail
    if "fail" in review_result.lower():
        print("⛔ Review failed. Re-running implementer on flagged items...")
        implementation = run_agent(
            "implementer",
            f"Review feedback:\n{review_result}\n\nOriginal implementation:\n{implementation}",
            use_advisor=True
        )

    return run_commit(refined_plan, implementation)


if __name__ == "__main__":
    task = sys.argv[1] if len(sys.argv) > 1 else "Add rate limiting middleware to the Express API"
    run_pipeline(task)