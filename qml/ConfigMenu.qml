import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    property int blockID
    property color menuColor
    property string menuTitle   
    property bool menuVisible: false

    // ------- Duration
    property bool durationVisible
    property alias duration:    durationInput.text

    // ------- Lines
    property bool linesVisible
    property alias lines:       linesInput.text

    // ------- Samples
    property bool samplesVisible
    property alias samples:     samplesInput.text

    // ------- ADC Delay
    property bool adcDelayVisible
    property alias adcDelay:    adcDelayInput.text

    // ------- FOV
    property bool fovVisible
    property alias fov:         fovInput.text

    // ------- RF
    property bool rfVisible
    property alias select:      rfSelect.currentIndex
    property alias shape:       shapeInput.currentIndex
    property alias b1Module:    b1ModuleInput.text
    property alias flipAngle:   flipAngleInput.text
    property alias deltaf:      deltafInput.text

    // ------- Gradients
    property bool gradientsVisible
    property alias gxDelay:     gxDelayInput.text
    property alias gyDelay:     gyDelayInput.text
    property alias gzDelay:     gzDelayInput.text

    property alias gxRise:      gxRiseInput.text
    property alias gyRise:      gyRiseInput.text
    property alias gzRise:      gzRiseInput.text

    property alias gxFlatTop:   gxFlatTopInput.text
    property alias gyFlatTop:   gyFlatTopInput.text
    property alias gzFlatTop:   gzFlatTopInput.text

    property alias gxAmplitude: gxAmplitudeInput.text
    property alias gyAmplitude: gyAmplitudeInput.text
    property alias gzAmplitude: gzAmplitudeInput.text

    property alias gxStep:      gxStepInput.text
    property alias gyStep:      gyStepInput.text
    property alias gzStep:      gzStepInput.text

    // ------- Times
    property bool tVisible
    property alias te:          teInput.text
    property alias tr:          trInput.text

    // ------- Group
    property bool groupVisible
    property alias repetitions: repsInput.text

    function applyChanges(blockID){
        if(durationVisible) {blockList.setProperty(blockID,          "duration",     Number(duration));}
        if(linesVisible)    {blockList.setProperty(blockID,          "lines",        Number(lines));}
        if(samplesVisible)  {blockList.setProperty(blockID,          "samples",      Number(samples));
                             blockList.setProperty(blockID,          "adcDelay",     Number(adcDelay));}
        if(fovVisible)      {blockList.setProperty(blockID,          "fov",          Number(fov));}
        if(rfVisible)       {blockList.get(blockID).rf.set(0,       {"select":       Number(select),
                                                                     "shape":        Number(shape),
                                                                     "b1Module":     Number(b1Module),
                                                                     "flipAngle":    Number(flipAngle),
                                                                     "deltaf":       Number(deltaf)});}
        if(gradientsVisible){
            var gradients = blockList.get(blockID).gradients;
            for(var i=0; i<gradients.count; i++){
                var grad = gradients.get(i);
                blockList.get(blockID).gradients.set(i,             {"axis":         grad.axis,
                                                                     "delay":        eval('Number(g' + grad.axis + 'Delay)'),
                                                                     "rise":         eval('Number(g' + grad.axis + 'Rise)'),
                                                                     "flatTop":      eval('Number(g' + grad.axis + 'FlatTop)'),
                                                                     "amplitude":    eval('Number(g' + grad.axis + 'Amplitude)'),
                                                                     "step":         eval('Number(g' + grad.axis + 'Step)')});}
        }
        if(tVisible)        {blockList.get(blockID).t.set(0,        {"te":           Number(te),
                                                                     "tr":           Number(tr)});}
        if(groupVisible)    {blockList.setProperty(blockID,          "repetitions",  Number(repetitions));}

        var blockInfo = blockList.get(blockID);

        duration =      durationVisible ?   blockInfo.duration : 0;
        lines =         linesVisible ?      blockInfo.lines : 0;
        samples =       samplesVisible ?    blockInfo.samples : 0;
        adcDelay =      adcDelayVisible ?   blockInfo.adcDelay : 0;
        fov =           fovVisible ?        blockInfo.fov : 0;
        shape =         rfVisible ?         blockInfo.rf.get(0).shape : 0;
        b1Module =      rfVisible ?         blockInfo.rf.get(0).b1Module : 0;
        flipAngle =     rfVisible ?         blockInfo.rf.get(0).flipAngle : 0;
        deltaf =        rfVisible ?         blockInfo.rf.get(0).deltaf : 0;
        gxDelay =       gradientsVisible ?  blockInfo.gradients.get(0).delay : 0;
        gyDelay =       gradientsVisible ?  blockInfo.gradients.get(1).delay : 0;
        gzDelay =       gradientsVisible ?  blockInfo.gradients.get(2).delay : 0;
        gxRise =        gradientsVisible ?  blockInfo.gradients.get(0).rise : 0;
        gyRise =        gradientsVisible ?  blockInfo.gradients.get(1).rise : 0;
        gzRise =        gradientsVisible ?  blockInfo.gradients.get(2).rise : 0;
        gxFlatTop =     gradientsVisible ?  blockInfo.gradients.get(0).flatTop : 0;
        gyFlatTop =     gradientsVisible ?  blockInfo.gradients.get(1).flatTop : 0;
        gzFlatTop =     gradientsVisible ?  blockInfo.gradients.get(2).flatTop : 0;
        gxAmplitude =   gradientsVisible ?  blockInfo.gradients.get(0).amplitude : 0;
        gyAmplitude =   gradientsVisible ?  blockInfo.gradients.get(1).amplitude : 0;
        gzAmplitude =   gradientsVisible ?  blockInfo.gradients.get(2).amplitude : 0;
        gxStep =        gradientsVisible ?  blockInfo.gradients.get(0).step : 0;
        gyStep =        gradientsVisible ?  blockInfo.gradients.get(1).step : 0;
        gzStep =        gradientsVisible ?  blockInfo.gradients.get(2).step : 0;
        te =            tVisible ?          blockInfo.t.get(0).te : 0;
        tr =            tVisible ?          blockInfo.t.get(0).tr : 0;
        repetitions =   groupVisible ?      blockInfo.repetitions : 0;
    }

    Rectangle{
        id: rectConfig
        visible: menuVisible
        anchors.fill: parent

        color: menuColor

        radius: window.radius

        RectangularGlow {
            id: configGlow
            anchors.fill: parent
            visible: parent.visible & !popup.visible
            glowRadius: 6
            spread: 0.2
            color: menuColor
            opacity: 0.6
            cornerRadius: parent.radius + glowRadius
        }

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
                implicitWidth: column.width
                color: Qt.lighter(menuColor,1.3)
                z:-10
            }
        }

        Row{
            visible: rfVisible
            anchors.right: column.right
            anchors.top: column.top
            anchors.margins: 2
            Label{
                visible: !window.mobile
                text: "Select: "
            }

            ComboBoxItem{
                id: rfSelect;
                model: ["Flip angle and duration", "Flip angle and amplitude", "Duration and amplitude"];
                // onAccepted:{
                //     switch(currentIndex){
                //     case 0:
                //         b1ModuleInput.visible = false;
                //         durationInput.visible = true;
                //         flipAngleInput.visible = true;
                //         break;
                //     case 1:
                //         durationInput.visible = false;
                //         b1ModuleInput.visible = true;
                //         flipAngleInput.visible = true;
                //         break;
                //     case 2:
                //         flipAngleInput.visible = false;
                //         b1ModuleInput.visible = true;
                //         durationInput.visible = true;
                //         break;
                //     }
                // }
            }
        }



        Column {
            id: column
            anchors.top: configText.bottom
            width: parent.width - 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 5
            spacing: 5

            Loader { visible: linesVisible
                sourceComponent: configPanel
                width:200
                height: 26
                GridLayout{ id: linesLayout
                    uniformCellWidths: true
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "Lines:";   bold: true;   Layout.columnSpan: 2}
                    TextInputItem{ id: linesInput;              Layout.alignment: Qt.AlignRight }
                    MenuLabel { text: "lines" }
                }
            }

            Loader { visible: samplesVisible
                sourceComponent: configPanel
                width:200
                height: 26
                GridLayout{ id: samplesLayout
                    uniformCellWidths: true
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "Samples:";  bold: true;  Layout.columnSpan: 2}
                    TextInputItem{ id: samplesInput;            Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "samples" }
                }
            }

            Loader { visible: samplesVisible
                sourceComponent: configPanel
                width:200
                height: 26
                GridLayout{ id: adcDelayLayout
                    uniformCellWidths: true
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "ADC Delay:";  bold: true;  Layout.columnSpan: 2}
                    TextInputItem{ id: adcDelayInput;            Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s" }
                }
            }

            Loader { visible: durationVisible
                sourceComponent: configPanel
                width:200
                height: 26
                enabled: rfVisible & rfSelect.currentIndex === 1 ? false : true
                opacity: enabled
                GridLayout{ id: durationLayout
                    uniformCellWidths: true
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "Duration:";  bold: true; Layout.columnSpan: 2}
                    TextInputItem{ id:durationInput;            Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s"}
                }
            }

            Loader { visible: fovVisible
                sourceComponent: configPanel
                width:200
                height: 26
                GridLayout{ id: fovLayout
                    uniformCellWidths: true
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 3

                    MenuLabel { text: "FOV:";  bold: true;      Layout.columnSpan: 2}
                    TextInputItem{ id:fovInput;                 Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "m" }
                }
            }

            Loader { visible: rfVisible
                sourceComponent: configPanel
                height: 72
                Flickable {
                    anchors.fill:parent
                    anchors.leftMargin: 5; anchors.rightMargin: 5
                    contentHeight: this.height
                    contentWidth: rfLayout.width
                    clip:true
                    GridLayout{ id: rfLayout
                        anchors.fill: parent
                        anchors.margins:3
                        columns: 5
                        rowSpacing: 3

                        MenuLabel { text: "RF:";                    bold: true}
                        MenuLabel { text: "RF Shape:";              Layout.alignment: Qt.AlignRight}
                        ComboBoxItem{
                            id: shapeInput;
                            model: ["Rectangle (hard)", "Sinc"];
                        }

                        MenuLabel { text: "Peak |B1|[T]:";          Layout.alignment: Qt.AlignRight;                                enabled:b1ModuleInput.enabled; opacity: enabled}
                        TextInputItem{  id:b1ModuleInput
                                        enabled: rfVisible & rfSelect.currentIndex === 0 ? false : true
                                        opacity: enabled }

                        MenuLabel { text: "Flip Angle [º]:";        Layout.alignment: Qt.AlignRight;        Layout.columnSpan: 2;   enabled:flipAngleInput.enabled; opacity: enabled}
                        TextInputItem{  id:flipAngleInput;           Layout.columnSpan: 3
                                        enabled: rfVisible & rfSelect.currentIndex === 2 ? false : true
                                        opacity: enabled }

                        MenuLabel { text: "Δf [Hz]:";               Layout.alignment: Qt.AlignRight;        Layout.columnSpan: 2}
                        TextInputItem{ id:deltafInput}
                    }
                }
            }

            Loader { visible: gradientsVisible
                sourceComponent: configPanel
                height: 90
                Flickable {
                    anchors.fill:parent
                    anchors.leftMargin: 5; anchors.rightMargin: 5
                    contentHeight: this.height
                    contentWidth: gradientsLayout.width
                    clip:true
                    GridLayout{ id: gradientsLayout
                        columns: 6
                        anchors.fill: parent
                        anchors.margins:3
                        anchors.rightMargin: 10
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
            }

            Loader { visible: tVisible
                sourceComponent: configPanel
                height: 50
                width: 200
                GridLayout{ id:tLayout
                    uniformCellWidths: true
                    anchors.fill: parent
                    anchors.margins:3
                    columns: 4
                    rowSpacing: 1
                    MenuLabel { text: "TE:";  bold: true;       Layout.columnSpan: 2}
                    TextInputItem{ id:teInput;                  Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s" }
                    MenuLabel { text: "TR:";  bold: true;       Layout.columnSpan: 2}
                    TextInputItem{ id:trInput;                  Layout.alignment: Qt.AlignRight}
                    MenuLabel { text: "s"}
                }
            }

            Loader { visible: groupVisible
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

        //  APPLY CHANGES
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
            onClicked:{ applyChanges(blockID) }
        }

        // VIEW 3D MODEL OF SELECTED SLICE
        Button{
            id: plotButton
            visible: rfVisible
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
