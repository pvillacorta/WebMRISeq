import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects


Item{
    id: block

    height: 100
    width: collapsed? 0:100-20*ngroups
    visible:collapsed?false:true

    property int dropIndex: index

    property string blockText:  cod==0? name:
                                cod==1? "Ex":
                                cod==2? "Delay":
                                cod==3? "Dephase":
                                cod==4? "Readout":
                                cod==5? "EPI_ACQ":
                                cod==6? "GRE":
                                undefined

    property string blockColor: cod==0? "#cca454":
                                cod==1? "#ed645a":
                                cod==2? "#61e86f":
                                cod==3? "#e3f56e":
                                cod==4? "#a68ff2":
                                cod==5? "#ffa361":
                                cod==6? "#ffa361":
                                undefined

    function displayFields(index){
        cod = blockList.get(index).cod
        switch(cod){
            // Group
            case 0:
                configMenu.durationVisible =    false;
                configMenu.rfVisible =          false;
                configMenu.gradientsVisible =   false;
                configMenu.linesVisible =       false;
                configMenu.samplesVisible =     false;
                configMenu.fovVisible =         false;
                configMenu.groupVisible =       true;
                configMenu.tVisible =           false;
                break;
            // Excitation
            case 1:
                configMenu.durationVisible =    true;
                configMenu.rfVisible =          true;
                configMenu.gradientsVisible =   true;
                configMenu.linesVisible =       false;
                configMenu.samplesVisible =     false;
                configMenu.fovVisible =         false;
                configMenu.groupVisible =       false;
                configMenu.tVisible =           false;
                break;

            // Delay
            case 2:
                configMenu.durationVisible =    true;
                configMenu.rfVisible =          false;
                configMenu.gradientsVisible =   false;
                configMenu.linesVisible =       false;
                configMenu.samplesVisible =     false;
                configMenu.fovVisible =         false;
                configMenu.groupVisible =       false;
                configMenu.tVisible =           false;
                break;

            // Dephase
            case 3:
                configMenu.durationVisible =    true;
                configMenu.rfVisible =          false;
                configMenu.gradientsVisible =   true;
                configMenu.linesVisible =       false;
                configMenu.samplesVisible =     false;
                configMenu.fovVisible =         false;
                configMenu.groupVisible =       false;
                configMenu.tVisible =           false;
                break;

            // Readout
            case 4:
                configMenu.durationVisible =    true;
                configMenu.rfVisible =          false;
                configMenu.gradientsVisible =   true;
                configMenu.linesVisible =       false;
                configMenu.samplesVisible =     true;
                configMenu.fovVisible =         false;
                configMenu.groupVisible =       false;
                configMenu.tVisible =           false;
                break;

            // EPI Adquisition
            case 5:
                configMenu.durationVisible =    false;
                configMenu.rfVisible =          false;
                configMenu.gradientsVisible =   false;
                configMenu.linesVisible =       true;
                configMenu.samplesVisible =     true;
                configMenu.fovVisible =         true;
                configMenu.groupVisible =       false;
                configMenu.tVisible =           false;
                break;

            // GRE (Gradient Echo)
            case 6:
                configMenu.durationVisible =    false;
                configMenu.rfVisible =          true;
                configMenu.gradientsVisible =   false;
                configMenu.linesVisible =       true;
                configMenu.samplesVisible =     true;
                configMenu.fovVisible =         true;
                configMenu.groupVisible =       false;
                configMenu.tVisible =           true;
                break;
        }

        configMenu.duration =       blockList.get(index).duration
        configMenu.lines =          blockList.get(index).lines
        configMenu.samples =        blockList.get(index).samples
        configMenu.fov =            blockList.get(index).fov
        if (configMenu.rfVisible){
            configMenu.shape =      blockList.get(index).rf.get(0).shape
            configMenu.b1Module =   blockList.get(index).rf.get(0).b1Module
            configMenu.flipAngle =  blockList.get(index).rf.get(0).flipAngle
            configMenu.deltaf =     blockList.get(index).rf.get(0).deltaf
        }
        if (configMenu.tVisible){
            configMenu.te =         blockList.get(index).t.get(0).te
            configMenu.tr =         blockList.get(index).t.get(0).tr
        }
        if (configMenu.groupVisible){
            configMenu.repetitions= blockList.get(index).repetitions
        }
        if (configMenu.gradientsVisible){
            var gradients = blockList.get(index).gradients
            for (var i=0; i<gradients.count; i++){
                var grad = gradients.get(i);
                eval('configMenu.g' + grad.axis + 'Delay = grad.delay');
                eval('configMenu.g' + grad.axis + 'Rise = grad.rise');
                eval('configMenu.g' + grad.axis + 'FlatTop = grad.flatTop');
                eval('configMenu.g' + grad.axis + 'Amplitude = grad.amplitude');
                eval('configMenu.g' + grad.axis + 'Step = grad.step');
            }
        }
    }

    MouseArea {
        id: dragArea
        property bool held: false
        property bool hovered: false
        property bool selected: blockSeq.displayedMenu == dropIndex? true: false
        property bool dragged: false

        anchors.horizontalCenter: held? undefined: parent.horizontalCenter
        anchors.bottom: held? undefined: parent.bottom

        width:  parent.width
        height:  width

        drag.target: held? dragArea: undefined
        drag.axis: Drag.XAndYAxis

        onClicked:{ //Configuration panel will be displayed:
            if(!popup.active){

                blockSeq.focus = true;
                blockSeq.displayedMenu = dropIndex;

                configMenu.menuVisible = true;

                configMenu.blockID = dropIndex;
                configMenu.menuColor = blockColor;
                configMenu.menuTitle = blockText;

                displayFields(dropIndex);

                for(var i=0; i<blockList.count; i++){
                     collapse(i);
                }
                 expand(configMenu.blockID);

            }else{
                grouped = !grouped;
            }
        }

        hoverEnabled: true

        onEntered: {
            blockSeq.hoveredBlock = dropIndex;

            if(!blockView.held){
                if(!isChild(dropIndex)){ // If it is not a child (1st level node)
                    // Collapse all nodes so we can only see 1st level nodes
                    for (var i=0; i<blockList.count; i++){
                         collapse(i);
                    }
                }
                else { // If it is a child
                    var max = -1;
                    var min = blockSeq.displayedGroup;

                    if(min>=0){
                        for (i=0; i<blockList.get(min).children.count; i++){
                            if(blockList.get(min).children.get(i).number > max){
                                max = blockList.get(min).children.get(i).number;
                            }
                        }
                        if (dropIndex<min || dropIndex>max){
                            for (i=0; i<blockList.get(min).children.count; i++){
                                 collapse(blockList.get(min).children.get(i).number)
                            }
                            blockSeq.displayedGroup = getParent(dropIndex);
                        }
                    }
                }
                if(isGroup(dropIndex)){ // If it is a group (Note that a block could be a child and a group at the same time)
                    blockSeq.displayedGroup = dropIndex
                }

                expand(blockSeq.hoveredBlock);

                if(blockSeq.displayedMenu>=0){
                    expand(blockSeq.displayedMenu);
                }
            }
        }

        onExited: {
            dragged = false;
            if(!blockView.held){
                timer.setTimeout(function(){
                    if(dropIndex==blockSeq.hoveredBlock){
                        blockSeq.hoveredBlock = -1;
                        for (var i=0; i<blockList.count; i++){
                            if (blockList.get(i).grouped){
                                return;
                            }
                        }
                        for (i=0; i<blockList.count; i++){
                                collapse(i);
                        }

                        if(blockSeq.displayedMenu>=0){
                            expand(blockSeq.displayedMenu);
                        }
                    }
                }, 10);
            }
        }

        // ---------------------------------- DRAG AND DROP MECHANICS ---------------------------------------

        onPressed:{
            if (!window.mobile){
                dragged = true;
                if(!popup.active){
                    held = true
                    blockView.held = true;
                    blockView.dragIndex = dropIndex

                    if(isGroup(dropIndex)){
                        for(var i=0; i<blockList.get(dropIndex).children.count; i++){
                            collapse(blockList.get(dropIndex).children.get(i).number);
                        }
                    }
                }
            }
        }

        onPressAndHold:{
            if (window.mobile){
                dragged = true;
                if(!popup.active){
                    held = true
                    blockView.held = true;
                    blockView.dragIndex = dropIndex

                    if(isGroup(dropIndex)){
                        for(var i=0; i<blockList.get(dropIndex).children.count; i++){
                            collapse(blockList.get(dropIndex).children.get(i).number);
                        }
                    }
                }
            }
        }

        onReleased: {
            dragged = false;
            held = false;
            blockView.held = false;
        }

        Drag.active: held
        Drag.source: dragArea
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        // We define a DropArea on each element so we can determine when the hot spot of the dragged object interacts with another object
        DropArea {
            id:dropArea
            anchors {fill: parent; margins: 10}

            onEntered: {
                // Blocks must be siblings so we can move them
                if(getParent(dropIndex) === getParent(blockView.dragIndex)){
                    configMenu.menuVisible = false;
                    blockSeq.displayedMenu = -1;

                    moveBlock(blockView.dragIndex,dropIndex)
                }
            }
        } // DropArea

        RectangularGlow {
            id: itemGlow
            anchors.fill: item
            visible: !dragArea.held
            glowRadius: 4
            spread: 0.2
            color: item.color
            opacity: 0.5
            cornerRadius: item.radius + glowRadius
        }

        Rectangle {
            id: item;
            color: blockColor
            anchors.fill: parent
            anchors.margins: 10

            radius: 4

            // Block Text
            Text {
                id: textBlock
                color: "black"
                font.pointSize: 10 - 2*ngroups
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                text: blockText
             }

            Text {
                id: blockNumber
                color: "black"
                font.pointSize: 8 - ngroups
                anchors{
                    left: parent.left
                    bottom: parent.bottom
                    margins: 4
                }
                text: dropIndex
            }

            //Delete button
            DeleteButton {
                function clicked(){
                    removeBlock(index);
                    configMenu.menuVisible = false;
                    blockSeq.displayedMenu = -1;
                }

                anchors.top: parent.top
                anchors.right: parent.right

                anchors.margins:2

                height: 15 - 2*ngroups
                width: 15 - 2*ngroups

                color: Qt.darker(blockColor,1.3)
            }

        } //Rectangle

        Item{
            visible:!dragArea.held
            anchors.left:item.right
            anchors.leftMargin:6
            anchors.verticalCenter: item.verticalCenter
            height:12
            width:8
            Image{
                visible:index==blockList.count-1?false:true
                source: "qrc:/icons/arrow_gray.png"
                anchors.fill:parent
            }
        }

        states: [
            State {
                name: "held"; when: dragArea.Drag.active
                PropertyChanges{
                    target: item
                    color: Qt.darker(blockColor,1.5)
                    scale: 0.7
                    opacity: 1
                }
                PropertyChanges{
                    target: block
                    z: 100
                }
                PropertyChanges{
                    target: dropArea
                    visible:false
                }
            },

            State {
                name: "grouped"; when: grouped
                PropertyChanges{
                    target: itemGlow
                    scale: 0.8
                }
                PropertyChanges{
                    target: item
                    scale: 0.8
                }
            }, State{
                name:"selected"; when: dragArea.selected;
                PropertyChanges{
                    target: item
                    color: Qt.darker(blockColor,1.8)
                }
                PropertyChanges{
                    target: textBlock
                    font.bold: true
                    color: "white"
                }
            }, State{
                name:"dragged"; when: dragArea.dragged;
                PropertyChanges{
                    target: item
                    scale: 0.75
                }
            }
        ]

        // ANIMACIONES dependientes del cambio de estado
        transitions: [
            Transition{
                PropertyAnimation {property: "scale"; duration: 40}
                PropertyAnimation {property: "color"; duration: 80}
                AnchorAnimation { duration: 100 }
            }
        ]

    } // MouseArea
} //Item


