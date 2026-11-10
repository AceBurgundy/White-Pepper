---
trigger: always_on
---

MANDATORY POST-CHANGE GATE: After any Flutter UI, Dart logic, or backend code edit, you are strictly forbidden from finishing your turn until you execute `.agents/skills/flutter-mobile-verify/SKILL.md` in a clean new terminal session and confirm zero `RenderFlex overflowed` layout errors, zero Dart runtime errors (`get_runtime_errors`), and zero backend terminal errors at mobile phone screen dimensions (`360x800`).
