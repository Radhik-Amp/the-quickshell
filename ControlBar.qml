pragma ComponentBehavior:Bound 
import qs
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root
    property string label: ""
    property real value: 0
    property real from: 0
    property real to: 100
    signal moved(real value)
        

    RowLayout {
        Layout.fillWidth: true
        BarText {
            Layout.fillWidth: true
            text: "●" + " " + root.label
        }
        BarText {
            text: String(Math.round(root.value)).padStart(3, "0")
        }
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        topPadding: 10
        bottomPadding: 10
        from: root.from
        to: root.to
        value: root.value
        stepSize: 5
        snapMode: Slider.SnapAlways
        onMoved: root.moved(slider.value)
        wheelEnabled: true

        background: RowLayout {
            id: bar
            spacing: 2

            Repeater {
                model: 20
                Rectangle {
                    id: segment

                    required property int index
                    property bool countFilled: index < (slider.visualPosition * 20)

                    Layout.fillWidth: true
                    implicitHeight: 10

                    color: countFilled ? Qt.rgba(1, 1, 1, 1) : Qt.rgba(1, 1, 1, 0.15)
                    radius: 2
                    border.width: countFilled ? 1 : 0
                    border.color: countFilled ? Theme.borderColorMuted : "transparent"
                    

                }
            }

        }
        handle: Item {}

    }
    
}
