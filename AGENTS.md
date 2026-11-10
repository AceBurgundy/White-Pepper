# AGENTS.md — White Pepper Flutter Desktop & Headless Scanner Suite

## 1. Mandatory Post-Change Verification Gate
- **MANDATORY POST-CHANGE GATE**: After any Flutter UI, Dart logic, or backend code edit, you are strictly forbidden from finishing your turn until you execute `.agents/skills/flutter-mobile-verify/SKILL.md` in a clean new terminal session and confirm zero `RenderFlex overflowed` layout errors, zero Dart runtime errors (`get_runtime_errors`), and zero backend terminal errors at mobile phone screen dimensions (`360x800`).

## 2. Git Management & Commit Protocol
- Production repository `white_pepper` and standalone submodule `scripts` must always remain Git-monitored.
- Commits and repository history generation must use the `/git-revisit` skill (`D:/conversations/skills/git-revisit/SKILL.md`) using AST decomposition with author `AceBurgundy <Samadriansabalo99@gmail.com>`.
