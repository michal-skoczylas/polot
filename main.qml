import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint
    color: "transparent"
    title: qsTr("Hello World")

    // Variables for offsetting rectangle
    property bool dragging: false
    property real offsetX : 0
    property real offsetY: 0
    property real startX: 0
    property real startY: 0

    Rectangle {
        id: canvas
        color: "transparent"
        anchors.fill: parent

        // Rectangle drawn by user
        Rectangle {
            id: selectionRect
            visible: false
            color: "transparent"
            border.color: "green"
            border.width: 2
        }

        MouseArea {
            id: selectionArea
            anchors.fill: parent
            cursorShape: Qt.CrossCursor

            onPressed: function(event) {
                // Check if the click is inside the rectangle
                if (event.x >= selectionRect.x && event.x <= selectionRect.x + selectionRect.width &&
                    event.y >= selectionRect.y && event.y <= selectionRect.y + selectionRect.height) {
                    // Start dragging: store the offset between the mouse position and the rectangle's position
                    dragging = true;
                    offsetX = event.x - selectionRect.x;
                    offsetY = event.y - selectionRect.y;
                } else {
                    // If the click is outside the rectangle, start drawing a new one
                    dragging = false;
                    startX = event.x;
                    startY = event.y;
                    selectionRect.x = startX;
                    selectionRect.y = startY;
                    selectionRect.width = 0;
                    selectionRect.height = 0;
                    selectionRect.visible = true;
                }
            }

            onPositionChanged: function(event) {
                if (dragging) {
                    // If dragging, move the rectangle according to the mouse position
                    selectionRect.x = event.x - offsetX;
                    selectionRect.y = event.y - offsetY;
                } else {
                    // Otherwise, resize the rectangle (drawing mode)
                    selectionRect.x = Math.min(event.x, startX); // returns smaller number as an x
                    selectionRect.y = Math.min(event.y, startY); // returns smaller number as an y

                    // Calculate the width and height of the rectangle
                    selectionRect.width = Math.abs(event.x - startX);
                    selectionRect.height = Math.abs(event.y - startY);
                }
            }

            onReleased: function(event) {
                // Log the final state of the rectangle when released
                console.log("Final rectangle: x=" + selectionRect.x +
                    ", y=" + selectionRect.y +
                    ", width=" + selectionRect.width +
                    ", height=" + selectionRect.height);
            }
        }
        Rectangle{
            y: 422
            width: 80
            height: 50
            color: "gray"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            Text{
                anchors.centerIn: parent
                text: "Snap"
                font.pixelSize: 20
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    // calling function to take screenshot
                    screenshotHandler.takeScreenshot(selectionRect.x,selectionRect.y,selectionRect.width,selectionRect.height)
                }
            }
        }
    }
}
