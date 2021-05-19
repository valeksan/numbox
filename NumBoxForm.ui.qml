import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Control {
    id: control

    property alias inputText: inputText
    property alias displayText: displayText
    property alias placeholderText: placeholderText
    property alias sufInfoInEdit: sufInfoInEdit

    property alias displayTextMouseArea: displayTextMouseArea
    property alias inputTextMouseArea: inputTextMouseArea

    width: 180
    height: 46
    contentItem: Item {
        id: controlContent

        Label {
            id: displayText

            z: 3
            clip: true
            verticalAlignment: "AlignVCenter"
            horizontalAlignment: "AlignHCenter"
            visible: !inputText.activeFocus

            anchors.fill: parent

            MouseArea {
                id: displayTextMouseArea
                anchors.fill: parent
            }
        }

        TextField {
            id: inputText

            z: 2
            visible: !displayText.visible
            clip: true
            verticalAlignment: "AlignVCenter"
            horizontalAlignment: "AlignHCenter"

            anchors.fill: parent

            MouseArea {
                id: inputTextMouseArea
                anchors.fill: parent
            }
        }

        Label {
            id: placeholderText

            opacity: 0.4
            visible: inputText.visible && inputText.text.length === 0
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }

        Label {
            id: sufInfoInEdit

            visible: visibleSuffixInEdit ? inputText.visible : false
            verticalAlignment: Qt.AlignVCenter

            anchors {
                right: parent.right
                top: parent.top
            }
        }
    }

    states: [
        State {
            name: "view"
            PropertyChanges {
                target: displayText
                visible: true
            }
        },
        State {
            name: "edit"
            PropertyChanges {
                target: displayText
                visible: false
            }
        }
    ]
}
