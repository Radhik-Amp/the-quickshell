pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import QtQuick

Singleton {
    id: root

    property bool locked: false
    property bool authenticating: pam.active
    property bool authFailed: false
    property bool unlocking: false
    property string message: ""
    property bool suspendPending: false

    function lockAndSuspend() {
        console.warn("lock and suspend called")
        if (root.locked) {
            Quickshell.execDetached(["systemctl", "suspend"])
            return
        }
        suspendPending = true
        lock()
    }

    function lock() {
        if (!root.locked) {
            authFailed = false
            unlocking = false
            root.locked = true
        }
    }

    function unlock() {
        authFailed = false
        root.locked = false
        unlocking = false
    }

    function authenticate(password) {
        if (pam.active || unlocking) return
        authFailed = false
        pam.gotMessage = false
        pam.pending = password
        pam.start()
    }

    Timer {
        interval: 350
        running: root.unlocking
        onTriggered: root.unlock()
    }

    IpcHandler {
        target: "lockscreen"
        function lock(): void { root.lock() }
        function isLocked(): bool { return root.locked }
        function lockAndSuspend(): void { root.lockAndSuspend() }
    }

    PamContext {
        id: pam
        config: "login"
        property string pending: ""
        property bool gotMessage: false

        onCompleted: (result) => {
            pending = ""
            if (result === PamResult.Success) {
                root.unlocking = true
            } else {
                if (!gotMessage) root.message = "Incorrect password"
                root.authFailed = true
            }
        } 
        onError: (error) => {
            pending = ""
            if (!gotMessage) root.message = "Authentication error"
            root.authFailed = true
        }

        onPamMessage: {
            if (responseRequired) {
                respond(pending)
                pending = ""
            } else if (message) {
                root.message = message
                gotMessage = true
            }
        }
    }
}
