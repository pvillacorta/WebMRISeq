import QtQuick

ListModel{
    // Example blocks
    ListElement{
        cod: 1
        name: ""
        collapsed: false
        ngroups: 0
        children:[]
        grouped: false
        duration: 1
        rf: [
            ListElement{
                shape: 1
                b1Module: 1e-3
                flipAngle: 10
                deltaf: 0
            }
        ]
        gradients: [
            ListElement{
                axis: "x"
                delay: 0.1234
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            },
            ListElement{
                axis: "y"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            },
            ListElement{
                axis: "z"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            }
        ]
    }
    ListElement{
        cod: 2
        name: ""
        collapsed: false
        ngroups: 0
        children:[]
        grouped: false
        duration: 1
    }
    ListElement{
        cod: 3
        name: ""
        collapsed: false
        ngroups: 0
        children:[]
        grouped: false
        duration: 1
        gradients:[
            ListElement{
                axis: "x"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            },
            ListElement{
                axis: "y"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            },
            ListElement{
                axis: "z"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            }
        ]
    }
    ListElement{
        cod: 4
        name: ""
        collapsed: false
        ngroups: 0
        children:[]
        grouped: false
        duration: 1
        samples: 32
        gradients:[
            ListElement{
                axis: "x"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            },
            ListElement{
                axis: "y"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            },
            ListElement{
                axis: "z"
                delay: 0.1
                rise: 0.1
                flatTop: 0.2
                amplitude: 1e-3
                step: 1e-4
            }
        ]
    }
    ListElement{
        cod: 5
        name: ""
        collapsed: false
        ngroups: 0
        children:[]
        grouped: false
        lines: 32
        samples: 32
        fov: 0.1
    }
    ListElement{
        cod: 6
        name: ""
        collapsed: false
        ngroups: 0
        children:[]
        grouped: false
        rf: [
            ListElement{
                shape: 0
                b1Module: 1e-3
                flipAngle: 10
                deltaf: 0
            }
        ]
        lines: 32
        samples: 32
        fov: 0.1
        t:[
            ListElement{
                te: 20e-3
                tr: 100e-3
            }
        ]
    }
}

