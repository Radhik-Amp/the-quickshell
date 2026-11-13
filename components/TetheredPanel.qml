import qs.config
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root
    // Panel frame tethered to the bar or a screen edge, opened via Panels.active.

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

    // Tether look and reveal direction; defaults come from VOYAGER_TETHER_STYLE / VOYAGER_TETHER_REVEAL.
    // style: "line", "thick", "dashed", "bridge" or "none"
    // reveal: "auto" (sideways from an edge it's clamped to, else down from the bar),
    //         "vertical" (always down from the bar) or "horizontal" (always from the nearer side edge)
    property string tetherStyle: Env.tetherStyle
    property string reveal: Env.tetherReveal

    readonly property real idealLeft: anchorX - panelWidth / 2
    readonly property string clampedEdge: !anchored ? ""
        : idealLeft > screenWidth - panelWidth - Theme.padding ? "right"
        : idealLeft < Theme.padding ? "left"
        : ""
    readonly property string nearerEdge: (anchored ? anchorX : screenWidth / 2) < screenWidth / 2 ? "left" : "right"
    readonly property string edge: reveal === "vertical" ? ""
        : reveal === "horizontal" ? (clampedEdge || nearerEdge)
        : clampedEdge
    readonly property bool horizontal: edge !== ""
    readonly property real panelLeft: edge === "right" ? screenWidth - panelWidth - Theme.padding
        : edge === "left" ? Theme.padding
        : anchored ? Math.round(Math.max(Theme.padding, Math.min(idealLeft, screenWidth - panelWidth - Theme.padding)))
        : Math.round((screenWidth - panelWidth) / 2)
    // Bridge corners flare past the panel's sides, so the window leaves room for them
    readonly property int flare: tetherStyle === "bridge" ? Math.round(tether / 2) : 0
    readonly property int panelX: edge === "left" ? tether : horizontal ? 0 : flare

    property real progress: shown ? 1 : 0
    Behavior on progress {
        NumberAnimation {
            duration: 650
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.2, 0.8, 0.2, 1, 1, 1]
        }
    }

    implicitWidth: panelWidth + (horizontal ? tether : flare * 2)
    implicitHeight: tether + panelHeight + (horizontal ? flare : 0)
    visible: shown || progress > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    margins.top: Theme.padding + Theme.barHeight
    margins.left: panelLeft - panelX

    // While a bridged panel hangs from the bar, tell the bar where to open its border
    readonly property var barGap: tetherStyle === "bridge" && !horizontal && visible
        ? [panelLeft - flare, panelLeft + panelWidth + flare]
        : null
    onBarGapChanged: Panels.setBarGap(name, barGap)
    Component.onDestruction: Panels.setBarGap(name, null)

    mask: Region { item: clipper }

    WlrLayershell.keyboardFocus: shown ? focusMode : WlrKeyboardFocus.None

    Item {
        id: clipper
        clip: true
        x: root.edge === "right" ? root.implicitWidth - width : 0
        width: root.horizontal ? Math.round(root.implicitWidth * root.progress) : root.implicitWidth
        height: root.horizontal ? root.implicitHeight : Math.round(root.implicitHeight * root.progress)
        focus: true
        Keys.onEscapePressed: Panels.close()

        readonly property real frameX: Math.max(0, root.panelX - x)
        readonly property real frameWidth: Math.max(0, Math.min(x + width, root.panelX + root.panelWidth) - Math.max(x, root.panelX))
        readonly property real frameHeight: Math.max(0, Math.min(height, root.tether + root.panelHeight) - root.tether)

        Tether {
            visible: root.tetherStyle !== "none" && root.tetherStyle !== "bridge"
            style: root.tetherStyle
            length: root.tether
            vertical: !root.horizontal
            x: root.horizontal
                ? (root.edge === "right" ? root.panelWidth : 0) - clipper.x
                : root.panelX + Math.round(root.panelWidth / 2) - Math.floor(width / 2) - clipper.x
            y: root.horizontal ? root.tether + Math.round(root.panelHeight / 2) - Math.floor(height / 2) : 0
        }

        Rectangle {
            visible: root.tetherStyle !== "bridge"
            x: clipper.frameX
            y: root.tether
            width: clipper.frameWidth
            height: clipper.frameHeight
            color: Theme.background
            radius: Theme.radius
        }

        BridgeFrame {
            visible: root.tetherStyle === "bridge"
            anchors.fill: parent
            frameX: clipper.frameX
            frameY: root.tether
            frameWidth: clipper.frameWidth
            frameHeight: clipper.frameHeight
            edge: root.horizontal ? root.edge : "top"
            surface: root.edge === "right" ? root.implicitWidth - clipper.x
                : root.edge === "left" ? -clipper.x
                : 0
            fillet: root.flare
        }

        ColumnLayout {
            id: column
            x: root.panelX + Theme.padding - clipper.x
            y: root.tether + Theme.padding
            width: root.panelWidth - Theme.padding * 2
        }

        Rectangle {
            visible: root.tetherStyle !== "bridge"
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
