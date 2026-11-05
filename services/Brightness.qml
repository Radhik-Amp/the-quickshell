pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

//ddcutil-service instead of ddcutil cli
Singleton {
    id: root
    property int value: 0
    property int max: 100
    property int pending: -1

    property int display: 1
    readonly property string edid: ""

    readonly property int vcpBrightness: 0x10
    readonly property int flagNoVerify: 4

    function set(v) {
        root.value = v
        root.pending = v
        debounce.restart()
    }

    function call(method, signature, args) {
        return ["busctl", "--user", "--json=short", "call",
            "com.ddcutil.DdcutilService", "/com/ddcutil/DdcutilObject",
            "com.ddcutil.DdcutilInterface", method, signature].concat(args.map(String))
    }

    function parse(text, method) {
        try {
            const data = JSON.parse(text).data
            const status = data[data.length - 2]
            if (status !== 0) {
                console.warn("brightness:", method, "failed:", data[data.length - 1])
                return null
            }
            return data
        } catch (e) {
            console.warn("brightness:", method, "unparseable reply:", text)
            return null
        }
    }

    Process {
        command: root.call("GetVcp", "isyu", [root.display, root.edid, root.vcpBrightness, 0])
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const data = root.parse(text, "GetVcp")
                if (!data) return
                root.value = data[0]
                root.max = data[1]
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) console.warn("brightness: GetVcp:", text.trim())
        }
    }

    Timer {
        id: debounce
        interval: 150
        onTriggered: {
            if (setProc.running) { restart(); return }
            setProc.command = root.call("SetVcp", "isyqu",
                [root.display, root.edid, root.vcpBrightness, root.pending, root.flagNoVerify])
            setProc.running = true
        }
    }

    Process {
        id: setProc
        stdout: StdioCollector {
            onStreamFinished: root.parse(text, "SetVcp")
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) console.warn("brightness: SetVcp:", text.trim())
        }
    }
}
