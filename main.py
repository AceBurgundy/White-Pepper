"""
Primary PyQt6 interactive desktop application entry point for white-pepper.
"""

from __future__ import annotations

# DPI = Dots Per Inch
# GUI = Graphical User Interface
# UI = User Interface

from pathlib import Path
import sys

from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QApplication

# Ensure scripts folder is accessible to imports
SCRIPTS_DIRECTORY: Path = Path(__file__).resolve().parent / "scripts"
if str(SCRIPTS_DIRECTORY) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIRECTORY))

from ui.main_window import MainWindow


def main() -> None:
    """
    Launch the white-pepper PyQt6 graphical desktop application.

    Parameters
    ----------
    None

    Returns
    -------
    None
    """
    # High-DPI scaling configuration
    if hasattr(Qt.ApplicationAttribute, "AA_EnableHighDpiScaling"):
        QApplication.setAttribute(Qt.ApplicationAttribute.AA_EnableHighDpiScaling, True)
    if hasattr(Qt.ApplicationAttribute, "AA_UseHighDpiPixmaps"):
        QApplication.setAttribute(Qt.ApplicationAttribute.AA_UseHighDpiPixmaps, True)

    application: QApplication = QApplication(sys.argv)
    application.setApplicationName("white-pepper")
    application.setApplicationVersion("1.1.1")
    application.setOrganizationName("AceBurgundy")

    main_window: MainWindow = MainWindow()
    main_window.show()

    sys.exit(application.exec())


if __name__ == "__main__":
    main()
