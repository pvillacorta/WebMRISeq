import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle{
    id: variablesMenu
    color: "#016b6b"
    property int menuID: -2

    function applyVariablesChanges(){
        var idx = getViewIndexes() 
        for (var i = 0; i < idx.length; i++){
            var delegateItem = variablesView.contentItem.children[idx[i]];
            if (delegateItem) {
                variablesList.setProperty(i, "name",       delegateItem.children[0].text)
                variablesList.setProperty(i, "expression", delegateItem.children[1].text)
                variablesList.setProperty(i, "value",      evalExpression(delegateItem.children[1].text))
            }
            else{
                console.log("No se encontró el item " + i);
            }
        }
    }

    function getViewIndexes(){ // This is not the best practice, but it works
        var indexes = []
        for (var i = 0; i < variablesList.count; i++){
            var j = i == 0 ? i : i + 1 
            indexes.push(j)
        }
        return indexes
    }

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
            id: variablesTitleText
            text: "Global Variables"
            color:"white"
            font.pointSize: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin:12
        }

        Button {
            id: newVariableButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: variablesTitleText.right; anchors.leftMargin: 10
            height: 18
            width:  18

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

            onClicked: { 
                variablesList.append({"name":"", "expression":"", "value":0, "readonly":false})
            }
        }

        Text{
            id: variablesFieldNames
            text: " Name                Expression          Value"
            anchors.top: variablesTitleText.bottom; anchors.topMargin: 5
            color:"white"
            font.pointSize: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin:12
        }
    }

    Item{
        id: variablesArea
        anchors.fill: parent
        anchors.bottomMargin:10
        anchors.topMargin: 45
        anchors.leftMargin: 15
        anchors.rightMargin: 15

        ListView{
            id: variablesView
            anchors.fill: parent
            orientation: ListView.Vertical
            clip: true
            model: variablesList
            boundsBehavior: Flickable.StopAtBounds 
            
            ScrollBar.vertical: ScrollBar{
                id: varScrollBar
                active: true
                orientation: Qt.Vertical
                policy: ScrollBar.AlwaysOn
            }

            delegate: GridLayout{ 
                height: 25
                columns:4
                columnSpacing: 5
                TextInputItem{
                    id: nameInput;  
                    idNumber: menuID; 
                    text: name; 
                    width: 100; 
                    readOnly: readonly
                    function nextInput(){
                        return expressionInput.textInput
                    }
                }
                TextInputItem{
                    id: expressionInput;  
                    idNumber: menuID; 
                    text: expression; 
                    width: 100; 
                    function nextInput(){
                        var idx = getViewIndexes()
                        if (index < idx.length - 1) {
                            return variablesView.contentItem.children[idx[index + 1]].children[0].textInput
                        }
                        return null; 
                    }
                }
                TextInputItem{
                    id: valueInput; 
                    idNumber: menuID; 
                    text: value; 
                    width: 100; 
                    readOnly: true
                    function nextInput(){
                        var idx = getViewIndexes()
                        if (index < idx.length - 1) {
                            return variablesView.contentItem.children[idx[index + 1]].children[0].textInput
                        }
                        return null; 
                    }
                }
                DeleteButton{
                    visible: !readonly
                    function clicked(){
                        variablesList.remove(index)
                    }
                    height: 15
                    width: height
                }
            } 
        }
    }
}
