import QtQuick
import QtQuick.Layouts

StyledText {
    id: root

    property string inkReference: text

    Layout.preferredWidth: Math.ceil(ink.tightBoundingRect.width)
    horizontalAlignment: Text.AlignHCenter

    TextMetrics {
        id: ink
        font: root.font
        text: root.inkReference
    }

    transform: Translate {
        x: Math.round(ink.advanceWidth / 2 - (ink.tightBoundingRect.x + ink.tightBoundingRect.width / 2))
    }
}
