import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    flags: Qt.FramelessWindowHint
    color: "transparent"
    title: qsTr("Polot App")

    property bool dragging: false
    property real offsetX : 0
    property real offsetY: 0
    property real startX: 0
    property real startY: 0

    Component.onCompleted: {
        var screen = Screen.active;
        if (screen) {
            x = screen.geometry.x + (screen.geometry.width - width) / 2;
            y = screen.geometry.y + (screen.geometry.height - height) / 2;
        }
    }

    Rectangle {
        id: canvas
        color: "transparent"
        anchors.fill: parent

        Rectangle {
            id: selectionRect
            visible: false
            color: "transparent"
            border.color: "green"
            border.width: 2
            focus: true

            Keys.onPressed: function(event) {
                if (event.key == Qt.Key_Escape) {
                    Qt.quit();
                }
            }
        }

        MouseArea {
            id: selectionArea
            anchors.fill: parent

            onPressed: function(event) {
                if (event.x >= selectionRect.x && event.x <= selectionRect.x + selectionRect.width &&
                    event.y >= selectionRect.y && event.y <= selectionRect.y + selectionRect.height) {
                    dragging = true;
                    offsetX = event.x - selectionRect.x;
                    offsetY = event.y - selectionRect.y;
                } else {
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
                    selectionRect.x = event.x - offsetX;
                    selectionRect.y = event.y - offsetY;
                } else {
                    selectionRect.x = Math.min(event.x, startX);
                    selectionRect.y = Math.min(event.y, startY);
                    selectionRect.width = Math.abs(event.x - startX);
                    selectionRect.height = Math.abs(event.y - startY);
                }
            }

            onReleased: function(event) {
                console.log("Final rectangle: x=" + selectionRect.x +
                    ", y=" + selectionRect.y +
                    ", width=" + selectionRect.width +
                    ", height=" + selectionRect.height);
            }
        }

        Rectangle {
            y: 422
            width: 80
            height: 50
            color: "gray"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                anchors.centerIn: parent
                text: "Snap"
                font.pixelSize: 20
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    screenshotHandler.takeScreenshot(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
                }
            }
        }
    }
}
