import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle{
    id: vmenu
    color: "#016b6b"

    RectangularGlow {
        anchors.fill: parent
        visible: parent.visible & !popup.visible
        glowRadius: 6
        spread: 0.2
        color: parent.color
        opacity: 0.6
        cornerRadius: parent.radius + glowRadius
    }

    Item{
        id: variablesTitle
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: window.mobile ? 25 : 35

        z: 10

        Text{
            text: "Global Variables"
            color:"white"
            font.pointSize: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin:12
        }

        Button {
            id: newVariableButton

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
            height: 20
            width: 20

            background: Rectangle{
                anchors.fill:parent
                color: newVariableButton.pressed? Qt.darker(dark_3,1.3) : dark_3
                radius: 2
            }

            contentItem: Image{
                anchors.fill: parent
                anchors.margins: 3
                source: "qrc:/icons/light/plus.png"
            }

            scale: hovered? 0.9: 1

            onClicked: { }
        }
    }

    MouseArea{
        anchors.top: variablesTitle.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        ListView{
            id: variableView
            anchors.fill: parent
            anchors.leftMargin: 10
            orientation: ListView.Vertical
            clip:true
            model: variableList
            delegate: Item{
                GridLayout{
                    columns:2
                    TextInputItem{text: name;  width: 100; readOnly: readonly}
                    TextInputItem{text: value; width: 100}
                }
            }
        }
    }
}
