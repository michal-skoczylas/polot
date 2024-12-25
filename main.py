import sys
from pathlib import Path
import os
from PySide6.QtGui import QGuiApplication, QImage, QPainter
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import Qt, QRect, QUrl, QObject, Slot
from datetime import datetime
from PySide6.QtQuick import QQuickWindow

class ScreenshotHandler(QObject):
    def __init__(self, window):
        super().__init__()
        self.window = window  # Store the window reference

    @Slot(float, float, float, float)
    def takeScreenshot(self, x, y, width, height):
        # Setting primary screen
        screen = QGuiApplication.primaryScreen()

        # Getting window screen rect area (geometry of the window)
        window_rect = self.window.geometry()

        # Defining area to capture based on the coordinates passed from QML
        rect = QRect(window_rect.left() + x, window_rect.top() + y, width, height)

        # Taking screenshot
        screenshot = screen.grabWindow(self.window.winId(), rect.left() + 2, rect.top() + 2, rect.width() - 4, rect.height() - 4)

        # Get the system's screenshots folder (usually ~/Pictures/Screenshots)
        screenshots_folder = os.path.expanduser("~/Pictures/Screenshots")

        # Create "polot" subfolder inside the screenshots folder if it doesn't exist
        polot_folder = os.path.join(screenshots_folder, "polot")
        if not os.path.exists(polot_folder):
            os.makedirs(polot_folder)

        # Set save path with timestamp inside the "polot" folder
        timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
        save_path = os.path.join(polot_folder, f"screenshot_{timestamp}.png")

        # Save the screenshot as a PNG
        screenshot.save(save_path, "PNG")
        print(f"Screenshot saved to {save_path}")


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)  # Initialize QGuiApplication before creating any QML-based windows

    # Get the active screen
    screen = QGuiApplication.primaryScreen()

    # Create the QQuickWindow instance
    window = QQuickWindow()

    # Set the window's position to the active screen's center
    screen_geometry = screen.geometry()
    window.setGeometry(screen_geometry)

    # Create ScreenshotHandler and pass the window to it
    screenshot_handler = ScreenshotHandler(window)

    engine = QQmlApplicationEngine()

    # Load the QML file
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        sys.exit(-1)

    # Set the context property so QML can access the ScreenshotHandler
    engine.rootContext().setContextProperty("screenshotHandler", screenshot_handler)

    sys.exit(app.exec())

