import QtQuick

Item {
    id:deleteButton
    property alias color: deleteRect.color

    function clicked(){
        parent.clicked();
    }

    Rectangle{
        id: deleteRect

        anchors.fill: parent

        radius: 3

        Image{
            id: deleteIcon
            source: "qrc:/icons/delete_white.png"
            anchors.fill: parent
            anchors.margins:3
        }

        MouseArea{
            id: deleteMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: deleteButton.clicked()
            states: [
                State{
                    when: deleteMouseArea.pressed
                    PropertyChanges{
                        target: deleteRect
                        scale: 0.9
                    }
                },
                State{
                    when: deleteMouseArea.containsMouse
                    PropertyChanges{
                        target: deleteRect
                        color:"red"
                        scale: 0.9
                    }
                }
            ]
        }
    } // Delete button
}
