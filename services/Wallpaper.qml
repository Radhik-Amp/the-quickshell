pragma Singleton

import qs.config
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string pendingDirectory: ""
    property string directoryError: ""
    property var currentPaths: ({})
    property var entries: []
    property var currentDirectory: Env.wallpaperDir
    readonly property var extensions: ["jpeg", "jpg", "png", "webp", "gif"]

    property bool previewShown: false
    property int queryAttempts: 0

    IpcHandler {
        target: "wallpaper"
        function set(path: string): void { root.set(path) }
        function toggle(): void { root.toggle() }
        function preview(): void { root.togglePreview() }
    }

    function setDirectory(text: string) {
        const path = text.trim().replace(/^~/, Quickshell.env("HOME")).replace(/\/+$/, "")

        if (!path) {
            root.directoryError = "Enter a folder path"
            return
        } 

        if (path === root.currentDirectory) refresh()
        else {
            root.pendingDirectory = path
            dirCheck.command = ["test", "-d", path]
            dirCheck.running = true
        }
    }

    function refresh() {
        listDirectory.running = true
        query.running = true
    }

    function set(path: string) {
        setter.command = ["awww", "img", path,
                          "--transition-type", Env.wallpaperTransition,
                          "--transition-duration", String(Env.wallpaperDuration),
                          "--transition-bezier", Env.wallpaperBezier,
                          "--transition-fps", String(Env.wallpaperFps),
                          "--transition-angle", String(Env.wallpaperAngle),
                          "--transition-pos", Env.wallpaperPosition]
        setter.running = true
    }

    function toggle() {
        Panels.toggle("wallpaper")
    }

    function togglePreview() {
        if (root.previewShown) root.previewShown = false
        else openPreview()
    }

    // Preview: minimize the windows on the current tag so the real wallpaper (and awww's
    // transitions) show behind the wallpaper panel, which opens along with it
    function openPreview() {
        Panels.open("wallpaper")
        root.previewShown = true
    }

    // Windows the preview minimized, in restore order: [{ id, tags }]. Also saved to
    // stateFile, so a crash or reload mid-preview restores them on the next start.
    property var hiddenClients: []
    readonly property string stateFile: '"${XDG_STATE_HOME:-$HOME/.local/state}/voyager/preview-hidden.json"'

    onPreviewShownChanged: {
        if (previewShown) clientQuery.running = true
        else restoreClients()
    }

    function hideClients(text) {
        if (!previewShown) return // preview closed before the query came back
        let clients = []
        try { clients = JSON.parse(text).clients ?? [] } catch (e) { console.warn("wallpaper: couldn't read clients:", e) }

        const shown = clients.filter(c => c.is_visible && !c.is_minimized
            && !c.is_scratchpad && !c.is_namedscratchpad
            && (!Mango.monitor || c.monitor === Mango.monitor))
        if (!shown.length) return
        // The focused window is restored last so it gets focus back
        shown.sort((a, b) => a.is_focused - b.is_focused)

        hiddenClients = hiddenClients.concat(shown.map(c => ({ id: c.id, tags: c.tags })))
        const state = JSON.stringify(hiddenClients)
        run(shown.map(c => "mmsg dispatch minimized client," + c.id)
            .concat([`mkdir -p "$(dirname ${stateFile})"`, `printf '%s' '${state}' > ${stateFile}`]))
    }

    function restoreClients() {
        if (!hiddenClients.length) return
        // Restored windows land on the tag being viewed; send any back that came from another
        const active = Mango.tags.find(t => t.is_active)?.index
        const cmds = []
        for (const c of hiddenClients) {
            cmds.push("mmsg dispatch restore_minimized client," + c.id)
            if (c.tags.length === 1 && c.tags[0] !== active)
                cmds.push(`mmsg dispatch tagsilent,${c.tags[0]} client,${c.id}`)
        }
        hiddenClients = []
        run(cmds.concat(["rm -f " + stateFile]))
    }

    function run(cmds) {
        Quickshell.execDetached(["sh", "-c", cmds.join("; ")])
    }

    Process {
        id: clientQuery
        command: ["mmsg", "get", "all-clients"]
        stdout: StdioCollector { onStreamFinished: root.hideClients(text) }
    }

    // Windows left minimized by a preview that never closed (crash, reload)
    Process {
        id: leftoverQuery
        command: ["sh", "-c", "cat " + root.stateFile + " 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const leftover = JSON.parse(text)
                    if (Array.isArray(leftover) && leftover.length) {
                        root.hiddenClients = leftover
                        root.restoreClients()
                    }
                } catch (e) {}
            }
        }
    }

    function fileUrl(path) {
        return "file://" + path.split("/").map(encodeURIComponent).join("/")
    }

    function apply(path) {
        if (path && !Object.values(root.currentPaths).includes(path)) set(path)
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

    Process {
    id: dirCheck
        onExited: (code) => {
            if (code === 0) {
                root.currentDirectory = root.pendingDirectory
                root.directoryError = ""
                root.refresh()
            } else {
                root.directoryError = "Folder not found: " + root.pendingDirectory
            }
        }
    }

    Process { id: setter; onExited: query.running = true}

    Component.onCompleted: {
        refresh()
        leftoverQuery.running = true
    }

    Timer {
        id: retryTimer
        interval: 500
        onTriggered: {
            root.queryAttempts++
            query.running = true
        }
    }
}

