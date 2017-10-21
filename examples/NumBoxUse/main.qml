import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "components" as Components

ApplicationWindow {
    visible: true
    width: 640
    height: 580
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
                precision: 2
                minimumValue: 0.0
                maximumValue: 104.75
                enableSequenceGrid: chkEnableSeqGrid.checked //
                step: 0.05
                editable: chkEditable.checked                
                suffix: " dB"
                fixed: chkFixedZeros.checked
                decorateBorders: chkDecorateBorders.checked
                memory: 3.8
                doubleClickEdit: chk2click.checked
            }
            CheckBox {
                id: chkDecorateBorders
                text: "Окантовка"
                checked: true
            }
            CheckBox {
                id: chkFixedZeros
                text: "Фиксированное отображение нулей"
                checked: false
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
                    checked: true
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
