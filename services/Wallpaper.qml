pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var paths: ({})

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

                root.paths = newPaths
            }
        }
    }

    function refresh() {
        query.running = true
    }
}
