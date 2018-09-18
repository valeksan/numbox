import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "components" as Components

ApplicationWindow {
    visible: true
    width: 1000
    height: 900
    title: qsTr("Пример")

    RowLayout {
        anchors.fill: parent
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Item {
                height: 75
                width: 600
                Text {
                    text:"экспонат (не весь функционал реализован в примере! см. код контрола)"
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
                    Components.NumBox {
                        id: superRealSpinBox // :)
                        height: 45
                        width: 200
                        value: 0.0
                        buttonsAlignType: 2
                        precision: precision_setter.value
                        minimumValue: 0.0
                        maximumValue: 104.75
                        enableSequenceGrid: chkEnableSeqGrid.checked //
                        step: step_setter.value
                        editable: chkEditable.checked
                        suffix: " dB"
                        fixed: chkFixedZeros.checked
                        decimals: decimals_setter.value
                        decorateBorders: chkDecorateBorders.checked
                        memory: 3.8
                        doubleClickEdit: chk2click.checked
                        widthButtons: 45
                        onFinishEdit: {
                            // если так не написать, ничего не будет изменяться!
                            value = number
                        }
                        anchors.centerIn: parent
                    }
                }
            }
            Text {
                text: "Варианты расположения кнопок:"
            }
            ButtonGroup {
                buttons: groupNumBoxTypes.children
            }
            Row {
                id: groupNumBoxTypes
                RadioButton {
                    text: "0"
                    onCheckedChanged: {
                        if(checked === true) superRealSpinBox.buttonsAlignType = 0
                    }
                }
                RadioButton {
                    text: "1"
                    onCheckedChanged: {
                        if(checked === true) superRealSpinBox.buttonsAlignType = 1
                    }
                }
                RadioButton {
                    text: "2"
                    checked: true
                    onCheckedChanged: {
                        if(checked === true) superRealSpinBox.buttonsAlignType = 2
                    }
                }
                RadioButton {
                    text: "3"
                    onCheckedChanged: {
                        if(checked === true) superRealSpinBox.buttonsAlignType = 3
                    }
                }
                RadioButton {
                    text: "4"
                    onCheckedChanged: {
                        if(checked === true) superRealSpinBox.buttonsAlignType = 4
                    }
                }
            }
            CheckBox {
                id: chkDecorateBorders
                text: "Окантовка"
                checked: true
            }
            CheckBox {
                id: chkFixedZeros
                text: "Фиксированное отображение нулей"
                checked: true
            }
            Row {
                spacing: 15
                Label {
                    text:"Количество отображаемых чисел после запятой (0-10):"
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
                    text:"Точность (0-10):"
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
                    text:"Шаг (используется наш контрол):"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                Components.NumBox {
                    id: step_setter // установщик шага
                    height: 45
                    width: 200
                    value: 0.05
                    buttonsAlignType: superRealSpinBox.buttonsAlignType
                    precision: precision_setter.value
                    minimumValue: 0.0
                    maximumValue: 100.0
                    step: Math.pow(10,-(precision))
                    editable: true
                    fixed: true
                    //decorateBorders: chkDecorateBorders.checked
                    //doubleClickEdit: chk2click.checked
                    widthButtons: 45
                    onFinishEdit: {
                        value = number
                    }
                }
            }

            CheckBox {
                id: chkEnableSeqGrid
                text: "Включить привязку к сетке шага "+superRealSpinBox.step.toString()+" (можно поменять в коде)"
                checked: false
            }
            CheckBox {
                id: chkEditable
                text: "Включить редактирование"
                checked: true
            }
            CheckBox {
                id: chk2click
                text: "Редактирование по двойному клику"
            }

        }
    }
}
