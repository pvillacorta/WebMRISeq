import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle{
    id: smenu
    color: "#334C66"
    property int menuID: -1

    // TODO: Change Scanner parameters to a ListModel
    property alias b0: b0Input.text
    property alias b1: b1Input.text
    property alias deltat: deltatInput.text
    property alias gmax : gmaxInput.text
    property alias smax : smaxInput.text

    property string fontColor: "white"

    RectangularGlow {
        anchors.fill: parent
        visible: parent.visible & !popup.visible
        glowRadius: 6
        spread: 0.2
        color: parent.color
        opacity: 0.6
        cornerRadius: parent.radius + glowRadius
    }

    Text{
        text: "Scanner Parameters"
        font.pointSize: 10
        anchors.top: parent.top;   anchors.topMargin: 12
        anchors.left: parent.left; anchors.leftMargin:12
        color: fontColor
    }

    GridLayout{
        x: 20
        y: 35
        columns:3
        rowSpacing: 3
        columnSpacing: 5

        MenuLabel { text: "Main magnetic field B0:";    fontColor: smenu.fontColor}
        TextInputItem{ id:b0Input; idNumber: menuID; function nextInput(){  return b1Input.textInput }}
        MenuLabel { text: "T";                          fontColor: smenu.fontColor }

        MenuLabel { text: "Max RF amplitude B1:";       fontColor: smenu.fontColor }
        TextInputItem{ id:b1Input; idNumber: menuID; function nextInput(){  return deltatInput.textInput } }
        MenuLabel { text: "T";                          fontColor: smenu.fontColor }

        MenuLabel { text: "Min Sampling period Δt:";    fontColor: smenu.fontColor }
        TextInputItem{ id:deltatInput; idNumber: menuID; function nextInput(){  return gmaxInput.textInput } }
        MenuLabel { text: "s";                          fontColor: smenu.fontColor }

        MenuLabel { text: "Max Gradient Gmax:";         fontColor: smenu.fontColor }
        TextInputItem{ id:gmaxInput; idNumber: menuID; function nextInput(){  return smaxInput.textInput } }
        MenuLabel { text: "T/m";                        fontColor: smenu.fontColor }

        MenuLabel { text: "Max Slew-Rate:";             fontColor: smenu.fontColor }
        TextInputItem{ id:smaxInput; idNumber: menuID; function nextInput(){  return smaxInput.textInput } }
        MenuLabel { text: "T/m/s";                      fontColor: smenu.fontColor }
    }

}
