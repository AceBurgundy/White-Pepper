# Contributing to white-pepper

Thank you for contributing to **white-pepper**. This repository maintains rigorous engineering standards. All contributors, agents, and maintainers must strictly follow the conventions outlined below.

---

## 1. Code Conventions Reference
All Python source code must comply in full with:
`D:\Conversations\conventions\python-conventions.md`

### Universal Type Annotations
- **Universal Annotation**: Every variable assignment, function argument, return value, class attribute, and dictionary must have an explicit type hint down to the most specific type.
- **Python 3.10+ Generic Forms**: Use built-in generic forms (`list[str]`, `dict[str, Any]`, `tuple[int, int]`, `Optional[Path]`). Always import annotations:
  ```python
  from __future__ import annotations
  ```
- **Class Initializers**: `__init__` methods must always be annotated with `-> None`.
- **No Loose Types**: Avoid untyped variables. If dynamic COM typing requires `Any`, provide an inline explanatory comment.

### Docstring Standards (NumPy / Sphinx)
Every module, class, public/private method, and function must have a docstring formatted as:
```python
def configure_device(device_name: str, resolution_dpi: int) -> bool:
    """
    Configure scanner device optical parameters.

    Parameters
    ----------
    device_name : str
        The unique hardware identifier of the scanner.
    resolution_dpi : int
        The target resolution in dots per inch.

    Returns
    -------
    bool
        True if configuration succeeded, False otherwise.

    Raises
    ------
    ConnectionError
        If the target scanner device is unreachable.
    """
```

### Naming & Formatting
- **Descriptive Names**: Uninformative abbreviations (`i`, `tmp`, `dir`, `cfg`, `resp`, `h`, `w`) are strictly prohibited. Use `index`, `temporary_path`, `directory_path`, `configuration`, `response`, `height`, `width`.
- **No Hanging Assignments**: Statements must never end with `=`.
- **No Decorative Banners**: Section comments such as `# ===== Helpers =====` are forbidden.
- **Preservation of Safeguards**: Never remove null checks, error handling, try/except blocks, logging, assertions, or safety guards.

---

## 2. Git & Commit Guidelines
- The repository timeline is managed using the `/git-revisit` skill (`D:/conversations/skills/git-revisit/SKILL.md`).
- Authorship is standardly configured for `AceBurgundy <Samadriansabalo99@gmail.com>`.
- Commit history is constructed via AST decomposition to preserve chronological engineering authenticity.

---

## 3. Pull Request & Verification Process
Before submitting changes:
1. Run syntax verification:
   ```powershell
   python -m py_compile scan_cli.py process_cli.py diagnostics_cli.py white_pepper/*.py
   ```
2. Verify CLI commands with `--help`:
   ```powershell
   python scan_cli.py --help
   python process_cli.py --help
   python diagnostics_cli.py --help
   ```
3. Test against live hardware or buffer test fixtures in `D:\Conversations\scanner`.
