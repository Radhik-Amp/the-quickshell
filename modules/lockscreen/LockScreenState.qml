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
    // set on successful auth; LockScreen plays the fade-out, then calls unlock()
    property bool unlocking: false

    function lock() {
        if (!root.locked) {
            authFailed = false
            unlocking = false
            root.locked = true
        }
    }

    function unlock() {
        authFailed = false
        // release the lock before clearing unlocking, so the surface doesn't start fading back in
        root.locked = false
        unlocking = false
    }

    function authenticate(password) {
        if (pam.active || unlocking) return
        authFailed = false
        pam.pending = password
        pam.start()
    }

    // let the fade-out finish before the session lock is released
    // (must live here: WlSessionLock's default property is `surface`, so children there are dropped)
    Timer {
        interval: 350
        running: root.unlocking
        onTriggered: root.unlock()
    }

    IpcHandler {
        target: "lockscreen"
        function lock(): void { root.lock() }
        function isLocked(): bool { return root.locked }
    }

    PamContext {
        id: pam
        config: "login"
        property string pending: ""

        onCompleted: (result) => {
            pending = ""
            if (result === PamResult.Success) {
                root.unlocking = true
            } else {
                root.authFailed = true
            }
        } 
        onError: (error) => {
            pending = ""
            root.authFailed = true
        }

        onPamMessage: {
            if (responseRequired) {
                respond(pending)
                pending = ""
            } 
        }
    }
}
