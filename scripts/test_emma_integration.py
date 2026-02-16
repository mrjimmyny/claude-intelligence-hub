from pathlib import Path


def main() -> None:
    print("Emma integration test - SUCCESS")

    repo_root = Path(__file__).resolve().parents[1]
    exists = repo_root.exists() and repo_root.name == "claude-intelligence-hub"
    print(f"claude-intelligence-hub directory exists: {exists}")

    skills_dir = Path.home() / ".claude" / "skills" / "user"
    if skills_dir.is_dir():
        skills = sorted([p.name for p in skills_dir.iterdir() if p.is_dir()])
        print("Skills in ~/.claude/skills/user/:")
        if skills:
            for skill in skills:
                print(f"- {skill}")
        else:
            print("(none)")
    else:
        print(f"Skills directory not found: {skills_dir}")


if __name__ == "__main__":
    main()
