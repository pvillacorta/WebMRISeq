import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle{
    id: menu
    color: "#334C66"

    property alias b0: b0Input.text
    property alias b1: b1Input.text
    property alias delta_t: deltatInput.text
    property alias gmax : gmaxInput.text
    property alias smax : smaxInput.text

    property string fontColor: "white"

    Text{
        text: "Scanner Parameters"
        anchors.horizontalCenter: parent.horizontalCenter
        y:5
        font.pointSize: 12
        color: fontColor
    }

    GridLayout{
        x: 20
        y: 31
        columns:3
        rowSpacing: 3
        columnSpacing: 5

        MenuLabel { text: "Main magnetic field B0:";    fontColor: menu.fontColor}
        TextInputItem{ id:b0Input }
        MenuLabel { text: "T";                          fontColor: menu.fontColor }

        MenuLabel { text: "Max RF amplitude B1:";       fontColor: menu.fontColor }
        TextInputItem{ id:b1Input }
        MenuLabel { text: "T";                          fontColor: menu.fontColor }

        MenuLabel { text: "Min Sampling period Δt:";    fontColor: menu.fontColor }
        TextInputItem{ id:deltatInput }
        MenuLabel { text: "s";                          fontColor: menu.fontColor }

        MenuLabel { text: "Max Gradient Gmax:";         fontColor: menu.fontColor }
        TextInputItem{ id:gmaxInput }
        MenuLabel { text: "T/m";                        fontColor: menu.fontColor }

        MenuLabel { text: "Max Slew-Rate:";             fontColor: menu.fontColor }
        TextInputItem{ id:smaxInput }
        MenuLabel { text: "T/m/s";                      fontColor: menu.fontColor }
    }

}
