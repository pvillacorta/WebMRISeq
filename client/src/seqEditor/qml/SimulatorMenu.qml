import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle{
    id: simulatorMenu
    color: "#492859"

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
        id: simulator
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: window.mobile ? 25 : 35

        z: 10

        Text{
            id: simulatorTitleText
            text: "Simulation Launcher"
            color:"white"
            font.pointSize: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin:12
        }
    }

    Row{
        id: simulatorRow
        x: 20
        y: 35
        spacing: 5
        MenuLabel { text: "Phantom:"; fontColor: "white"}
        ComboBoxItem{
            id: phantomInput;
            idNumber: -3;
            model: ["Brain 2D", "Brain 3D", "Pelvis 2D"];
        } 
    }

    Button{
        id : simulateButton
        text: "Simulate"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15
        height: 25

        onClicked: {
            simulate(phantomInput.currentText)
        }
    }
}
