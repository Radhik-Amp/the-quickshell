import qs.config
import qs.components
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    // Outlined card with an icon, a muted label and a value.

    property string icon
    property string label
    property string value

    implicitHeight: content.implicitHeight + Theme.spaceSm * 2
    radius: Theme.radius
    color: "transparent"
    border.width: Theme.borderWidth
    border.color: Theme.borderColorMuted

    RowLayout {
        id: content
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: Theme.spaceSm
        }
        spacing: Theme.spaceSm

        GlyphText {
            Layout.preferredWidth: font.pixelSize
            text: root.icon
            font.pixelSize: Theme.fontSize + 4
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: root.label
                color: Theme.textMuted
                font.pixelSize: Theme.fontSize - 3
                elide: Text.ElideRight
            }
            StyledText {
                Layout.fillWidth: true
                text: root.value
                elide: Text.ElideRight
            }
        }
    }
}
