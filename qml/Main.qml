// Comentario de prueba

import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

ApplicationWindow {
    id: window

    width: 1100;
    height: 1000
    minimumHeight: desktop ? 470 : (!mobile ? 630 : 710)

    // WINDOW SIZE
    property bool desktop: width>=1100
    property bool mobile: width<660

    // COLORS
    property string dark: "#212529"
    property string dark_secondary: "#343a40"
    property string light: "#d8e0e8"

    // CONFIGURATION PANEL (THIS IS THE PANEL WITH OPTIONS FOR EACH BLOCK)
    property int fieldWidth: 60
    property int fieldHeight: 20
    property int fontSize: 8

    // RIGHT BUTTONS
    property int buttonTextSize: 10

    color: dark
    visible:true

    // -------------------------------------- FUNCTIONS ------------------------------------------
    // Function addToGroup() looks for all the children of a specified block.
    // If the children of the block also have children (like in a tree structure),
    // the function works recursively so all the children can be found.
    // The function does not physically move any block (this is done by the blockList.move() method),
    // but it changes the index of the children attribute of a block so, if we move a group, all its children are also moved
    function addToGroup(index){
        var child;
        // We enter this loop if the selected block is a group
        if(isGroup(index)){
            var children = blockList.get(index).children.count;
            for(var i=0;i<children;i++){
                blockList.get(index).children.get(i).number++;
                child = blockList.get(index).children.get(i).number;
                addToGroup(child);
            }
        }

        blockList.get(index).ngroups++;
        collapse(index);
    }


    // Function collapse() recursively collapses a block and its children
    function collapse(index){
        var child, children;

        if(isGroup(index)){
            children = blockList.get(index).children.count;
            for(var i=0;i<children;i++){
                child = blockList.get(index).children.get(i).number;
                collapse(child);
            }
        }

       // If the block does not belong to any group, we cannot collapse it
       if(isChild(index)){
           blockList.get(index).collapsed=true;
       }
    }


    // As well as function collapse() collapses a block and all its children,
    // function expand() makes a block and all its parents/siblings visible
    // If the index corresponds to a group, its children expand too (only its direct children)
    function expand(index){
        if(isChild(index)){
            var children = blockList.get(getParent(index)).children.count;
            for (var i=0; i<children; i++){
                blockList.get(blockList.get(getParent(index)).children.get(i).number).collapsed = false;
            }
            expand(getParent(index));
        }

        if(isGroup(index)){
            children = blockList.get(index).children.count;
            for (i=0; i<children; i++){
                blockList.get(blockList.get(index).children.get(i).number).collapsed = false;
            }
        }
    }


    // Function moveBlock() moves a block to an specified position
    function moveBlock(from,to){
        var fromChildren = countChildren(from);
        var toChildren = countChildren(to);

       // If the blocks that we are moving belong to a group, we need to modify the children attribute of that outter group
       if(isChild(from) && isChild(to)){
           var parent = getParent(from);
           var child;
           if(from<to){
               for(var i=0;i<blockList.get(parent).children.count;i++){
                   child = blockList.get(parent).children.get(i).number;
                   if (child>from && child<=to){
                        blockList.get(parent).children.get(i).number -= (fromChildren+1);
                   }
                   else if (child==from){
                        blockList.get(parent).children.get(i).number = (to + toChildren - fromChildren);
                   }
               }
           }
           else if(from>to){
               for(i=0;i<blockList.get(parent).children.count;i++){
                   child = blockList.get(parent).children.get(i).number;
                   if (child<from && child>=to){
                        blockList.get(parent).children.get(i).number += fromChildren + 1;
                   }
                   else if (child==from){
                        blockList.get(parent).children.get(i).number = to;
                   }
               }
           }
       }
       if(from<to){ // We move from left to right
           for(var i=from;i<=from+fromChildren;i++){
               moveGroup(i,to+toChildren-(from+fromChildren));
           }

           for(i=to;i<=to+toChildren;i++){
               moveGroup(i,-(fromChildren+1));
           }

           blockSeq.displayedMenu = to+toChildren-fromChildren;
           configMenu.blockID = to+toChildren-fromChildren;

           blockList.move(from, blockView.dragIndex=to+toChildren-fromChildren, fromChildren+1);
       }
       else if(from>to){ // We move from right to left
           for(i=from;i<from+1+fromChildren;i++){
               moveGroup(i,to-from);
           }
           for(i=from-1;i>=to;i--){
                moveGroup(i,fromChildren+1);
           }

           blockSeq.displayedMenu = to;
           configMenu.blockID = to;

           blockList.move(from,blockView.dragIndex=to,fromChildren+1);
       }
    }


    // function moveGroup() changes (non recursively) the index of the children attribute from a displaced block
    function moveGroup(index,displacement){
        if(isGroup(index)){
            var children = blockList.get(index).children.count;
            for(var i=0;i<children;i++){
                blockList.get(index).children.get(i).number += displacement;
            }
        }
    }


    // Function removeBlock() removes a block from the list. If the block is a group,
    // it removes recursively that group and all of its children
    function removeBlock(index){
        var children = countChildren(index);
        // If there are groups more to the right than the removed block, we must displace their children (1+children) positions to the left
        for(var i=index+children+1;i<blockList.count;i++){
            moveGroup(i,-(1+children));
        }
        // If the removed block is a child, we must delete it fromm his parent (and move the children more to the right (1+children) positions to the left)
        if(isChild(index)){
            var parent = getParent(index);
            var child;
            for(i=0;i<blockList.get(parent).children.count;i++){
                child = blockList.get(parent).children.get(i).number;
                if(child==index){
                    blockList.get(parent).children.remove(i);
                }
            }
            for(i=0;i<blockList.get(parent).children.count;i++){
                child = blockList.get(parent).children.get(i).number;
                if (child>index){
                    blockList.get(parent).children.get(i).number -= (1+children)
                }
            }
        }
        // We remove the block and all of its children from the list:
        blockList.remove(index,1+children);
    }


    // Function isChild() returns true is a block belongs to a group
    function isChild(index){
        for(var i=0; i<blockList.count; i++){
            for(var j=0; j<blockList.get(i).children.count; j++){
                if(blockList.get(i).children.get(j).number === index){
                    return true;
                }
            }
        }
        return false;
    }


    // Function isGroup() returns true if a block is a group
    function isGroup(index){
        if(typeof(blockList.get(index).children)!=='undefined'){
            if(blockList.get(index).children.count > 0){
                return true;
            }
        }
        return false;
    }


    // Function countChildren() returns the number of blocks that inherit from a group.
    // To do this, we need a wrapper function to hold the accumulator
    function countChildren(index){
        let children = [0];
        function countInnerChildren(i){
            if(isGroup(i)){
                children.push(getMaxOfArray(children) + blockList.get(i).children.count);
                for(var j=0; j<blockList.get(i).children.count; j++){
                    countInnerChildren(blockList.get(i).children.get(j).number);
                }
            }
        }
        countInnerChildren(index);
        return getMaxOfArray(children);
    }


    // Function getParent()
    function getParent(index){
        for (var i=0; i<blockList.count; i++){
            for (var j=0; j<blockList.get(i).children.count; j++){
                if(blockList.get(i).children.get(j).number === index){
                    return i;
                }
            }
        }
        return -1;
    }


    // Function createSeq() creates an array from the block Sequence. This array will be the input argument to the simulator
    function createSeq(){
        var array = [];
        for(var i=0; i<10; i++){
            array[i] = [];
        }

        function addToSeq(i,rep){
            var children, reps;
            var j,k;
            if(i>=blockList.count){
                return;
            }

            if(isGroup(i)){
                reps = blockList.get(i).reps;
                children = blockList.get(i).children.count;
                for(j=0;j<reps;j++){
                    for(k=0;k<children;k++){
                        addToSeq(blockList.get(i).children.get(k).number,j);
                    }
                }
            } else {
                array[0].push(blockList.get(i).cod);
                array[1].push(blockList.get(i).dur);
                array[2].push(blockList.get(i).gx + rep*blockList.get(i).gxStep);
                array[3].push(blockList.get(i).gy + rep*blockList.get(i).gyStep);
                array[4].push(blockList.get(i).gz + rep*blockList.get(i).gzStep);
                array[5].push(blockList.get(i).b1x);
                array[6].push(blockList.get(i).b1y);
                array[7].push(blockList.get(i).delta_f);
                array[8].push(blockList.get(i).fov);
                array[9].push(blockList.get(i).n);
            }
        }

        for (var n=0; n<blockList.count; n++){
            if(!isChild(n)){
                addToSeq(n,0);
            }
        }

        return array;
    }


    // Function createScanner creates an array composed by global parameters for the simulator (Gmax, sampling period...)
    function createScanner(){
        var array = [];

        array[0] = Number(globalMenu.b0);
        array[1] = Number(globalMenu.b1);
        array[2] = Number(globalMenu.delta_t);
        array[3] = Number(globalMenu.gmax);
        array[4] = Number(globalMenu.smax);

        // print("Scanner: ", array);

        return array;
    }


    // Function saveSeq() creates an array from the block Sequence. This array will be
    // passed to C++ so we will be able to save the Sequence in a file for future use
    function saveSeq(){
        var array = [];
        for(var i=0; i<18; i++){
            array[i] = [];
            for(var j=0; j<blockList.count; j++){
                array[i][j] = []; //We need to store the children so we need a 3D array
            }
        }
        for(j=0; j<blockList.count; j++){
            array[0][j].push(blockList.get(j).cod);
            array[1][j].push(blockList.get(j).dur);
            array[2][j].push(blockList.get(j).gx);
            array[3][j].push(blockList.get(j).gy);
            array[4][j].push(blockList.get(j).gz);
            array[5][j].push(blockList.get(j).gxStep);
            array[6][j].push(blockList.get(j).gyStep);
            array[7][j].push(blockList.get(j).gzStep);
            array[8][j].push(blockList.get(j).b1x);
            array[9][j].push(blockList.get(j).b1y);
            array[10][j].push(blockList.get(j).delta_f);
            array[11][j].push(blockList.get(j).fov);
            array[12][j].push(blockList.get(j).n);
            array[13][j].push(blockList.get(j).ngroups);

            for(var k=0; k<blockList.get(j).name.length; k++){
                array[14][j].push(blockList.get(j).name.charCodeAt(k));
            }

            for(k=0; k<blockList.get(j).children.count; k++){
                array[15][j].push(blockList.get(j).children.get(k).number);
            }

            if(isChild(j)){
                array[16][j].push(1);
            } else {
                array[16][j].push(0);
            }

            array[17][j].push(blockList.get(j).reps);
        }

        return array;
    }


    // functions getMaxOfArray and getMinOfArray
    function getMaxOfArray(numArray) {
        return Math.max.apply(null, numArray);
    }
    function getMinOfArray(numArray) {
        return Math.min.apply(null, numArray);
    }


    // Timer & delay
    Timer {
        id: timer
        function setTimeout(cb, delayTime) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.triggered.connect(function release () {
                timer.triggered.disconnect(cb); // This is important
                timer.triggered.disconnect(release); // This is important as well
            });
            timer.start();
        }
    }




    // ------------------------- BLOCK LIST ---------------------------------------------------
    ListModel{id:blockList}

    // In this loader we will store the loaded sequence from a previously saved file
    Loader{id: modelLoader}
    // -----------------------------------------------------------------------------------------


    // SEQUENCE TITLE
    Rectangle {
        id: seqTitle

        x: blockSeq.x
        height:25
        width:blockSeq.width

        anchors.bottom: blockSeq.top

        color: dark_secondary

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            text: "Block sequence"

            font.pointSize: 14

            color: light
        }
    }


    // SEQUENCE
    MouseArea{
        id: blockSeq
        y: 50

        height: 105
        width: parent.width - 50
        anchors.horizontalCenter: parent.horizontalCenter

        property int hoveredBlock: -1
        property int displayedGroup: -1
        property int displayedMenu: -1

        // BLOCK MOVEMENT VIA KEYBOARD ------------------------------------------------------------
        Keys.onLeftPressed: {
            for(var i=displayedMenu-1; i>=0; i--){
                if(getParent(displayedMenu) === getParent(i)){
                    moveBlock(displayedMenu,i);
                    break;
                }
            }
        }
        Keys.onRightPressed: {
            for(var i=displayedMenu+1; i<blockList.count; i++){
                if(getParent(displayedMenu) === getParent(i)){
                    moveBlock(displayedMenu,i);
                    break;
                }
            }
        }
        // -------------------------------------------------------------------------------------

        WheelHandler{
            onWheel: (event)=> event.angleDelta.y<0 ? scrollBar.increase(): scrollBar.decrease();
        }

        Rectangle {
            color:"gray"
            anchors.fill: parent

            ListView {
                id: blockView

                property int dragIndex // Index of the block that we are dragging
                property bool held: false // Tells us is we are dragging a block or not

                anchors.fill: parent
                interactive: true

                orientation: ListView.Horizontal

                // This blockList is the model used for visualizing the data.
                model: blockList

                delegate: BlockItem{}

                ScrollBar.horizontal: ScrollBar {
                    id: scrollBar
                    active: true
                    orientation: Qt.Horizontal
                }

                // ANIMATIONS when elements are added or moved
                add: Transition{
                    NumberAnimation {property: "scale"; from: 0; to: 1; duration: 100}
                }
                move: Transition{
                    NumberAnimation {properties: "x,y"; easing.type: Easing.OutBack; duration: 200}
                }
                displaced: Transition{
                    NumberAnimation {properties: "x,y"; easing.type: Easing.OutBack; duration: 200}
                }
                remove: Transition{
                    NumberAnimation {property: "scale"; from: 1; to: 0; duration: 100}
                }
            }//ListView
        }//Rectangle
    } //MouseArea

    // We define a component so we can use it by multiple Loader objets
    Component{
        id: borderSquare
        Rectangle {
            color: window.color
            height: 500

            width: 25

            y: blockSeq.y
        }
    }//Component

    // Right and left border for the sequence panel:
    Loader{
        sourceComponent: borderSquare
        anchors{left: blockSeq.right}
    }

    Loader{
        sourceComponent: borderSquare
        anchors{right: blockSeq.left}
    }


    // ADD BLOCKS
    Item{
        id: buttons
        anchors.top: blockSeq.bottom; anchors.topMargin:15
        anchors.left: blockSeq.left
        width: window.mobile ? blockSeq.width : 100
        height: window.mobile ? 70 : defaultMenu.height

        z:-15

        Rectangle{
            id: addBlocksTitle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: window.mobile ? 25 : 35

            color: seqTitle.color

            z:50

            Text {
                id: name
                text: qsTr("Add block:")
                color:light
                font.pointSize: 10
                anchors.centerIn: parent
            }
        }

        Rectangle{
            id: addBlocksButtons

            anchors.top: addBlocksTitle.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            color: "gray"

            MouseArea{
                anchors.fill: parent

                WheelHandler{
                    onWheel: (event)=> event.angleDelta.y<0 ? horizontalScrollBar.increase(): horizontalScrollBar.decrease();
                }

                ListView {
                    id: buttonView
                    anchors.fill: parent
                    anchors.topMargin: 5
                    anchors.leftMargin: 10
                    spacing: 15

                    orientation: window.mobile ?  ListView.Horizontal : ListView.Vertical

                    ScrollBar.horizontal: ScrollBar {
                        id: horizontalScrollBar
                        active: window.mobile
                        orientation: Qt.Horizontal
                    }

                    delegate: Button{
                        id: button
                        parent: buttonView
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            text: buttonText
                            color: light
                            font.pointSize: 8
                        }
                        height:25
                        width:60

                        background: Rectangle{
                            anchors.fill:parent
                            color: button.pressed? dark :"#595959"
                        }

                        scale: hovered? 0.9: 1

                        onClicked: {
                            blockSeq.displayedMenu = -1;

                            if(code<=6){
                                blockList.append({ "cod":code,
                                                   "dur":0,
                                                   "gx":0,
                                                   "gy":0,
                                                   "gz":0,
                                                   "gxStep":0,
                                                   "gyStep":0,
                                                   "gzStep":0,
                                                   "b1x":0,
                                                   "b1y":0,
                                                   "delta_f":0,
                                                   "fov":0,
                                                   "n":0,
                                                   "grouped":false,
                                                   "ngroups":0,
                                                   "name":"",
                                                   "children":[],
                                                   "collapsed": false,
                                                   "reps":1});
                            } else if(code>6){
                                var index;
                                for(var i=0; i<groupList.count; i++){
                                    if(groupList.get(i).group_cod == code){
                                        index = i;
                                    }
                                }
                                var num;
                                var counter = 0;

                                do{
                                    blockList.append(  {"cod":groupList.get(index).cod,
                                                        "dur":groupList.get(index).dur,
                                                        "gx":groupList.get(index).gx,
                                                        "gy":groupList.get(index).gy,
                                                        "gz":groupList.get(index).gz,
                                                        "gxStep":groupList.get(index).gxStep,
                                                        "gyStep":groupList.get(index).gyStep,
                                                        "gzStep":groupList.get(index).gzStep,
                                                        "b1x":groupList.get(index).b1x,
                                                        "b1y":groupList.get(index).b1y,
                                                        "delta_f":groupList.get(index).delta_f,
                                                        "fov":groupList.get(index).fov,
                                                        "n":groupList.get(index).n,
                                                        "grouped":false,
                                                        "ngroups":groupList.get(index).ngroups,
                                                        "name":groupList.get(index).name,
                                                        "children":[],
                                                        "collapsed": counter==0?false:true,
                                                        "reps":groupList.get(index).reps});

                                    num = groupList.get(index).children.count;
                                    for(i=0;i<num;i++){
                                        blockList.get(blockList.count-1).children.append({"number":groupList.get(index).children.get(i).number+(-index+blockList.count-1)});
                                    }
                                    index ++;
                                    counter ++;
                                } while((index<groupList.count)&&(groupList.get(index).group_cod === -1));
                                index--;
                            }
                        }
                    }

                    model: ListModel {
                        id: buttonList
                        ListElement { buttonText: "Excitation"; code: 1 }
                        ListElement { buttonText: "Delay"; code: 2 }
                        ListElement { buttonText: "Dephase"; code: 3 }
                        ListElement { buttonText: "Readout"; code: 4 }
                        ListElement { buttonText: "EPI_ACQ"; code: 5 }
                        ListElement { buttonText: "GRE"; code: 6 }
                    } // ListModel
                } // ListView
            }
        } // Rectangle
    }


    // ADD GROUPS
    Item{
        id: groupMenu
        anchors.top: window.mobile? buttons.bottom : blockSeq.bottom
        anchors.topMargin:15
        anchors.left:  window.mobile? blockSeq.left : buttons.right
        anchors.leftMargin: window.mobile ? 0 : 15
        width: buttons.width
        height: buttons.height

        z:5

        Rectangle{
            id: addGroupsTitle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: window.mobile ? 25 : 35

            color: seqTitle.color

            z:50

            Text {
                text: qsTr("Groups:")
                color:light
                font.pointSize: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin:10
            }

            Button {
                id: groupButton
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: light
                    font.pointSize: 12
                }
                height:20
                width:height

                background: Rectangle{
                    anchors.fill:parent
                    color: groupButton.pressed? dark :"#595959"
                }

                scale: hovered? 0.9: 1
            }

        }

        Rectangle{
            id: groupButtons

            anchors.top: addGroupsTitle.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            color: "gray"

            // MouseArea{
            //     anchors.fill: parent

            //     WheelHandler{
            //         onWheel: (event)=> event.angleDelta.y<0 ? horizontalScrollBar.increase(): horizontalScrollBar.decrease();
            //     }

            //     ListView {
            //         // id: buttonView
            //         anchors.fill: parent
            //         anchors.topMargin: 5
            //         anchors.leftMargin: 10
            //         spacing: 15

            //         orientation: window.mobile ?  ListView.Horizontal : ListView.Vertical

            //         ScrollBar.horizontal: ScrollBar {
            //             // id: horizontalScrollBar
            //             active: window.mobile
            //             orientation: Qt.Horizontal
            //         }

            //         delegate: Button{
            //             // id: button
            //             parent: buttonView
            //             Text {
            //                 anchors.horizontalCenter: parent.horizontalCenter
            //                 anchors.verticalCenter: parent.verticalCenter
            //                 text: buttonText
            //                 color: light
            //                 font.pointSize: 8
            //             }
            //             height:25
            //             width:60

            //             background: Rectangle{
            //                 anchors.fill:parent
            //                 color: button.pressed? dark :"#595959"
            //             }

            //             scale: hovered? 0.9: 1

            //             onClicked: {
            //                 blockSeq.displayedMenu = -1;

            //                 if(code<=6){
            //                     blockList.append({ "cod":code,
            //                                        "dur":0,
            //                                        "gx":0,
            //                                        "gy":0,
            //                                        "gz":0,
            //                                        "gxStep":0,
            //                                        "gyStep":0,
            //                                        "gzStep":0,
            //                                        "b1x":0,
            //                                        "b1y":0,
            //                                        "delta_f":0,
            //                                        "fov":0,
            //                                        "n":0,
            //                                        "grouped":false,
            //                                        "ngroups":0,
            //                                        "name":"",
            //                                        "children":[],
            //                                        "collapsed": false,
            //                                        "reps":1});
            //                 } else if(code>6){
            //                     var index;
            //                     for(var i=0; i<groupList.count; i++){
            //                         if(groupList.get(i).group_cod == code){
            //                             index = i;
            //                         }
            //                     }
            //                     var num;
            //                     var counter = 0;

            //                     do{
            //                         blockList.append(  {"cod":groupList.get(index).cod,
            //                                             "dur":groupList.get(index).dur,
            //                                             "gx":groupList.get(index).gx,
            //                                             "gy":groupList.get(index).gy,
            //                                             "gz":groupList.get(index).gz,
            //                                             "gxStep":groupList.get(index).gxStep,
            //                                             "gyStep":groupList.get(index).gyStep,
            //                                             "gzStep":groupList.get(index).gzStep,
            //                                             "b1x":groupList.get(index).b1x,
            //                                             "b1y":groupList.get(index).b1y,
            //                                             "delta_f":groupList.get(index).delta_f,
            //                                             "fov":groupList.get(index).fov,
            //                                             "n":groupList.get(index).n,
            //                                             "grouped":false,
            //                                             "ngroups":groupList.get(index).ngroups,
            //                                             "name":groupList.get(index).name,
            //                                             "children":[],
            //                                             "collapsed": counter==0?false:true,
            //                                             "reps":groupList.get(index).reps});

            //                         num = groupList.get(index).children.count;
            //                         for(i=0;i<num;i++){
            //                             blockList.get(blockList.count-1).children.append({"number":groupList.get(index).children.get(i).number+(-index+blockList.count-1)});
            //                         }
            //                         index ++;
            //                         counter ++;
            //                     } while((index<groupList.count)&&(groupList.get(index).group_cod === -1));
            //                     index--;
            //                 }
            //             }
            //         }

            //         model: ListModel {
            //             // id: buttonList
            //             ListElement { buttonText: "Excitation"; code: 1 }
            //             ListElement { buttonText: "Delay"; code: 2 }
            //             ListElement { buttonText: "Dephase"; code: 3 }
            //             ListElement { buttonText: "Readout"; code: 4 }
            //             ListElement { buttonText: "EPI_ACQ"; code: 5 }
            //             ListElement { buttonText: "GRE"; code: 6 }
            //         } // ListModel
            //     } // ListView
            // }
        } // Rectangle
    }



    // This list stores information about the groups stored as duplicatable blocks
    ListModel {id: groupList}

    Rectangle{
        color: window.color

        height: 30
        width: buttons.width

        z: -5

        anchors{
            horizontalCenter: buttons.horizontalCenter
            top: buttons.bottom
        }
    }


    Rectangle{
        id: defaultMenu
        // visible: false

        anchors.left: window.mobile ? blockSeq.left : groupMenu.right
        anchors.leftMargin: window.mobile ? 0 : 15;

        anchors.top: window.mobile ? buttons.bottom : blockSeq.bottom;
        anchors.topMargin: 15

        width: window.mobile ? blockSeq.width : 500
        height: 280

        color: "gray"
        Text{
            anchors.centerIn: parent
            text: "Click on a block to display its menu"
            font.pointSize: 10
        }

        ConfigMenu{
            id: configMenu
            anchors.fill: parent
        }
    }


    // GLOBAL PARAMETERS PANEL
    GlobalMenu{
        id: globalMenu
        visible: true

        anchors.left: window.desktop ? defaultMenu.right : blockSeq.left
        anchors.top: window.desktop ? blockSeq.bottom : defaultMenu.bottom
        anchors.leftMargin: window.desktop ? 10 : 0
        anchors.topMargin: 15

        width: 270
        height: 155

        // Default parameters
        b0: "1.5"
        b1: "10e-6"
        delta_t: "2e-6"
        gmax: "60e-3"
        smax: "500"
    }


    // PHANTOM
    /*
    Rectangle{
        id: phantomMenu
        visible: true

        // anchors.left: globalMenu.right
        anchors.right: createGroupButton.left
        anchors.left: globalMenu.right
        anchors.leftMargin: 10; anchors.rightMargin: 10;

        y: 170
        z: -10

        height: globalMenu.height

        color: "#bdffd3"

        Text{
            text: "Phantom"
            anchors.horizontalCenter: parent.horizontalCenter
            y:5
            font.pointSize: 12
        }

        Rectangle{
            id: phantomInputRect

            border.color: "gray"
            color: "white"

            anchors.horizontalCenter: parent.horizontalCenter
            y: 30
            height: 20
            width: parent.width - 20

            TextInput{
                id: phantomInput
                anchors.fill: parent
                color: "black"
                clip: true
            }
        }

        Button{
            id: phantomButton
            y: 75

            height: 20
            width: 75
            anchors.top: phantomInputRect.bottom
            anchors.left: phantomInputRect.left
            anchors.topMargin: 2

            background: Rectangle{
                anchors.fill:parent
                color: phantomButton.pressed? dark :"#595959"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "Select Folder"
                color: light
                font.pointSize: 8
            }

            onClicked: {
                phantomDialog.open()
            }
        }

        Text{
            id: phantomName
            text: ""
            anchors.top: phantomButton.bottom
            anchors.left: phantomInputRect.left
            anchors.topMargin: 15
            y:5
            color: "green"
            font.pointSize: 10
        }

        ListView{
            id: viewPhantomList
            visible: false

            anchors.left: phantomInputRect.left
            anchors.top: phantomName.bottom
            height: phantomButton.height
            width: 100

            orientation: ListView.Horizontal
            spacing: 2

            model: ListModel {
                ListElement{
                    name: "T1"
                }
                ListElement{
                    name: "T2"
                }
                ListElement{
                    name: "PD"
                }
            }

            delegate:    Button{
                            id:viewPhantomButton
                            height:25
                            width:25

                            background: Rectangle{
                                id: viewPhantomRect
                                anchors.fill:parent
                                color: viewPhantomButton.pressed? dark :"#595959"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                text: name
                                color: light
                                font.pointSize: 8
                            }

                            onClicked: {
                                 backend.plotPhantom(name);
                            }
                        }
        }

        FolderDialog{
            id: phantomDialog
            title: "Select Phantom Folder"

            currentFolder: "file:///home/pablov/Desktop/SeqSimulator/nifti_maps/"

            onAccepted:{
                phantomInput.text = this.selectedFolder;
                var phant = phantomInput.text.substring(7,phantomInput.text.length);
                phantomName.text = backend.loadPhantom(phant);
                viewPhantomList.visible = true;
            }
        }
    }
    */


    // CREATE GROUP
    // Rectangle{
    //     id: createGroupButton
    //     // visible:false

    //     property bool active: false

    //     width: window.mobile ? blockSeq.width : buttons.width
    //     anchors.left: blockSeq.left
    //     anchors.bottom: window.mobile ? blockSeq.bottom : defaultMenu.bottom

    //     anchors.topMargin: 15

    //     height: 31

    //     color: active? "gray": "#595959";

    //     Text{
    //         // id: buttonText
    //         anchors.centerIn: parent
    //         text: parent.active? "Done": "Create New Group"
    //         color: light
    //         font.pointSize: buttonTextSize
    //     }

    //     MouseArea{
    //         id: groupArea
    //         anchors.fill: parent
    //         hoverEnabled: true
    //         onClicked: {
    //             createGroupButton.active = !createGroupButton.active;

    //             if(createGroupButton.active){
    //                 groupDialog.open();
    //             }

    //             else{
    //                 var groupedBlocks = [];
    //                 for(var i = 0; i<blockList.count; i++){
    //                     if(blockList.get(i).grouped){
    //                         groupedBlocks.push(i);
    //                         blockList.get(i).grouped = false;
    //                     }
    //                 }

    //                 if(groupedBlocks.length <= 1){
    //                     console.log("Error: you must group at least 2 blocks");
    //                     return;

    //                 }else if(groupedBlocks.length > 1){
    //                     var numgroups = 0;

    //                     for(i=0; i<groupedBlocks.length; i++){
    //                         for(var j=0;j<blockList.count;j++){
    //                             for(var k=0;k<blockList.get(j).children.count;k++){
    //                                 // Check if the selected block already belongs to a group
    //                                 if (blockList.get(j).children.get(k).number===groupedBlocks[i] && i>0){
    //                                     numgroups = blockList.get(groupedBlocks[i]).ngroups;
    //                                     blockList.get(j).children.remove(k);
    //                                 }
    //                             }
    //                         }
    //                     }

    //                     for(j=0;j<blockList.count;j++){
    //                         for(k=0;k<blockList.get(j).children.count;k++){
    //                             // Check if there are more blocks that belong to an outter group but are not selected
    //                             if(j<getMinOfArray(groupedBlocks) && blockList.get(j).children.get(k).number>getMaxOfArray(groupedBlocks)){
    //                                 blockList.get(j).children.get(k).number++;
    //                             }
    //                         }
    //                     }

    //                     blockList.append({  "cod": 0,
    //                                         "dur":0,
    //                                         "gx":0,
    //                                         "gy":0,
    //                                         "gz":0,
    //                                         "gxStep":0,
    //                                         "gyStep":0,
    //                                         "gzStep":0,
    //                                         "b1x":0,
    //                                         "b1y":0,
    //                                         "delta_f":0,
    //                                         "fov":0,
    //                                         "n":0,
    //                                         "grouped":false,
    //                                         "ngroups":numgroups,
    //                                         "name":groupDialog.input,
    //                                         "children":[],
    //                                         "collapsed": false,
    //                                         "reps":1});

    //                     for(j=blockList.count-1;j>=0;j--){
    //                         // Check if there are groups more to the right (we must displace their children one step to the right)
    //                         if(j > (getMaxOfArray(groupedBlocks) + countChildren(getMaxOfArray(groupedBlocks))) && isGroup(j)){
    //                             moveGroup(j,1);
    //                         }
    //                     }

    //                     blockList.move(blockList.count-1,groupedBlocks[0],1);

    //                     for(i=0; i<groupedBlocks.length; i++){
    //                         blockList.get(groupedBlocks[0]).children.append({"number":groupedBlocks[i]+1});
    //                         addToGroup(groupedBlocks[i]+1);
    //                         configMenu.menuVisible = false;
    //                         blockSeq.displayedMenu = -1;
    //                     }
    //                 }
    //             }
    //         }
    //         states:
    //         [
    //             State{
    //                 when: groupArea.containsMouse
    //                 PropertyChanges{
    //                     target: createGroupButton
    //                     scale: 0.9
    //                 }
    //             }
    //         ]
    //     } // MouseArea
    // } // Rectangle ---------------------------------------------------------------------------------

    // Dialog{
    //     id: groupDialog
    //     property string input
    //     title: "Choose a name for the group"
    //     anchors.centerIn: window.center
    //     height: 200
    //     width: 400
    //     standardButtons: Dialog.Ok | Dialog.Cancel
    //     TextField{
    //         id: nameInput
    //         width: parent.width *0.75
    //         anchors.horizontalCenter: parent.horizontalCenter
    //     }
    //     onAccepted: {
    //         if (nameInput.text!=""){
    //             input = nameInput.text;
    //             nameInput.text = "";
    //         } else{
    //             createGroupButton.active = false;
    //             console.log("You must choose a name")
    //         }
    //     }
    //     onRejected: {
    //         createGroupButton.active = false;
    //     }
    // }


    // SIMULATE
    /*
    Timer {
        id: simTimer
        interval: 100 // Ajusta el tiempo de espera según tus necesidades
        onTriggered: {
            // sim();
            // plotSeq();
        }
    }

    function sim(){
        var sys = createScanner();
        var seq = createSeq();
        // var phant = phantomInput.text.substring(7,phantomInput.text.length);

        // backend.simulate(sys,seq);
    }

    Rectangle{
        id: simButton
        color: "#595959"
        height: createGroupButton.height
        anchors.top: createGroupButton.bottom
        anchors.left: createGroupButton.left
        anchors.right: createGroupButton.right
        anchors.topMargin: 10
        Text{
            anchors.centerIn: parent
            text: "Simulate"
            font.pointSize: buttonTextSize
            color: light
        }

        MouseArea{
            id: simArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
                //To simulate we need 3 inputs: a Scanner (with global parameters), a Sequence and a Phantom
                if(blockList.count>0){
                    if (phantomName.text !== ""){
                        loadingRect.visible = true;
                        simTimer.start();
                    } else {
                        console.log("ERROR: Please, select a valid phantom to simulate")
                    }
                }else{
                    console.log("ERROR: The sequence is empty");
                }
            }
            states:
            [
                State{
                    when: simArea.containsMouse
                    PropertyChanges{
                        target: simButton
                        scale: 0.9
                    }
                }
            ]
        }
    }
    */


    // SAVE SEQUENCE
    /*
    Rectangle{
        id: saveSeqButton
        color: simButton.color
        height: createGroupButton.height
        anchors.top: simButton.bottom
        anchors.left: createGroupButton.left
        anchors.right: createGroupButton.right
        anchors.topMargin: 10
        Text{
            anchors.centerIn: parent
            text: "Save Sequence"
            font.pointSize: buttonTextSize
            color: light
        }
        MouseArea{
            id: saveSeqArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                saveDialog.visible = true;
            }
            states:
            [State{
                when: saveSeqArea.containsMouse
                PropertyChanges{
                    target: saveSeqButton
                    scale: 0.9
                }
            }]
        }

        FileDialog {
            id:saveDialog
            nameFilters: ["QML File (*.qml)","All Files (*)"]

            fileMode: FileDialog.SaveFile
            currentFolder: "file:///home/pablov/Desktop/Editor/Sequences"

            onAccepted: {
                var array = saveSeq();
                backend.saveSeq(array,seqDescription.text,saveDialog.selectedFile);
                console.log(saveDialog.selectedFile);
            }
            onRejected: {
                console.log("Canceled")
            }
        }
    }
    */


    // LOAD SEQUENCE
    /*
    Rectangle{
        id: loadSeqButton
        color: simButton.color
        height: createGroupButton.height
        anchors.top: saveSeqButton.bottom
        anchors.left: createGroupButton.left
        anchors.right: createGroupButton.right
        anchors.topMargin: 10
        Text{
            anchors.centerIn: parent
            text: "Load Sequence"
            font.pointSize: buttonTextSize
            color: light
        }
        MouseArea{
            id: loadSeqArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                loadDialog.visible = true;
            }
            states:
            [State{
                when: loadSeqArea.containsMouse
                PropertyChanges{
                    target: loadSeqButton
                    scale: 0.9
                }
            }]
        }

        FileDialog {
            id:loadDialog
            nameFilters: ["QML File (*.qml)"]
            // currentFolder: "file:///home/pablov/Desktop/SeqSimulator/Sequences"

            onAccepted: {
                modelLoader.source = loadDialog.selectedFile;
                blockList.clear();
                configMenu.menuVisible = false;
                for(var i=0; i<modelLoader.item.count; i++){
                    blockList.append(modelLoader.item.get(i));
                }
                if(typeof modelLoader.item.seqDescription !== 'undefined'){
                    seqDescription.text = modelLoader.item.seqDescription;
                }
            }
            onRejected: {
                console.log("Canceled")
            }
        }
    }
    */



    // DISPLAY OUTPUT IMAGES
    /*
    Rectangle{
        id: resultRect
        anchors.top: loadSeqButton.bottom
        anchors.left: defaultMenu.right
        anchors.right: loadSeqButton.right
        anchors.bottom: parent.bottom

        anchors.bottomMargin: 15
        anchors.topMargin: 15
        anchors.leftMargin: 15

        color: "transparent"

        //DISPLAY RECON IMAGE
        Rectangle{
            id: reconRect
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: "gray"

            width: (parent.width/2) - 5

            Text {
                y:5
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Reconstruction"
                font.pointSize: 12
            }

            Image{
                id: recon
                anchors.fill: parent
                anchors.margins: 5
                anchors.topMargin: 30
                smooth: false
                cache: false
            }
        }

        //DISPLAY K-SPACE
        Rectangle{
            id: kspaceRect
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: "gray"

            width: (parent.width/2) - 5

            Text {
                y:5
                anchors.horizontalCenter: parent.horizontalCenter
                text: "K-Space"
                font.pointSize: 12
            }

            Image{
                id: kspace
                anchors.fill: parent
                anchors.margins: 5
                anchors.topMargin: 30
                smooth: false
                cache: false
            }
        }
    }
    */
}
