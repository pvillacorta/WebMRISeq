import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    property int blockID
    property color menuColor
    property string menuTitle   

    property bool menuVisible: false

    property bool linesVisible
    property bool durationVisible
    property bool fovVisible
    property bool rfVisible
    property bool gradientsVisible
    property bool tVisible
    property bool repetitionsVisible

    property alias b1Mod: b1ModInput.text

    property alias duration: durationInput.text
    property alias delta_f: deltafInput.text
    property alias alpha: alphaInput.text
    property alias te: teInput.text
    property alias tr: trInput.text

    property alias gx: xAmplitudeInput.text
    property alias gy: yAmplitudeInput.text
    property alias gz: zAmplitudeInput.text
    property alias gxStep: xStepInput.text
    property alias gyStep: yStepInput.text
    property alias gzStep: zStepInput.text

    property alias fov: fovInput.text
    property alias n: nInput.text
    property alias reps: repsInput.text
    property alias shape: shapeInput.currentIndex



    Rectangle{
        id: rectConfig
        visible: menuVisible
        anchors.fill: parent

        color: menuColor

        Text{
            id: configText
            text: menuTitle + " (" + blockID + ")"
            anchors.horizontalCenter: parent.horizontalCenter
            y:10
            font.pointSize: 12
        }

        Component{
            id: configPanel
            Rectangle {
                z: -100
                implicitWidth: column.width
                // border.color: "gray"
                color: Qt.lighter(menuColor,1.3)
            }
        }

        Column {
            id: column
            anchors.top: configText.bottom
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 5
            spacing: 5

            Loader { id: lines
                visible:linesVisible
                sourceComponent: configPanel
                width:246
                height: 26
                GridLayout{ id: nLayout
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "Lines:";                 bold: true}
                    TextInputItem{ id: linesInput;              Layout.alignment: Qt.AlignRight }
                    MenuLabel { text: "lines";                  Layout.columnSpan: 2            }

                    MenuLabel { text: "Samples per line:";      bold: true}
                    TextInputItem{ id: samplesPerLineInput;     Layout.alignment: Qt.AlignRight }
                    MenuLabel { text: "lines";                  Layout.columnSpan: 2            }
                }
            }

            Loader { id: duration
                visible:durationVisible
                sourceComponent: configPanel
                width:150
                height: 26
                GridLayout{ id: durationLayout
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "Duration:";              bold: true}
                    TextInputItem{ id:durationInput;                 Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s"}
                }
            }

            Loader { id: fov
                visible:fovVisible
                sourceComponent: configPanel
                width:155
                height: 26
                GridLayout{ id: fovLayout
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "FOV:";                   bold: true}
                    TextInputItem{ id:fovInput;                 Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "m"}
                }
            }

            Loader { id: rf
                visible:rfVisible
                sourceComponent: configPanel
                height: 72
                GridLayout{ id: rfLayout
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 5
                    rowSpacing: 3

                    MenuLabel { text: "RF:";                    bold: true}
                    MenuLabel { text: "RF Shape:";              Layout.alignment: Qt.AlignRight}
                    ComboBox {  id:shapeInput
                        model: ["Rectangle (hard)", "Sinc"]
                        font.pointSize: window.fontSize;
                        delegate: ItemDelegate {
                            width: shapeInput.width
                            height: shapeInput.height
                            Item{
                                anchors.fill:parent
                                anchors.leftMargin: 5
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 50
                                    text: modelData
                                    color: "#292929"
                                    font: shapeInput.font
                                    elide: Text.ElideRight
                                }
                            }
                            highlighted: shapeInput.highlightedIndex === index
                        }
                        indicator: Canvas {
                            id: canvas
                            x: shapeInput.width - width - shapeInput.rightPadding
                            y: shapeInput.topPadding + (shapeInput.availableHeight - height) / 2
                            width: 12
                            height: 8
                            contextType: "2d"

                            Connections {
                                target: shapeInput
                                function onPressedChanged() { canvas.requestPaint(); }
                            }
                            onPaint: {
                                context.reset();
                                context.moveTo(0, 0);
                                context.lineTo(width, 0);
                                context.lineTo(width / 2, height);
                                context.closePath();
                                context.fillStyle = shapeInput.pressed ? "black" : "#292929";
                                context.fill();
                            }
                        }
                        contentItem: Text {
                            leftPadding: 5
                            rightPadding: shapeInput.indicator.width + shapeInput.spacing

                            text: shapeInput.displayText
                            font: shapeInput.font
                            color: shapeInput.pressed ? "black" : "#292929"
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            implicitWidth: 120
                            implicitHeight: window.fieldHeight
                            border.color: shapeInput.pressed ? "black" : "#595959"
                            border.width: shapeInput.visualFocus ? 2 : 1
                            radius: 2
                        }
                        popup: Popup {
                            y: shapeInput.height - 1
                            width: shapeInput.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 1

                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: shapeInput.popup.visible ? shapeInput.delegateModel : null
                                currentIndex: shapeInput.highlightedIndex
                            }
                            background: Rectangle {
                                border.color: "#292929"
                                radius: 2
                            }
                        }
                    }

                    MenuLabel { text: "Peak |B1|[T]:";          Layout.alignment: Qt.AlignRight}
                    TextInputItem{ id:b1ModInput}

                    MenuLabel { text: "Flip Angle [º]:";        Layout.alignment: Qt.AlignRight;        Layout.columnSpan: 2}
                    TextInputItem{ id:flipAngleInput;           Layout.columnSpan: 3}

                    MenuLabel { text: "Δf [Hz]:";               Layout.alignment: Qt.AlignRight;        Layout.columnSpan: 2}
                    TextInputItem{ id:deltafInput}
                }
            }

            Loader { id: gradients
                visible:gradientsVisible
                sourceComponent: configPanel
                height: 90

                GridLayout{ id: gradientsLayout
                    columns: 6
                    anchors.fill: parent
                    anchors.margins:3
                    anchors.rightMargin:10
                    rowSpacing: 1

                    MenuLabel { text: "Gradients:";             bold: true}
                    MenuLabel { text: "InitialDelay [s]";       Layout.alignment: Qt.AlignCenter}
                    MenuLabel { text: "Rise/Fall [s]";          Layout.alignment: Qt.AlignCenter}
                    MenuLabel { text: "FlatTopTime [s]";        Layout.alignment: Qt.AlignCenter}
                    MenuLabel { text: "Amplitude [T/m]";        Layout.alignment: Qt.AlignCenter}
                    MenuLabel { text: "Step [T/m]";             Layout.alignment: Qt.AlignCenter}

                    MenuLabel { text: "Gx:";                    Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gxDelayInput;             Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gxRiseInput;              Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gxFlatTopInput;           Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gxAmplitudeInput;         Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gxStepInput;              Layout.alignment: Qt.AlignCenter}

                    MenuLabel { text: "Gy:";                    Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gyDelayInput;             Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gyRiseInput;              Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gyFlatTopInput;           Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gyAmplitudeInput;         Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gyStepInput;              Layout.alignment: Qt.AlignCenter}

                    MenuLabel { text: "Gz:";                    Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gzDelayInput;             Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gzRiseInput;              Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gzFlatTopInput;           Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gzAmplitudeInput;         Layout.alignment: Qt.AlignCenter}
                    TextInputItem{ id:gzStepInput;              Layout.alignment: Qt.AlignCenter}

                }
            }

            Loader { id: t
                visible:tVisible
                sourceComponent: configPanel
                height: 50
                width: 150
                GridLayout{ id:tLayout
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 3
                    rowSpacing: 1
                    MenuLabel { text: "TE:";                    bold: true}
                    TextInputItem{ id:teInput;                  Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s"}
                    MenuLabel { text: "TR:";                    bold: true}
                    TextInputItem{ id:trInput;                  Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s"}
                }
            }

            Loader { id: flipAngle
                visible:flipAngleVisible
                sourceComponent: configPanel
                width:150
                height: 26
                GridLayout{ id: flipAngleLayout
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "Flip Angle (α):";              bold: true}
                    TextInputItem{ id:flipAngleInput;                 Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s"}
                }
            }

            Loader { id: repetitions
                visible:repetitionsVisible
                sourceComponent: configPanel
                width: 200
                height: 26
                GridLayout{ id: repsLayout
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "Repetitions:";              bold: true}
                    TextInputItem{ id:repsInput;                   Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "times"}
                }
            }
        }




            // GridLayout{
            //     id: configLayout
            //     visible:false
            //     columns: 6
            //     width:parent.width
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     rowSpacing: 3

            //     MenuLabel { text: "Duration [s]:";          visible: durationVisible}
            //     TextInputItem{ id:durationInput;            visible: durationVisible;               Layout.columnSpan: rfVisible ? 2 : 5}

            //     MenuLabel { text: "α (flip angle) [º]:";    visible: alphaVisible}
            //     TextInputItem{ id:alphaInput;               visible: alphaVisible;                  Layout.columnSpan: 5}
            // }



        // APPLY CHANGES
        Button{
            id: applyButton
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 10
            anchors.bottomMargin: 10
            height: 25
            width: 100
            text:"Apply changes"
            font.pointSize: window.fontSize
            onClicked:{
                blockList.set(configMenu.blockID,{  "dur":durationVisible ? Number(durationInput.text) : Number(alphaInput.text),
                                                    "b1x":rfVisible ? Number(b1ModInput.text) : Number(teInput.text),
                                                    "b1y":rfVisible ? Number(b1yInput.text) : Number(trInput.text),
                                                    "gx":Number(gxInput.text),
                                                    "gy":Number(gyInput.text),
                                                    "gz":Number(gzInput.text),
                                                    "gxStep":Number(gxStepInput.text),
                                                    "gyStep":Number(gyStepInput.text),
                                                    "gzStep":Number(gzStepInput.text),
                                                    "delta_f":Number(deltafInput.text),
                                                    "fov":Number(fovInput.text),
                                                    "n":nVisible ? Number(nInput.text) : shapeInput.currentIndex,
                                                    "reps":Number(repsInput.text)});
                var blockinfo = blockList.get(blockID)
                duration = durationVisible? blockinfo.dur : 0;
                alpha = durationVisible? 0 : blockinfo.dur;
                b1x = rfVisible ? blockinfo.b1x : 0;
                b1y = rfVisible ? blockinfo.b1y : 0;
                shape = nVisible ? 0 : blockinfo.n;
                n = nVisible ? blockinfo.n : 0;
                te = rfVisible ? 0 : blockinfo.b1x;
                tr = rfVisible ? 0 : blockinfo.b1y;
                gx = blockinfo.gx;
                gy = blockinfo.gy;
                gz = blockinfo.gz;
                gxStep = blockinfo.gxStep;
                gyStep = blockinfo.gyStep;
                gzStep = blockinfo.gzStep;
                delta_f = blockinfo.delta_f;
                fov = blockinfo.fov;
                reps = blockinfo.reps;
            }
        }

        // VIEW 3D MODEL OF SELECTED SLICE
        Button{
            id: plotButton
            visible: plotVisible
            anchors.right: applyButton.left
            anchors.bottom: parent.bottom
            anchors.margins: 10
            height: applyButton.height
            width: applyButton.width
            text: "View 3D Model"
            font.pointSize: window.fontSize
            onClicked:{
                if (phantomInput.text !== ''){
                    // C++ slot call:
                    backend.plot3D(Number(gxInput.text),Number(gyInput.text),Number(gzInput.text),Number(deltafInput.text));
                } else {
                    console.log("Please, select a phantom");
                }
            }
        }

        // MAKE GROUP duplicatable (THIS ADDS A BUTTON TO THE "ADD BLOCK" MENU)
        Button{
            id: duplicateButton
            visible: groupVisible
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 10
            height: applyButton.height
            width: 200
            text: "Make group duplicatable"

            onClicked:{
                for(var i=0; i<buttonList.count; i++){
                    if(buttonList.get(i).buttonText === menuTitle){
                        console.log("This block is already duplicatable");
                        return;
                    }
                }
                buttonList.append({"buttonText": menuTitle, "code": buttonList.count+1});

                var group_cod;
                var num_groups = blockList.get(blockID).ngroups;
                var count = groupList.count;
                var childrenList;

                for(var j=0; j<=countChildren(blockID); j++){
                    childrenList = [];

                    if(j==0){
                        group_cod = buttonList.count;
                    } else {
                        group_cod = -1;
                    }

                    if(isGroup(blockID+j)){
                        var num = blockList.get(blockID+j).children.count;
                        for(var i=0;i<num;i++){
                            childrenList.push( blockList.get(blockID+j).children.get(i).number + (count-blockID) );
                        }
                    }

                    groupList.append(  {"group_cod":group_cod,
                                        "cod":blockList.get(blockID+j).cod,
                                        "dur":blockList.get(blockID+j).dur,
                                        "gx":blockList.get(blockID+j).gx,
                                        "gy":blockList.get(blockID+j).gy,
                                        "gz":blockList.get(blockID+j).gz,
                                        "gxStep":blockList.get(blockID+j).gxStep,
                                        "gyStep":blockList.get(blockID+j).gyStep,
                                        "gzStep":blockList.get(blockID+j).gzStep,
                                        "b1x":blockList.get(blockID+j).b1x,
                                        "b1y":blockList.get(blockID+j).b1y,
                                        "delta_f":blockList.get(blockID+j).delta_f,
                                        "fov":blockList.get(blockID+j).fov,
                                        "n":blockList.get(blockID+j).n,
                                        "ngroups":blockList.get(blockID+j).ngroups - num_groups,
                                        "name":blockList.get(blockID+j).name,
                                        "children":[],
                                        "reps":blockList.get(blockID+j).reps});

                    for(i=0;i<childrenList.length;i++){
                        groupList.get(groupList.count-1).children.append({"number":childrenList[i]})
                    }
                }
            }
        }
    } // Rectangle

    states: [
        State{
            when: !configMenu.menuVisible
            PropertyChanges {
                target: rectConfig
                scale: 0
            }
        },
        State{
            when: configMenu.menuVisible
            PropertyChanges {
                target: rectConfig
                scale: 1
            }
        }
    ] // states

    transitions:
        Transition{
                 PropertyAnimation {property: "scale"; duration: 75}
        }

} // Item
