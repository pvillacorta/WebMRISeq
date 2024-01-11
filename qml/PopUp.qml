import QtQuick
import QtQuick.Controls


Item {
    id: popup

    property alias text: label.text
    property bool active: false

    property int textSize: 8

    function closePopUp(){
        popup.visible = false
        popup.active = false
        nameInput.text = "";
        nameRect.color = "white";
        log.text = ""
    }

    visible: false
    width: 200
    height: 150
    z: 20
    Image {
        anchors.fill: parent
        source: "/icons/balloon.png"
    }

    Column {
        id: column
        anchors.fill: parent
        anchors.margins: 25
        Text {
            id: label

            anchors.left: parent.left
            anchors.right: parent.right

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            wrapMode: Text.WordWrap
            font.pointSize: popup.textSize
        }

        Item{
            width: 1
            height: 15
        }

        Rectangle{
            id: nameRect
            anchors.left: parent.left
            anchors.right: parent.right
            height: 20
            border.width: 1
            border.color: "gray"
            color: "white"
            TextInput {
                id: nameInput
                anchors.fill:parent
                anchors.margins:3
            }
        }

        Text{
            id: log
            anchors.left: parent.left
            anchors.right: parent.right
            color: "red"
            wrapMode: Text.WordWrap
            font.pointSize: popup.textSize
        }
    }


    //Delete button
    DeleteButton {
        function clicked(){
            closePopUp();
            for(var i = 0; i<blockList.count; i++){
                if(blockList.get(i).grouped){
                    blockList.get(i).grouped = false;
                }
            }
        }

        y: 12
        anchors.right: parent.right

        anchors.margins:3

        height: 15
        width: 15

        color: Qt.darker(light,1.3)
    }

    //Done button
    Button {
        id: doneButton
        text: "Done"
        font.pointSize: popup.textSize

        height:20
        width:50
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 5

        background: Rectangle {
            color: Qt.darker(light,1.3)
        }

        onClicked: {
            var groupedBlocks = [];
            var counter = 0;
            var lastGrouped = -1;
            var blockID = -1;
            for(var i = 0; i<blockList.count; i++){
                if(blockList.get(i).grouped){
                    if (counter != 0){
                        if ((i - lastGrouped) > 1 & !isGroup(lastGrouped)){
                            log.text = "All selected blocks must be adjacent"
                            return;
                        }
                    }else{
                        blockID = i;
                    }
                    groupedBlocks.push(i);
                    lastGrouped = i;
                    counter++;
                }
            }

            if(nameInput.text === ""){
                nameRect.color = "#fc8383"
                log.text = "No name specified"
                return;
            }

            for(var i=0; i<groupButtonList.count; i++){
                if(groupButtonList.get(i).buttonText === nameInput.text){
                    nameRect.color = "#fc8383"
                    log.text = "This name already exists"
                    return;
                }
            }

            if(groupedBlocks.length <= 1){
                log.text="You must group at least 2 blocks";
                return;

            }else if(groupedBlocks.length > 1){
                for(var i = 0; i<blockList.count; i++){
                    blockList.get(i).grouped = false;
                }

                var numgroups = 0;

                for(i=0; i<groupedBlocks.length; i++){
                    for(var j=0;j<blockList.count;j++){
                        for(var k=0;k<blockList.get(j).children.count;k++){
                            // Check if the selected block already belongs to a group
                            if (blockList.get(j).children.get(k).number===groupedBlocks[i] && i>0){
                                numgroups = blockList.get(groupedBlocks[i]).ngroups;
                                blockList.get(j).children.remove(k);
                            }
                        }
                    }
                }

                for(j=0;j<blockList.count;j++){
                    for(k=0;k<blockList.get(j).children.count;k++){
                        // Check if there are more blocks that belong to an outter group but are not selected
                        if(j<getMinOfArray(groupedBlocks) && blockList.get(j).children.get(k).number>getMaxOfArray(groupedBlocks)){
                            blockList.get(j).children.get(k).number++;
                        }
                    }
                }

                blockList.append({  "cod": 0,
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
                                    "ngroups":numgroups,
                                    "name": nameInput.text,
                                    "children":[],
                                    "collapsed": false,
                                    "reps":1});

                for(j=blockList.count-1;j>=0;j--){
                    // Check if there are groups more to the right (we must displace their children one step to the right)
                    if(j > (getMaxOfArray(groupedBlocks) + countChildren(getMaxOfArray(groupedBlocks))) && isGroup(j)){
                        moveGroup(j,1);
                    }
                }

                blockList.move(blockList.count-1,groupedBlocks[0],1);

                for(i=0; i<groupedBlocks.length; i++){
                    blockList.get(groupedBlocks[0]).children.append({"number":groupedBlocks[i]+1});
                    addToGroup(groupedBlocks[i]+1);
                    configMenu.menuVisible = false;
                    blockSeq.displayedMenu = -1;
                }

                addGroup(nameInput.text, blockID);
                closePopUp();
            }
        }
    } //Button
}
