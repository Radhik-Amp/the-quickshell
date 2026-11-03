import qs.config
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property string icon
    required property string value
    required property string widest
    property var iconWidest: icon
    property bool dimmed: false
    property int valueAlignment: Text.AlignRight

    spacing: Theme.spaceSm

    FixedWidthText {
        text: root.icon
        widest: root.iconWidest
        horizontalAlignment: Text.AlignHCenter
    }

    FixedWidthText {
        text: root.value
        widest: root.widest
        horizontalAlignment: root.valueAlignment
        opacity: root.dimmed ? 0.75 : 1
    }
}
