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

    // Tether look and reveal direction; defaults come from VOYAGER_TETHER_STYLE / _REVEAL / _CONTENT.
    // style: "line", "thick", "dashed", "bridge" or "none"
    // reveal: "auto" (sideways from an edge it's clamped to, else down from the bar),
    //         "vertical" (always down from the bar) or "horizontal" (always from the nearer side edge)
    // contentMotion (bridge only): "fixed" (uncovered in place) or "slide" (travels with the outline)
    property string tetherStyle: Env.tetherStyle
    property string reveal: Env.tetherReveal
    property string contentMotion: Env.tetherContent

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

    // Reveal progress, 0 (hidden) to 1 (open). Bridged panels use Noctalia's slide timing
    // (300ms ease-out-cubic open, ease-in-out-quad close); the other styles keep the slower
    // growing reveal. Started from onShownChanged so the easing is set before it runs.
    property real progress: 0
    Component.onCompleted: progress = shown ? 1 : 0
    onShownChanged: {
        revealAnim.stop()
        revealAnim.to = shown ? 1 : 0
        if (sliding) {
            revealAnim.duration = 300
            revealAnim.easing.type = shown ? Easing.OutCubic : Easing.InOutQuad
        } else {
            revealAnim.duration = 650
            revealAnim.easing.type = Easing.Bezier
            revealAnim.easing.bezierCurve = [0.2, 0.8, 0.2, 1, 1, 1]
        }
        revealAnim.start()
    }
    NumberAnimation {
        id: revealAnim
        target: root
        property: "progress"
    }

    implicitWidth: panelWidth + (horizontal ? tether : flare * 2)
    implicitHeight: tether + panelHeight + (horizontal ? flare : 0)

    // Bridged panels slide their outline's far edge out from under the bar (or out of the
    // screen edge) instead of growing a clip, with the curved joins fixed at the bar from the
    // first frame; the outline is what clips the panel.
    readonly property bool sliding: tetherStyle === "bridge"
    readonly property bool contentSlides: contentMotion === "slide"
    // Depth of the outline from the attach surface to its far edge, how much of it is still
    // hidden behind the surface, and how much is out
    readonly property real travel: tether + (horizontal ? panelWidth : panelHeight)
    readonly property real slide: sliding ? Math.round((1 - progress) * travel) : 0
    readonly property real reach: travel - slide
    readonly property real slideX: !sliding || !horizontal ? 0 : edge === "right" ? slide : -slide
    readonly property real slideY: sliding && !horizontal ? -slide : 0

    // Hide as soon as the reveal has pulled back out of the panel body; the easing's long
    // tail would otherwise leave a sliver on screen after the panel is gone.
    readonly property bool bodyVisible: sliding ? reach > Theme.radius
        : horizontal ? clipper.width > tether : clipper.height > tether
    visible: shown || bodyVisible
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    anchors.left: true
    margins.top: Theme.padding + Theme.barHeight
    margins.left: panelLeft - panelX

    // While a bridged panel hangs from the bar, tell the bar where to open its border: the
    // span between the outer ends of the curved joins (shrunk with them while the outline is
    // shallower than the curves, as in BridgeFrame).
    readonly property var barGap: {
        if (!sliding || horizontal || !bodyVisible) return null
        const f = Math.min(flare, (reach - 0.5) / 2)
        return [panelLeft - f, panelLeft + panelWidth + f]
    }
    onBarGapChanged: Panels.setBarGap(name, barGap)
    Component.onDestruction: Panels.setBarGap(name, null)

    mask: Region { item: body }

    WlrLayershell.keyboardFocus: shown ? focusMode : WlrKeyboardFocus.None

    // Growing reveal clip for the non-bridge styles; bridged panels keep it full-size and
    // clip by their sliding outline instead
    Item {
        id: clipper
        clip: true
        x: !root.sliding && root.edge === "right" ? root.implicitWidth - width : 0
        width: !root.sliding && root.horizontal ? Math.round(root.implicitWidth * root.progress) : root.implicitWidth
        height: !root.sliding && !root.horizontal ? Math.round(root.implicitHeight * root.progress) : root.implicitHeight
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

        // Outline reaching `reach` out from the bar or screen edge, curved joins fixed there
        BridgeFrame {
            visible: root.sliding
            depth: root.reach
            width: root.implicitWidth
            height: root.implicitHeight
            frameX: root.panelX
            frameY: root.tether
            frameWidth: root.panelWidth
            frameHeight: root.panelHeight
            edge: root.horizontal ? root.edge : "top"
            surface: root.edge === "right" ? root.implicitWidth : 0
            fillet: root.flare
        }

        // Panel body: clips the content to the outline (moving with it when sliding). The
        // content's padding keeps it clear of the rounded corners, so a rect is enough.
        Item {
            id: body
            clip: true
            x: root.sliding ? root.panelX + root.slideX : clipper.frameX
            y: root.tether + root.slideY
            width: root.sliding ? root.panelWidth : clipper.frameWidth
            height: root.sliding ? root.panelHeight : clipper.frameHeight

            ColumnLayout {
                id: column
                x: root.panelX + Theme.padding - clipper.x - body.x + (root.contentSlides ? root.slideX : 0)
                y: root.tether + Theme.padding - body.y + (root.contentSlides ? root.slideY : 0)
                width: root.panelWidth - Theme.padding * 2
            }
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
