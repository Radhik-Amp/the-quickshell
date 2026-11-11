import QtQuick

StyledText {
    id: root

    TextMetrics {
        id: ink
        font: root.font
        text: root.text
    }

    transform: Translate {
        x: Math.round(ink.advanceWidth / 2 - (ink.tightBoundingRect.x + ink.tightBoundingRect.width / 2))
    }
}
