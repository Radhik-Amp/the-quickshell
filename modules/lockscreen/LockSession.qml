import qs.components
import qs.config
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
                { label: "\u{F0904}", command: ["systemctl", "suspend"] },   
                { label: "\u{F021}", command: ["systemctl", "reboot"] },   
                { label: "\u{F011}", command: ["systemctl", "poweroff" ] }
            ]
        
            SessionButton {
                required property var modelData
                Layout.fillWidth: true
                label: modelData.label
                command: modelData.command
            }
        }
    }
}
