import QtQuick
import QtQuick.Controls

Item {
    property alias text: label.text
    property alias bold: label.font.bold
    property alias fontColor: label.color
    height: window.fieldHeight
    width: label.contentWidth
    Label{
        id: label
        anchors.fill: parent
        font.pointSize: window.fontSize;
    }
}
