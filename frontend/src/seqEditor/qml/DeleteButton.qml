import QtQuick

Item {
    id:deleteButton
    property alias color: deleteRect.color

    function clicked(){
        parent.clicked();
    }

    Image{
        id: deleteIcon
        source: "qrc:/icons/delete_white.png"
        anchors.fill: deleteRect
        anchors.margins:3
        z: 10
    }

    Rectangle{
        id: deleteRect
        color: "black"
        opacity: 0.3
        anchors.fill: parent
        z: 5

        radius: 3

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
                        opacity: 1.0
                    }
                    PropertyChanges{
                        target: deleteIcon
                        scale: 0.9
                    }
                }
            ]
        }
    } // Delete button
}
