import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    visible: shown || clipper.height > 0
    anchors.top: true
    margins.top: Theme.padding + Theme.barHeight
    exclusionMode: ExclusionMode.Ignore
//    exclusiveZone: 0

    implicitWidth: 540
    readonly property int tether: Theme.padding * 2
    readonly property int panelHeight: 300

    implicitHeight: tether + panelHeight
    color: "transparent"

    readonly property bool shown: ControlState.shown

    mask: Region { item: clipper }

    IpcHandler {
        target: "control"
        function toggle(): void { root.shown = !root.shown } 
    }
    Item {
        id: clipper
        clip: true
        width: root.implicitWidth
        height: root.shown ? root.implicitHeight : 0

        Rectangle {
            x: Math.round(parent.width / 2)
            width: Theme.borderWidth
            height: root.tether
            color: Theme.borderColor
        }
        Rectangle {
            y: root.tether
            implicitWidth: root.implicitWidth
            implicitHeight: root.panelHeight
            color: Theme.background
            radius: Theme.radius
        }
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.tether
            color: "transparent"
            border.color: Theme.borderColor
            border.width: Theme.borderWidth
            radius: Theme.radius
        
        }
        Behavior on height {
            NumberAnimation {
                duration: 750
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.2, 0.8, 0.2, 1, 1, 1]
            }
        }
    }


}
