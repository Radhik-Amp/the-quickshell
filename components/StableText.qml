import QtQuick
import QtQuick.Layouts

BarText {
    id: root
    required property string widest

    Layout.minimumWidth: metrics.width

    TextMetrics {
        id: metrics
        font: root.font
        text: root.widest

    }
}
