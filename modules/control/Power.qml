import qs
import qs.components
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
                readonly property bool isFirst: index === 0
                readonly property bool isLast: index === profiles.count - 1

                Layout.fillWidth: true
                implicitHeight: profileText.implicitHeight + Theme.padding

                topLeftRadius: isFirst ? root.radius : 0
                bottomLeftRadius: isFirst ? root.radius : 0
                topRightRadius: isLast ? root.radius : 0
                bottomRightRadius: isLast ? root.radius : 0

                border.width: root.border.width
                border.color: root.border.color
                color: mouse.containsMouse && !active ? Qt.rgba(0.28, 0.28, 0.28, 0.35)
                     : active ? Theme.borderColor 
                     : "transparent"

                BarText {
                    id: profileText
                    anchors.centerIn: parent
                    text: modelData.label
                    color: active ? Theme.background : "white"
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: PowerProfiles.profile = modelData.value
                }
            }
        }
    }
}
