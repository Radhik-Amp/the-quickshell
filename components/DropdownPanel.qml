import qs.config
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

// Shared frame for dropdown panels hanging off the bar: slide-down clip,
// tether line, background, border, and Escape-to-close. Open state comes
// from Panels.active === name. Children are laid out in a ColumnLayout.
PanelWindow {
    id: root

    required property string name
    readonly property bool shown: Panels.active === name

    // Screen x the tether points at. NaN = horizontally centered.
    property real anchorX: NaN
    readonly property bool anchored: !isNaN(anchorX)
    property int focusMode: WlrKeyboardFocus.OnDemand

    default property alias content: column.data
    property alias spacing: column.spacing

    readonly property int tether: Theme.padding
    readonly property int panelHeight: column.implicitHeight + Theme.padding * 2
    readonly property real screenWidth: screen?.width ?? 0

    implicitHeight: tether + panelHeight
    visible: shown || clipper.height > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: anchored
    margins.top: Theme.padding + Theme.barHeight
    margins.left: anchored
        ? Math.round(Math.max(Theme.padding,
            Math.min(anchorX - implicitWidth / 2, screenWidth - implicitWidth - Theme.padding)))
        : 0

    mask: Region { item: clipper }

    WlrLayershell.keyboardFocus: shown ? focusMode : WlrKeyboardFocus.None

    Item {
        id: clipper
        clip: true
        width: root.implicitWidth
        height: root.shown ? root.implicitHeight : 0
        focus: true
        Keys.onEscapePressed: Panels.close()

        Behavior on height {
            NumberAnimation {
                duration: 650
                easing.type: Easing.Bezier
                easing.bezierCurve: [0.2, 0.8, 0.2, 1, 1, 1]
            }
        }

        Rectangle {
            x: Math.round(root.anchored ? root.anchorX - root.margins.left : parent.width / 2)
            width: Theme.borderWidth
            height: root.tether
            color: Theme.borderColor
        }

        Rectangle {
            y: root.tether
            width: root.implicitWidth
            height: root.panelHeight
            color: Theme.background
            radius: Theme.radius

            ColumnLayout {
                id: column
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Theme.padding
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: root.tether
            color: "transparent"
            border.color: Theme.borderColor
            border.width: Theme.borderWidth
            radius: Theme.radius
        }
    }
}
