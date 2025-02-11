import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: window

    // WINDOW SIZE
    property int desktopWidth: 1500
    property int mobileWidth: 840

    property int desktopHeight: 450
    property int tabletHeight: 870
    property int mobileHeight: 2000

    property bool desktop: width>=desktopWidth
    property bool tablet: width >= mobileWidth & width < desktopWidth
    property bool mobile: width<mobileWidth

    // COLORS
    property string dark_1: "#212529"
    property string dark_2: "#303336"
    property string dark_3: "#525252"
    property string light:  "#d8e0e8"

    // CONFIGURATION PANEL (THIS IS THE PANEL WITH OPTIONS FOR EACH BLOCK)
    property int fieldWidth: 60
    property int fieldHeight: 20
    property int fontSize: 8

    // RIGHT BUTTONS
    property int buttonTextSize: 10

    // WINDOW RADIUS
    property int radius: window.mobile ? 2 : 6

    width:  desktopWidth;
    height: desktop ? desktopHeight :
            tablet ? tabletHeight :
            mobile ? mobileHeight :
            500

    color: dark_1
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

    // function addGroup() adds a group (created by the user) to the groupList
    function addGroup(menuTitle,blockID){
        groupButtonList.append({"buttonText": menuTitle, "code": (blockButtonList.count + groupButtonList.count)+1, "iconSource":"qrc:/icons/light/misc.png"});

        var group_cod;
        var num_groups = blockList.get(blockID).ngroups;
        var count = groupList.count;
        var childrenList;

        for(var j=0; j<=countChildren(blockID); j++){
            childrenList = [];

            if(j==0){
                group_cod = blockButtonList.count + groupButtonList.count;
            } else {
                group_cod = -1;
            }

            if(isGroup(blockID+j)){
                var num = blockList.get(blockID+j).children.count;
                for(var i=0;i<num;i++){
                    childrenList.push( blockList.get(blockID+j).children.get(i).number + (count-blockID) );
                }
            }

            var code = blockList.get(blockID+j).cod

            var durationActive =    [1,2,3,4].includes(code);
            var linesActive =       [5,6].includes(code);
            var samplesActive =     [4,5,6].includes(code);
            var adcDelayActive =    [4].includes(code);
            var fovActive =         [5,6].includes(code);
            var rfActive =          [1,6].includes(code);
            var gradientsActive =   [1,3,4].includes(code);
            var tActive =           [6].includes(code);
            var groupActive =       [0].includes(code);

            groupList.append(  {"group_cod":group_cod,
                                "cod":code,
                                "name":blockList.get(blockID+j).name,
                                "ngroups":blockList.get(blockID+j).ngroups - num_groups,
                                "children":[],
                                "rf": [],
                                "gradients": [],
                                "t": []});

            if(durationActive)  {groupList.setProperty(groupList.count-1,           "duration",     blockList.get(blockID+j).duration);}
            if(linesActive)     {groupList.setProperty(groupList.count-1,           "lines",        blockList.get(blockID+j).lines);}
            if(samplesActive)   {groupList.setProperty(groupList.count-1,           "samples",      blockList.get(blockID+j).samples);}
            if(adcDelayActive)  {groupList.setProperty(groupList.count-1,           "adcDelay",     blockList.get(blockID+j).adcDelay);}
            if(fovActive)       {groupList.setProperty(groupList.count-1,           "fov",          blockList.get(blockID+j).fov);}
            if(rfActive)        {groupList.get(groupList.count-1).rf.append(       {"select":       blockList.get(blockID+j).rf.get(0).select,
                                                                                    "shape":        blockList.get(blockID+j).rf.get(0).shape,
                                                                                    "b1Module":     blockList.get(blockID+j).rf.get(0).b1Module,
                                                                                    "flipAngle":    blockList.get(blockID+j).rf.get(0).flipAngle,
                                                                                    "deltaf":       blockList.get(blockID+j).rf.get(0).deltaf});
                                }
            if(gradientsActive) {groupList.get(groupList.count-1).gradients.append({"axis":         "x",
                                                                                    "delay":        blockList.get(blockID+j).gradients.get(0).delay,
                                                                                    "rise":         blockList.get(blockID+j).gradients.get(0).rise,
                                                                                    "flatTop":      blockList.get(blockID+j).gradients.get(0).flatTop,
                                                                                    "amplitude":    blockList.get(blockID+j).gradients.get(0).amplitude,
                                                                                    "step":         blockList.get(blockID+j).gradients.get(0).step});
                                 groupList.get(groupList.count-1).gradients.append({"axis":         "y",
                                                                                    "delay":        blockList.get(blockID+j).gradients.get(1).delay,
                                                                                    "rise":         blockList.get(blockID+j).gradients.get(1).rise,
                                                                                    "flatTop":      blockList.get(blockID+j).gradients.get(1).flatTop,
                                                                                    "amplitude":    blockList.get(blockID+j).gradients.get(1).amplitude,
                                                                                    "step":         blockList.get(blockID+j).gradients.get(1).step});
                                 groupList.get(groupList.count-1).gradients.append({"axis":         "z",
                                                                                    "delay":        blockList.get(blockID+j).gradients.get(2).delay,
                                                                                    "rise":         blockList.get(blockID+j).gradients.get(2).rise,
                                                                                    "flatTop":      blockList.get(blockID+j).gradients.get(2).flatTop,
                                                                                    "amplitude":    blockList.get(blockID+j).gradients.get(2).amplitude,
                                                                                    "step":         blockList.get(blockID+j).gradients.get(2).step});}
            if(tActive)         {groupList.get(groupList.count-1).t.append(        {"te":           blockList.get(blockID+j).t.get(0).te,
                                                                                    "tr":           blockList.get(blockID+j).t.get(0).tr});}
            if(groupActive)     {groupList.setProperty(groupList.count-1,           "repetitions",  blockList.get(blockID+j).repetitions);}

            for(i=0;i<childrenList.length;i++){
                groupList.get(groupList.count-1).children.append({"number":childrenList[i]})
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

        array[0] = Number(scannerMenu.b0);
        array[1] = Number(scannerMenu.b1);
        array[2] = Number(scannerMenu.deltat);
        array[3] = Number(scannerMenu.gmax);
        array[4] = Number(scannerMenu.smax);

        // print("Scanner: ", array);

        return array;
    }

    // Function seqToJSON()
    function seqToJSON(){
        var description = seqDescription.text;
        var datamodel = { "description": description, "blocks": [] };

        for (var i = 0; i < blockList.count; ++i) {
            datamodel.blocks.push(blockList.get(i));
        }

        var datastore = JSON.stringify(datamodel);
        return datastore;
    }

    // Function scannerToJSON()
    function scannerToJSON(){
        var datamodel = { "b0":     Number(scannerMenu.b0),
                          "b1":     Number(scannerMenu.b1),
                          "deltat": Number(scannerMenu.deltat),
                          "gmax":   Number(scannerMenu.gmax),
                          "smax":   Number(scannerMenu.smax) };
        var datastore = JSON.stringify(datamodel);
        return datastore;
    }

    // Function saveSeq()
    function saveSeq(extension){
        var datastore = seqToJSON();
        backend.getDownloadSequence(datastore,extension);
    }

    // Function saveScanner()
    function saveScanner(){
        var datastore = scannerToJSON();
        backend.getDownloadScanner(datastore);
    }

    // Function plotSeq()
    function plotSeq(){
        var scanstore = scannerToJSON();
        var seqstore = seqToJSON();
        backend.plotSequence(scanstore, seqstore);
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
    ListModel{ id:blockList }

    ListModel{ id:groupList }

    // In this loader we will store the loaded sequence from a previously saved file
    Loader{ id: modelLoader }
    // -----------------------------------------------------------------------------------------

    Rectangle {
        id:menuBar
        anchors.top: parent.top
        width: parent.width
        height: 20

        color: "gray"

        Row{
            anchors.fill: parent
            Button {
                id: fileButton
                text: "File"
                font.pointSize: 10
                height: parent.height
                width: 20 * text.length
                z: 20
                background: Rectangle {
                    color: light
                }

                onClicked: menuFile.open()

                Menu {
                    id: menuFile
                    y: fileButton.height
                    font.pointSize: 10

                    Menu {
                        title: "Sequence"
                        font.pointSize: 10
                        Action {
                            text: "New Sequence"
                        }
                        Action {
                            text: "Load Sequence"
                            onTriggered: backend.getUploadSequence();
                        }

                        Menu {
                            title: "Save Sequence"
                            font.pointSize: 10
                            Action {
                                text: ".json"
                                onTriggered: saveSeq("json");
                            }
                            Action {
                                text: ".qml"
                                onTriggered: saveSeq("qml");
                            }
                        }
                    }

                    Menu {
                        title: "Scanner"
                        font.pointSize: 10
                        Action {
                            text: "Load Scanner"
                            onTriggered: backend.getUploadScanner();
                        }

                        Action {
                            text: "Save Scanner"
                            onTriggered: saveScanner();
                        }
                    }
                }

                states: [
                    State{
                        when: fileButton.hovered
                        PropertyChanges {
                            target: fileButton.background
                            color: Qt.darker(light, 1.3)
                        }
                    }
                ] // states
            }
            Button {
                id: plotButton
                text: "Plot"
                font.pointSize: 10
                height: parent.height
                width: 20 * text.length
                z: 20
                background: Rectangle {
                    color: light
                }

                onClicked: menuPlot.open()

                Menu {
                    id: menuPlot
                    y: plotButton.height
                    font.pointSize: 10

                    Action {
                        text: "Sequence Diagram"
                        onTriggered: plotSeq();
                    }
                }

                states: [
                    State{
                        when: plotButton.hovered
                        PropertyChanges {
                            target: plotButton.background
                            color: Qt.darker(light, 1.3)
                        }
                    }
                ] // states
            }
        }
    }


    Connections {
        target: backend
        function onUploadSequenceSelected(path) {
            modelLoader.source = path
            blockList.clear();
            seqDescription.text = modelLoader.item.description;
            configMenu.menuVisible = false;
            for(var i=0; i<modelLoader.item.count; i++){
                blockList.append(modelLoader.item.get(i));
                if(isChild(i)){
                    blockList.get(i).collapsed = true;
                } else {
                    blockList.get(i).collapsed = false;
                }
            }
        }

        function onUploadScannerSelected(path) {
            modelLoader.source = path
            scannerMenu.b0      = modelLoader.item.b0
            scannerMenu.b1      = modelLoader.item.b1
            scannerMenu.deltat  = modelLoader.item.deltat
            scannerMenu.gmax    = modelLoader.item.gmax
            scannerMenu.smax    = modelLoader.item.smax
        }
    }


    Flickable{
        anchors.top: menuBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        contentHeight: mobile ? mobileHeight :
                       tablet ? tabletHeight :
                       desktop ? desktopHeight :
                       500
        contentWidth: window.width
        boundsBehavior: Flickable.StopAtBounds

        clip:true

        /*
        Text{
            id: textDim
            color: "white"
            text: "Window: " + window.width + " x " + window.height
        }
        */

        // SEQUENCE
        RectangularGlow {
            id: seqGlow
            visible: popup.visible
            anchors.fill: blockSeq
            glowRadius: 10
            spread: 0.2
            color: light
            cornerRadius: window.radius + glowRadius
        }

        MouseArea{
            id: blockSeq
            x:  window.mobile ? 4 : 25
            y:  15

            height: 132
            width: window.mobile ? window.width - 8 : window.width - 50

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
                id: seqRect
                color: dark_2
                anchors.fill: parent

                radius: window.radius

                // SEQUENCE TITLE
                Item {
                    id: seqTitle

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top:parent.top
                    height:25

                    Text {
                        anchors.top: parent.top;
                        anchors.left: parent.left;
                        anchors.topMargin:10
                        anchors.leftMargin:12

                        text: "Block sequence"
                        font.pointSize: 11

                        color: light
                    }
                }

                ListView {
                    id: blockView

                    property int dragIndex // Index of the block that we are dragging
                    property bool held: false // Tells us is we are dragging a block or not

                    anchors.fill: parent
                    anchors.topMargin: seqTitle.height + 3
                    interactive: true

                    orientation: ListView.Horizontal

                    clip: true

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

        Rectangle {
            visible: popup.visible
            color: dark_1
            opacity: 0.7
            anchors.top:blocksMenu.top
            z: 18
            height: window.height - (blockSeq.height + blockSeq.y)
            width: window.width
        }

        property int lineThickness: 1

        Component{
            id: verticalLine
            Rectangle{
                width: window.lineThickness
                color:dark_3
            }
        }

        Component{
            id: horizontalLine
            Rectangle{
                height: window.lineThickness
                color:dark_3
            }
        }


        // This list stores information about the available "basic" blocks
        ListModel {
            id: blockButtonList
            ListElement { buttonText: "Excitation";     code: 1;    iconSource:"qrc:/icons/light/rf.png" }
            ListElement { buttonText: "Delay";          code: 2;    iconSource:"qrc:/icons/light/clock.png"  }
            ListElement { buttonText: "Dephase";        code: 3;    iconSource:"qrc:/icons/light/angle.png"  }
            ListElement { buttonText: "Readout";        code: 4;    iconSource:"qrc:/icons/light/readout.png"  }
            ListElement { buttonText: "EPI_ACQ";        code: 5;    iconSource:"qrc:/icons/light/epi.png"  }
            ListElement { buttonText: "GRE";            code: 6;    iconSource:"qrc:/icons/light/misc.png"  }
        }

        // This list stores information about the groups stored as duplicatable blocks
        ListModel {
            id: groupButtonList
        }

        // This list stores information about the global variables that can be defined and used to create the sequence
        ListModel {
            id: variableList
            ListElement { name: "gamma";  value: 42.85e6; readonly: true }
        }

        // ADD BLOCKS
        ButtonsMenu {
            id: blocksMenu
            anchors.top: blockSeq.bottom; anchors.topMargin:15
            anchors.left: blockSeq.left
            width: window.mobile ? blockSeq.width/2 - 2 : 130
            height: window.mobile ? 200 : 280

            title: "Add blocks"
            group: false
        }

        // ADD GROUPS
        ButtonsMenu {
            id: groupsMenu
            anchors.top: blocksMenu.top
            anchors.left: blocksMenu.right
            anchors.leftMargin: window.mobile ? 4 : 15
            width: blocksMenu.width
            height: blocksMenu.height

            title: "Groups"
            group: true
        }

        PopUp {
            id: popup
            text: "Click on the blocks you want to group and give a name to the group:"
            x: blockSeq.width/2 - width/2
            y: blockSeq.y + blockSeq.height + seqGlow.glowRadius
        }

        // BLOCK CONFIGURATION PANEL
        Rectangle{
            id: defaultMenu

            anchors.left: window.mobile ? blockSeq.left : groupsMenu.right
            anchors.leftMargin: window.mobile ? 0 : 15;

            anchors.top: window.mobile ? blocksMenu.bottom : blockSeq.bottom;
            anchors.topMargin: 15

            width: window.mobile ? blockSeq.width : 500
            height: 280
            z: 15

            color: dark_2
            radius: window.radius

            Text{
                anchors.centerIn: parent
                text: "Click on a block to display its menu"
                font.pointSize: 10
                color: light
            }

            BlockMenu{
                id: configMenu
                anchors.fill: parent
            }
        }

        // SCANNER PARAMETERS PANEL
        ScannerMenu{
            id: scannerMenu
            visible: true

            anchors.left: window.desktop ? defaultMenu.right : blockSeq.left
            anchors.top: window.desktop ? blockSeq.bottom : (window.mobile ? defaultMenu.bottom : blocksMenu.bottom)
            anchors.leftMargin: window.desktop ? 15 : 0
            anchors.topMargin: 15

            width: window.mobile ? blockSeq.width : (window.tablet ? 2*blocksMenu.width + 15 : 265)
            height: 155
            z: 15

            radius: window.radius

            // Default parameters
            b0: "1.5"
            b1: "10e-6"
            deltat: "2e-6"
            gmax: "60e-3"
            smax: "500"
        }

        // GLOBAL VARIABLES PANEL
        VariablesMenu{
            id: variablesMenu
            visible: true

            anchors.left:  window.mobile ? scannerMenu.left   : scannerMenu.right; anchors.leftMargin: window.mobile ? 0 : 15
            anchors.right: window.tablet ? defaultMenu.right  : blockSeq.right
            anchors.top:   window.mobile ? scannerMenu.bottom : (window.tablet ? defaultMenu.bottom : blockSeq.bottom); anchors.topMargin: 15
            
            height: scannerMenu.height

            radius: window.radius
        }

        // SEQUENCE DESCRIPTION
        Rectangle{
            id:descriptionRect

            anchors.top:    window.tablet ? blockSeq.bottom : variablesMenu.bottom;  anchors.topMargin: 15
            anchors.left:   window.tablet ? defaultMenu.right : scannerMenu.left;    anchors.leftMargin: window.tablet ? 15 : 0
            anchors.right:  blockSeq.right;

            height: window.desktop ? defaultMenu.height - 15 - scannerMenu.height : (window.mobile ? defaultMenu.height : defaultMenu.height + 15 + scannerMenu.height)

            radius: window.radius
            color: dark_2

            Text{
                id: descriptionTitle
                text: "Sequence Description"
                font.pointSize: 10
                anchors.top: parent.top;   anchors.topMargin: 12
                anchors.left: parent.left; anchors.leftMargin:12
                color: "white"
            }

            ScrollView {
                id: descriptionView

                anchors.top:descriptionTitle.bottom; anchors.topMargin: 5
                anchors.bottom:parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left

                TextArea {
                    id: seqDescription
                    color: light
                    font.family: "Consolas"
                    text: "Write Here\n...\n...\n...\n"
                    font.pointSize: 10
                    wrapMode: TextEdit.Wrap
                }
            }
        }
    } // Flickable
} // ApplicationWindow

