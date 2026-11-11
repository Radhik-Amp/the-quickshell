import QtQuick
import QtQuick.Layouts

StyledText {
    id: root
    // Text whose minimum width fits the widest of `widest`, so values don't jitter.

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
