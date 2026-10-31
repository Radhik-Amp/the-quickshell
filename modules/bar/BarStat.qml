import qs.config
import qs.components
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property string icon
    required property string value
    required property string widest
    // Pass every icon variant when the icon changes, so its width stays fixed
    property var iconWidest: icon
    property bool dimmed: false
    property int valueAlignment: Text.AlignRight

    spacing: Theme.spaceSm

    StableText {
        text: root.icon
        widest: root.iconWidest
        horizontalAlignment: Text.AlignHCenter
    }
    StableText {
        text: root.value
        widest: root.widest
        // Right-aligned by default so the gap to whatever follows stays fixed as digits change
        horizontalAlignment: root.valueAlignment
        opacity: root.dimmed ? 0.75 : 1
    }
}
