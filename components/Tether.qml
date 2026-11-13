import qs.config
import QtQuick

Item {
    id: root
    // Straight tether strip: "line", "thick" or "dashed", running vertically or horizontally.

    property string style: "line"
    property int length: Theme.padding
    property bool vertical: true

    readonly property int thickness: style === "thick" ? 3 : Theme.borderWidth
    readonly property int dash: 2

    width: vertical ? thickness : length
    height: vertical ? length : thickness

    Rectangle {
        visible: root.style !== "dashed"
        anchors.fill: parent
        color: Theme.borderColor
    }

    Repeater {
        model: root.style === "dashed" ? Math.ceil(root.length / (root.dash * 2)) : 0

        Rectangle {
            required property int index
            x: root.vertical ? 0 : index * root.dash * 2
            y: root.vertical ? index * root.dash * 2 : 0
            width: root.vertical ? root.thickness : Math.min(root.dash, root.length - x)
            height: root.vertical ? Math.min(root.dash, root.length - y) : root.thickness
            color: Theme.borderColor
        }
    }
}
