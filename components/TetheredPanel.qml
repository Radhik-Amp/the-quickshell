import qs.config
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    // Panel frame tethered to the bar, or to the screen edge with edgeReveal, opened via Panels.active.

    required property string name
    readonly property bool shown: Panels.active === name

    // Screen x the panel centers under. NaN = horizontally centered.
    property real anchorX: NaN
    readonly property bool anchored: !isNaN(anchorX)
    property int focusMode: WlrKeyboardFocus.OnDemand
    required property int panelWidth

    default property alias content: column.data
    property alias spacing: column.spacing

    readonly property int tether: Theme.padding
    readonly property int panelHeight: column.implicitHeight + Theme.padding * 2
    readonly property real screenWidth: screen?.width ?? 0

    readonly property real idealLeft: anchorX - panelWidth / 2
    readonly property real panelLeft: Math.round(Math.max(Theme.padding, Math.min(idealLeft, screenWidth - panelWidth - Theme.padding)))
    readonly property string pinnedEdge: !anchored ? ""
        : idealLeft > screenWidth - panelWidth - Theme.padding ? "right"
        : idealLeft < Theme.padding ? "left"
        : ""
    // When pinned to an edge, wipe in sideways from that edge and tether to it,
    // instead of unrolling down from the bar.
    property bool edgeReveal: false
    readonly property bool horizontal: edgeReveal && pinnedEdge !== ""
    readonly property int panelX: horizontal && pinnedEdge === "left" ? tether : 0

    property real progress: shown ? 1 : 0
    Behavior on progress {
        NumberAnimation {
            duration: 650
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.2, 0.8, 0.2, 1, 1, 1]
        }
    }

    implicitWidth: panelWidth + (horizontal ? tether : 0)
    implicitHeight: tether + panelHeight
    visible: shown || progress > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: anchored
    margins.top: Theme.padding + Theme.barHeight
    margins.left: anchored ? panelLeft - panelX : 0

    mask: Region { item: clipper }

    WlrLayershell.keyboardFocus: shown ? focusMode : WlrKeyboardFocus.None

    Item {
        id: clipper
        clip: true
        x: root.horizontal && root.pinnedEdge === "right" ? root.implicitWidth - width : 0
        width: root.horizontal ? Math.round(root.implicitWidth * root.progress) : root.implicitWidth
        height: root.horizontal ? root.implicitHeight : Math.round(root.implicitHeight * root.progress)
        focus: true
        Keys.onEscapePressed: Panels.close()

        readonly property real frameX: Math.max(0, root.panelX - x)
        readonly property real frameWidth: Math.max(0, Math.min(x + width, root.panelX + root.panelWidth) - Math.max(x, root.panelX))
        readonly property real frameHeight: Math.max(0, height - root.tether)

        Rectangle {
            visible: !root.horizontal
            x: root.panelX + Math.round(root.panelWidth / 2) - clipper.x
            width: Theme.borderWidth
            height: root.tether
            color: Theme.borderColor
        }

        Rectangle {
            visible: root.horizontal
            x: (root.pinnedEdge === "right" ? root.panelWidth : 0) - clipper.x
            y: root.tether + Math.round(root.panelHeight / 2)
            width: root.tether
            height: Theme.borderWidth
            color: Theme.borderColor
        }

        Rectangle {
            x: clipper.frameX
            y: root.tether
            width: clipper.frameWidth
            height: clipper.frameHeight
            color: Theme.background
            radius: Theme.radius
        }

        ColumnLayout {
            id: column
            x: root.panelX + Theme.padding - clipper.x
            y: root.tether + Theme.padding
            width: root.panelWidth - Theme.padding * 2
        }

        Rectangle {
            x: clipper.frameX
            y: root.tether
            width: clipper.frameWidth
            height: clipper.frameHeight
            color: "transparent"
            border.color: Theme.borderColor
            border.width: Theme.borderWidth
            radius: Theme.radius
        }
    }
}
