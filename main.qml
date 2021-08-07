import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 1000
    height: 900
    title: "Example to use"

    RowLayout {
        anchors.fill: parent
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Item {
                height: 75
                width: 600
                Text {
                    text: "exhibit (not all functionality is implemented in the example! see control code)"
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    height: 15
                }
                Rectangle {
                    border.width: 1
                    border.color: "black"
                    anchors.fill: parent
                    anchors.topMargin: 15
                    NumBox {
                        id: superRealSpinBox
                        height: 45
                        width: 200
                        value: 0.0
                        precision: precision_setter.value
                        minimumValue: 0.0
                        maximumValue: 104.75
                        enableSequenceGrid: chkEnableSeqGrid.checked
                        step: step_setter.value
                        editable: chkEditable.checked
                        suffix: " dB"
                        fixed: chkFixedZeros.checked
                        decimalPlaces: decimals_setter.value
                        memory: 3.8
                        doubleClickEdit: chk2click.checked
                        onFinishEdit: {
                            value = number; // if you don't write that, nothing will change!
                        }
                        anchors.centerIn: parent
                    }
                }
            }
            CheckBox {
                id: chkFixedZeros
                text: "Fixed display of zeros"
                checked: true
            }
            Row {
                spacing: 15
                Label {
                    text: "Displayed numbers after the decimal point (0 - 10):"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                SpinBox {
                    id: decimals_setter
                    from: 0
                    to: 10
                    value: 2
                }
            }
            Row {
                spacing: 15
                Label {
                    text: "Accuracy (0 - 10):"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                SpinBox {
                    id: precision_setter
                    from: 0
                    to: 10
                    value: 2
                }
            }
            Row {
                spacing: 15
                Label {
                    text: "Step (our control is used):"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                NumBox {
                    id: step_setter // step installer
                    height: 45
                    width: 200
                    value: 0.05
                    precision: precision_setter.value
                    minimumValue: 0.0
                    maximumValue: 100.0
                    step: Math.pow(10, -(precision))
                    editable: true
                    fixed: true
                    onFinishEdit: {
                        value = number;
                    }
                }
            }
            CheckBox {
                id: chkEnableSeqGrid
                text: "Enable Snap to Step Grid " + superRealSpinBox.step.toString() + " (can be changed in the code)"
                checked: false
            }
            CheckBox {
                id: chkEditable
                text: "Enable editing"
                checked: true
            }
            CheckBox {
                id: chk2click
                text: "Double click editing (Optional)"
            }
        }
    }
}
