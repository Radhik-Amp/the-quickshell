pragma Singleton

import Quickshell.Wayland
import Quickshell
import QtQuick

Singleton {
    id: root

    property bool caffiene: false

    property int lockTimeout: 300
    property int screenOffTimeout: 600
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
