import QtQuick
import QtQuick.Controls

Item{
    property alias menuTitle: menuTitle
    property string title

    property int buttonX: groupMenu.x + groupButton.x + 6
    property int buttonY: groupMenu.y + groupButton.y + groupButton.height

    property bool group

    Rectangle{
        id: buttons
        anchors.fill: parent
        color: dark_2
        radius:window.radius


        Item{
            id: menuTitle
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: window.mobile ? 25 : 35

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

                visible: group
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
                    popup.nameInput.forceActiveFocus();
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
                clip:true
                model: group ? groupButtonList : blockButtonList
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
                            width: 15
                            height: width
                        }
                        Text{
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: icon.right; anchors.leftMargin: 10
                            color: light
                            text: buttonText
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: buttonArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            blockSeq.displayedMenu = -1;
                            // Default values ------
                            var duration = 1e-3;
                            var lines = 64;
                            var samples = 64;
                            var fov = 0.1;
                            var shape = 0;
                            var b1Module = 1e-6;
                            var flipAngle = 10;
                            var deltaf = 0;
                            var te = 20e-3;
                            var tr = 100e-3;
                            var repetitions = 1;
                            var gDelay = 0;
                            var gRise = 1e-4;
                            var gFlatTop = 1e-3;
                            var gAmplitude = 1e-5;
                            var gStep = 0;
                            // ------------------

                            var durationActive =    code in [1,2,3,4];
                            var rfActive =          code in [1,6];
                            var gradientsActive =   code in [1,3,4];
                            var linesActive =       code in [5,6];
                            var samplesActive =     code in [4,5,6];
                            var fovActive =         code in [5,6];
                            var groupActive =       code in [0];
                            var tActive =           code in [6];

                            if(code<=blockButtonList.count){
                                blockList.append({
                                                "cod": code,
                                                "name": "",
                                                "collapsed": false,
                                                "ngroups": 0,
                                                "children":[],
                                                "grouped": false,
                                                "duration": duration,
                                                "rf": [],
                                                "gradients": []
                                                });
                            } else if(code>blockButtonList.count){
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
                                                        "repetitions":groupList.get(index).repetitions});

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

