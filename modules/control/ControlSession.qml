import qs.config
import qs.services
import qs.components
import Quickshell
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: Theme.padding
    Layout.fillWidth: true
    property int gap: 200

    RowLayout {
        id: left
        spacing: parent.spacing

        Repeater {
            model: [
                { label: "\u{F023}", command: ["echo", "locked"] },   
                { label: "\u{F0904}", command: ["systemctl", "suspend"] },   
                { label: "\u{F021}", command: ["systemctl", "reboot"] }   
            ]
        
            SessionButton {
                required property var modelData
                Layout.fillWidth: true
                label: modelData.label
                command: modelData.command
            }
        }

        Item { Layout.preferredWidth: root.gap }

        SessionButton {
            label: "\u{F011}"
            command: ["systemctl", "poweroff"]
            holdDuration: 3000
            Layout.preferredWidth: 150
        }

    }

    
}

