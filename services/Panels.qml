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
