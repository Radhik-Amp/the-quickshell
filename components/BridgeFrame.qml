import qs.config
import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    // Visible panel rect, in this item's coordinates
    property real frameX: 0
    property real frameY: 0
    property real frameWidth: 0
    property real frameHeight: 0
    property real radius: Theme.radius

    property string edge: "top"
    property real surface: 0
    property real fillet: Theme.padding / 2

    preferredRendererType: Shape.CurveRenderer

    readonly property var paths: {
        const side = edge !== "top"
        const s = surface
        let u0, u1, v1
        if (!side) {
            u0 = frameX; u1 = frameX + frameWidth
            v1 = frameY + frameHeight - s
        } else {
            u0 = frameY; u1 = frameY + frameHeight
            v1 = edge === "right" ? s - frameX : frameX + frameWidth - s
        }
        if (u1 - u0 < 1 || v1 < 1) return { fill: "", stroke: "" }

        u0 += 0.5; u1 -= 0.5; v1 -= 0.5
        const f = fillet
        const r = Math.max(0, Math.min(radius, (u1 - u0) / 2, v1 - f))

        const mirror = edge === "left"
        const pt = (u, v) => !side ? `${u} ${s + v}` : edge === "right" ? `${s - v} ${u}` : `${s + v} ${u}`
        const arc = (rad, sweep, u, v) => `A ${rad} ${rad} 0 0 ${mirror ? 1 - sweep : sweep} ${pt(u, v)}`

        const d = [
            `M ${pt(u0 - f, 0)}`, arc(f, 1, u0, f),
            `L ${pt(u0, v1 - r)}`, arc(r, 0, u0 + r, v1),
            `L ${pt(u1 - r, v1)}`, arc(r, 0, u1, v1 - r),
            `L ${pt(u1, f)}`, arc(f, 1, u1 + f, 0)
        ].join(" ")
        return { fill: d + " Z", stroke: d }
    }

    ShapePath {
        fillColor: Theme.background
        strokeColor: "transparent"
        PathSvg { path: root.paths.fill }
    }

    ShapePath {
        fillColor: "transparent"
        strokeColor: Theme.borderColor
        strokeWidth: Theme.borderWidth
        PathSvg { path: root.paths.stroke }
    }
}
