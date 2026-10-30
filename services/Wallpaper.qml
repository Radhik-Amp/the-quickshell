pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var currentPaths: ({})
    property var entries: []
    property var currentDirectory: Quickshell.env("HOME") + "/wallpapers"
    readonly property var extensions: ["jpeg", "jpg", "png", "webp", "gif"]

    property bool shown: false
    property int queryAttempts: 0

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void { root.set(path) }
        function toggle(): void { root.toggle() }
    }

    function refresh() {
        listDirectory.running = true
        query.running = true
    }

    function set(path: string) {
        setter.command = ["awww", "img", path,
                          "--transition-type", "center",
                          "--transition-duration", "0.6",
                          "--transition-bezier", "0.22,1,0.36,1",
                          "--transition-fps", "144"]
        setter.running = true
    }

    function toggle() {
        root.shown = !root.shown
    }

    Process {
        id: query
        command: ["awww", "query"]
        stdout: StdioCollector {
            onStreamFinished: {
                const newPaths = {}
                const marker = "image: "

                for (const line of text.split("\n")) {
                    if (!line.trim()) continue

                    const i = line.indexOf(marker)
                    if (i === -1) continue

                    const m = line.match(/^(?:[^:]*:\s+)?(\S+?):\s/)
                    if (!m) continue

                    newPaths[m[1]] = line.slice(i + marker.length).trim()
                }

                root.currentPaths = newPaths
                if (Object.keys(newPaths).length === 0 && root.queryAttempts < 10)
                    retryTimer.restart()
                else
                    root.queryAttempts = 0
            }
        }
    }

    Process {
        id: listDirectory
        command: ["find", "-L", root.currentDirectory, "-mindepth", "1", "-maxdepth", "1", "-type", "f", "-printf", "%P\\n"]
        stdout: StdioCollector {
            onStreamFinished: {
                const newEntries = []
                for (const line of text.split("\n")) {
                    const dot = line.lastIndexOf(".")
                    const ext = dot === -1 ? "" : line.slice(dot + 1).toLowerCase()

                    if (!line) continue
                    if (line[0] === ".") continue
                    if (!root.extensions.includes(ext)) continue

                    newEntries.push(root.currentDirectory + "/" + line)
                }
                newEntries.sort((a, b) => a.localeCompare(b, undefined, { numeric: true }))
                root.entries = newEntries
            }
        }
    }

    Process { id: setter; onExited: query.running = true}

    Component.onCompleted: refresh()

    Timer {
        id: retryTimer
        interval: 500
        onTriggered: {
            root.queryAttempts++
            query.running = true
        }
    }
}

