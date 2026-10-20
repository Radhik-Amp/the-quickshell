import qs
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property int activeTag: 1

    spacing: 6

    Repeater {
        model: 9

        Rectangle {
            id: tag
            required property int index
            readonly property int number: index + 1
            
            readonly property var info: Mango.tags[index] ?? null
            readonly property bool active: info ? info.is_active : false
            readonly property bool occupied: info ? info.client_count > 0 : false
            readonly property bool urgent: info ? info.is_urgent : false

            implicitWidth: Theme.tagWidth
            implicitHeight: Theme.tagHeight
            radius: Theme.radius
            border.width: 1
            border.color: active ? Theme.tagBorderActive 
                        : occupied ? Theme.tagBorder
                        : Theme.tagBorderEmpty
            color: active ? Theme.tagActive
                 : urgent ? Theme.tagUrgent
                 : mouse.containsMouse ? Theme.tagHover
                 : "transparent"

            BarText {
                anchors.centerIn: parent
                text: tag.number
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Mango.viewTag(tag.number)
            }
        }
    }
    Item {
        id: layoutIndicator
        implicitWidth: layoutIcon.width
        implicitHeight: Theme.tagHeight
        Item {
            id: layoutIcon
            anchors.centerIn: parent
            height: Theme.tagHeight - 4
            width: Math.round(height * 9 / 7)
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)

            Repeater {
                model: Theme.layoutRects[Mango.layout] ?? []

                Rectangle {
                    required property var modelData
                    x: modelData[0] * parent.width
                    y: modelData[1] * parent.height
                    width: modelData[2] * parent.width - 1
                    height: modelData[3] * parent.height - 1
                    opacity: modelData[4] ?? 1
                    radius: 1
                    color: modelData[4] ? "white" : Theme.background
                    border.width: 1
                    border.color: "white"
                }
            }
        }
    }
}
