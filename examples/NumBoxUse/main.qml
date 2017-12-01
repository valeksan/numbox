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
            }
            CheckBox {
                id: chkFixedZeros
                text: "Фиксированное отображение нулей"
                checked: false
            }
            Row {
                spacing: 15
                Label {
                    text:"Количество отображаемых чисел:"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                SpinBox {
                    id: decimals_setter
                    from: 0
                    to: 10
                    value: 0
                }
            }
            Row {
                spacing: 15
                Label {
                    text:"Точность:"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                SpinBox {
                    id: precision_setter
                    from: 0
                    to: 10
                    value: 0
                }
            }
            Row {
                spacing: 15
                Label {
                    text:"Шаг:"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                Components.NumBox {
                    id: step_setter // установщик шага
                    height: 45
                    width: 200
                    value: 0.05
                    buttonsAlignType: 1
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
                id: chkDecorateBorders
                text: "Окантовка"
                checked: true
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
            Text {
                text: "Варианты расположения кнопок:"
            }
            ButtonGroup {
                buttons: groupNumBoxTypes.children
            }
            Column {
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
        }
    }
}
