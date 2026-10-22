import qs
import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight
    color: "transparent"
    radius: Theme.radius
    border.width: Theme.borderWidth
    border.color: Theme.borderColorMuted

    RowLayout {
        id: content

        implicitWidth: profiles.implicitWidth 
        implicitHeight: profiles.implicitHeight
        anchors.fill: parent
        spacing: 0

        Repeater {
            id: profiles
            model: [
                { label: "eco", value: PowerProfile.PowerSaver },
                { label: "normal", value: PowerProfile.Balanced },
                { label: "boost", value: PowerProfile.Performance }
            ]

            Rectangle {
                id: profileItem

                readonly property bool active: PowerProfiles.profile === modelData.value

                Layout.fillWidth: true
                implicitHeight: profileText.implicitHeight + Theme.padding
                color: active ? "white" : "transparent"

                BarText {
                    id: profileText
                    anchors.centerIn: parent
                    text: modelData.label
                    color: active ? Theme.background : "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: PowerProfiles.profile = modelData.value
                }
            }
        }
    }
}
