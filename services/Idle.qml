pragma Singleton

import qs.config
import Quickshell.Wayland
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool caffeine: false

    property int lockTimeout: Env.lockTimeout
    property int screenOffTimeout: Env.suspendTimeout
    property var suspendCmd: ["systemctl", "suspend"]

    IdleMonitor {
        id: lockMonitor
        timeout: root.lockTimeout
        onIsIdleChanged: if (isIdle) LockScreenState.lock()
    }

    IdleMonitor {
        id: screenMonitor
        timeout: root.screenOffTimeout
        onIsIdleChanged: if (isIdle) Quickshell.execDetached(root.suspendCmd)
    }
}
