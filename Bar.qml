import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }
    
    margins {
        top: Theme.padding
        left: Theme.padding
        right: Theme.padding
    }

    implicitHeight: Theme.barHeight
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.borderColor

        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.barSpacing

            Tags {}
            Media {}
        }

        Clock {
            anchors.centerIn: parent
        }

        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: Theme.padding
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.barSpacing

            Volume {}
            Vitals {}
        }
    }
}
