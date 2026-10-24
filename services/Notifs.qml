pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    property alias history: history
    property alias server: server

    ListModel { id: history }

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            history.insert(0, {
                notifId: n.id,
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            })
            if (ControlState.dnd && n.urgency !== NotificationUrgency.Critical) return
            n.tracked = true
        }
    }

    function dismissNotif(notifID: int): void {
        const n = server.trackedNotifications.values.find(n => n.id === notifID)
        if (n) n.dismiss();
    }
}

