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


    Rectangle {
        id: canvas
        color: "transparent"
        anchors.fill: parent
    //Rectangle drawn by user
        Rectangle{
            id:selectionRect
            visible: false
            color: "transparent"
            border.color: "green"
            border.width: 2

        }
        MouseArea{
            anchors.fill: parent
            property real startX:0
            property real startY:0

            onPressed: function(event){
                //Rectangle start position
                startX = event.x;
                startY = event.y;
                selectionRect.x = startX;
                selectionRect.y=startY;
                selectionRect.width =0;
                selectionRect.height =0;
                selectionRect.visible = true;
            }
            onPositionChanged:function(event) {
                   selectionRect.x = Math.min(event.x, startX); // returns smaller number as an x
                   selectionRect.y = Math.min(event.y, startY);// returns smaller number as an y

                   // Obliczenie szerokości i wysokości prostokąta
                   selectionRect.width = Math.abs(event.x - startX);
                   selectionRect.height = Math.abs(event.y - startY);
            }
            onReleased:function(event) {
                //Log last state of rectangle
                console.log("Final rectangle: x=" + selectionRect.x +
                                            ", y=" + selectionRect.y +
                                            ", width=" + selectionRect.width +
                                            ", height=" + selectionRect.height);
            }
        }
    }
}
