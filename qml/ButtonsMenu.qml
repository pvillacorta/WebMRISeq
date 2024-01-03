import QtQuick
import QtQuick.Controls

Item{
    property string title

    property alias model: buttonView.model
    property alias menuTitle: menuTitle

    property int buttonX: groupMenu.x + groupButton.x + 6
    property int buttonY: groupMenu.y + groupButton.y + groupButton.height

    Rectangle{
        id: buttons
        anchors.fill: parent
        color: dark_2
        radius:window.radius


        Rectangle{
            id: menuTitle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: window.mobile ? 25 : 35

            color: dark_2

            radius:window.radius

            z: 10

            Text {
                id: name
                text: title
                color:light
                font.pointSize: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin:12
            }

            Button {
                id: groupButton

                visible: model == groupButtonList
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                height: 20
                width: 20

                background: Rectangle{
                    anchors.fill:parent
                    color: groupButton.pressed? dark_1 : dark_3
                    radius: 2
                }

                contentItem: Image{
                    anchors.fill: parent
                    anchors.margins: 3
                    source: "/icons/light/plus.png"
                }

                scale: hovered? 0.9: 1

                onClicked: {
                    popup.visible = true
                    popup.active = true
                }
            }

            Loader{
                sourceComponent: horizontalLine
                width: parent.width - 20
                anchors.bottom: parent.bottom
                z:15
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }


        MouseArea{
            anchors.top: menuTitle.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            ListView {
                id: buttonView
                anchors.fill: parent
                orientation: ListView.Vertical

                delegate: Button{
                    id: button
                    parent: buttonView

                    height:40
                    width:parent.width

                    display: AbstractButton.TextBesideIcon

                    background : Rectangle{
                        id: bgButton
                        color: "transparent"
                    }

                    contentItem: Item {
                        anchors.fill: parent
                        anchors.margins: 10
                        Image{
                            id: icon
                            anchors.verticalCenter: parent.verticalCenter
                            source:iconSource
                            width: 20
                            height: width
                        }
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: icon.right; anchors.leftMargin: 10
                            color: light
                            text: buttonText
                        }
                    }

                    MouseArea {
                        id: buttonArea
                        hoverEnabled: true
                        anchors.fill: parent
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

                            for (var j=1; j<100; j++){
                               scrollBar.increase();
                            }
                        }

                        states: [
                            State{
                                when: buttonArea.pressed
                                PropertyChanges{
                                    target: bgButton
                                    color: dark_1
                                }
                            },
                            State{
                                when: buttonArea.containsMouse
                                PropertyChanges{
                                    target: bgButton
                                    color: dark_3
                                }
                            }
                        ]
                    }
                }
            } // ListView
        } // MouseArea
    }
}

