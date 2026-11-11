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
    property string iconReference: icon
    property bool dimmed: false
    property int valueAlignment: Text.AlignRight

    spacing: Theme.spaceSm

    GlyphText {
        id: iconText
        Layout.minimumWidth: {
            iconMetrics.font
            return Math.max(...[].concat(root.iconWidest).map(s => Math.ceil(iconMetrics.boundingRect(s).width)))
        }
        text: root.icon
        inkReference: root.iconReference

        FontMetrics {
            id: iconMetrics
            font: iconText.font
        }
    }

    FixedWidthText {
        text: root.value
        widest: root.widest
        horizontalAlignment: root.valueAlignment
        opacity: root.dimmed ? 0.75 : 1
    }
}
