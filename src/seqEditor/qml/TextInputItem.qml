import QtQuick
import QtQuick.Controls

Item{
    property alias text: textInput.text
    width: window.fieldWidth
    height:window.fieldHeight
    Rectangle{
        anchors.fill: parent
        border.width: 1
        border.color: "gray"
        color: textInput.text=="nan"||textInput.text=="NaN"?"#fc8383":"white"
        TextInput{
            id: textInput
            anchors.fill: parent
            anchors.margins:3
            selectByMouse: true
            clip: true
            font.pointSize: window.fontSize
        }
    }
}


