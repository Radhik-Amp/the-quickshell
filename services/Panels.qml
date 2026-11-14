pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string active: "" // names: "control", "media", "weather", ...

    property var positions: ({})

    function toggle(name: string): void { active = active === name ? "" : name }
    function open(name: string): void { active = name }
    function close(): void { active = "" }

    property var barGaps: ({})

    function setBarGap(name: string, span: var): void {
        const next = Object.assign({}, barGaps)
        if (span) next[name] = span
        else delete next[name]
        barGaps = next
    }

    // Screen rect [x, y, w, h] each visible panel currently covers, so an opening panel can
    // wait for a closing one to get out of its way
    property var extents: ({})

    function setExtent(name: string, rect: var): void {
        if (!rect && !(name in extents)) return
        const next = Object.assign({}, extents)
        if (rect) next[name] = rect
        else delete next[name]
        extents = next
    }

    function setPosition(name: string, x: real): void {
        if (positions[name] === x) return
        const next = Object.assign({}, positions)
        next[name] = x
        positions = next
    }

    IpcHandler {
        target: "panels"
        function toggle(name: string): void { root.toggle(name) }
        function open(name: string): void { root.open(name) }
        function close(): void { root.close() }
    }
}
