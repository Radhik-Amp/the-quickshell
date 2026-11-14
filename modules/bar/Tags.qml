import qs.config
import qs.services
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    spacing: Theme.spaceSm

    readonly property color fillActive: Qt.rgba(1, 1, 1, 0.28)
    readonly property color fillHover: Qt.rgba(1, 1, 1, 0.14)
    readonly property color fillUrgent: Qt.rgba(1, 1, 1, 0.45)
    readonly property color borderOccupied: Qt.rgba(1, 1, 1, 0.40)
    readonly property color borderActive: Qt.rgba(1, 1, 1, 0.55)

    WheelHandler {
        property real accumulated: 0

        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            accumulated += event.angleDelta.y
            const steps = Math.trunc(accumulated / 120)
            if (steps === 0)
                return
            accumulated -= steps * 120

            const current = Mango.pendingTag >= 0 ? Mango.pendingTag
                          : Mango.tags.findIndex(t => t.is_active)
            if (current < 0)
                return
            const next = (((current - steps) % 9) + 9) % 9
            Mango.viewTag(next + 1)
        }
    }

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
            readonly property bool minimized: !occupied && Wallpaper.hiddenClients.some(c => c.tags.includes(number))

            implicitWidth: Theme.tagWidth
            implicitHeight: Theme.tagHeight
            radius: Theme.radius
            border.width: 1
            border.color: minimized ? "transparent"
                        : active ? root.borderActive
                        : occupied ? root.borderOccupied
                        : "transparent"

            Repeater {
                model: tag.minimized ? [
                    [0, 0],
                    [tag.width - tag.radius, 0],
                    [0, tag.height - tag.radius],
                    [tag.width - tag.radius, tag.height - tag.radius]
                ] : []

                Item {
                    required property var modelData
                    x: modelData[0]
                    y: modelData[1]
                    width: tag.radius
                    height: tag.radius
                    clip: true

                    Rectangle {
                        x: -parent.x
                        y: -parent.y
                        width: tag.width
                        height: tag.height
                        radius: tag.radius
                        color: "transparent"
                        border.width: 1
                        border.color: tag.active ? root.borderActive : root.borderOccupied
                    }
                }
            }
            color: active ? root.fillActive
                 : urgent ? root.fillUrgent
                 : hover.hovered ? root.fillHover
                 : "transparent"

            StyledText {
                anchors.centerIn: parent
                text: tag.number
            }

            HoverHandler {
                id: hover
                cursorShape: Qt.PointingHandCursor
            }

            TapHandler {
                onTapped: Mango.viewTag(tag.number) 
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
