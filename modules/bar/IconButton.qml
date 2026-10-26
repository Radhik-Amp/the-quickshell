import QtQuick
import qs.components

BarText {
    id: root
    signal clicked()

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.clicked() }
}
