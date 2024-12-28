import sys
import os
from pathlib import Path
from datetime import datetime
import glob
import cv2 as cv
import pytesseract
from PIL import Image
from PySide6.QtGui import QGuiApplication, QImage, QClipboard
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import Qt, QRect, QObject, Slot, QUrl
from PySide6.QtQuick import QQuickWindow


class ScreenshotHandler(QObject):
    def __init__(self, window):
        super().__init__()
        self.window = window

    @Slot(float, float, float, float)
    def takeScreenshot(self, x, y, width, height):
        try:
            # Get all screens and choose the primary one (or you could select another)
            screens = QGuiApplication.screens()
            screen = screens[0]  # Choose the first screen, or use a different index if needed

            # Ensure screen exists
            if not screen:
                print("No primary screen available")
                return

            # Get the geometry of the window
            window_rect = self.window.geometry()

            # Adjust coordinates to global screen space
            rect = QRect(
                window_rect.x() + int(x),  # Global X
                window_rect.y() + int(y),  # Global Y
                int(width),               # Width
                int(height)               # Height
            )

            # Capture the screenshot
            screenshot = screen.grabWindow(0, rect.x(), rect.y(), rect.width(), rect.height())

            # Define save path
            screenshots_folder = os.path.expanduser("~/Pictures/Screenshots/polot")
            os.makedirs(screenshots_folder, exist_ok=True)
            timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
            save_path = os.path.join(screenshots_folder, f"screenshot_{timestamp}.png")

            # Save the screenshot
            if screenshot.save(save_path, "PNG"):
                print(f"Screenshot saved to {save_path}")
            else:
                print("Failed to save screenshot")

        except Exception as e:
            print(f"Error while taking screenshot: {e}")


    @Slot()
    def processImage(self):
        # Define folder path
            screenshots_folder = os.path.expanduser("~/Pictures/Screenshots/polot")
            list_of_files = glob.glob(os.path.join(screenshots_folder, '*.png'))

            if not list_of_files:
                print("Missing screenshot files in directory")
                return

            try:
                # Find the latest screenshot
                latest_img = max(list_of_files, key=os.path.getctime)

                # Image processing
                img = cv.imread(latest_img)
                img = cv.cvtColor(img, cv.COLOR_BGR2RGB)

                # Reading text from image
                text = pytesseract.image_to_string(img)

                # Pasting text to clipboard
                clipboard = QGuiApplication.clipboard()
                clipboard.setText(text)
                print("Text successfully copied to clipboard.")
            except cv.error as e:
                print(f"OpenCV error: {e}")
            except Exception as e:
                print(f"An error occurred: {e}")






if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    # Print active Python environment
    print("Active Python environment:", sys.executable)

    # Get the primary screen
    screen = QGuiApplication.primaryScreen()
    screen_geometry = screen.geometry()

    # Create the main application window
    window = QQuickWindow()
    window.setGeometry(screen_geometry)

    # Set up the ScreenshotHandler
    screenshot_handler = ScreenshotHandler(window)

    # Load the QML file
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("screenshotHandler", screenshot_handler)

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        sys.exit(-1)

    # Run the application
    sys.exit(app.exec())
