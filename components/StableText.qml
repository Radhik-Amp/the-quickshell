import QtQuick
import QtQuick.Layouts

BarText {
    id: root

    required property var widest

    Layout.minimumWidth: {
        metrics.font
        return Math.max(...[].concat(root.widest).map(s => Math.ceil(metrics.boundingRect(s).width)))
    }

    FontMetrics {
        id: metrics
        font: root.font
    }
}
