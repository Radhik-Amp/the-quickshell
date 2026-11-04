pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string active: "" // names: "control", "media", ...

    function toggle(name: string): void { active = active === name ? "" : name }
    function open(name: string): void { active = name }
    function close(): void { active = "" }

    IpcHandler {
        target: "panels"
        function toggle(name: string): void { root.toggle(name) }
        function open(name: string): void { root.open(name) }
        function close(): void { root.close() }
    }
}
