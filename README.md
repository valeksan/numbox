# NumBox QML Control
The alternate SpinBox control for double type.

#### 21.10.2017
Complete reworking of the functional.

#### 19.05.2021
Refactory javascript (syntax and view).

#### 20.05.2021
Remade control (light version).

## Example code:
```qml
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 1000
    height: 900
    title: "Пример"

    RowLayout {
        anchors.fill: parent
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Item {
                height: 75
                width: 600
                Text {
                    text: "экспонат (не весь функционал реализован в примере! см. код контрола)"
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
                            value = number; // если так не написать, ничего не будет изменяться!
                        }
                        anchors.centerIn: parent
                    }
                }
            }

            CheckBox {
                id: chkFixedZeros
                text: "Фиксированное отображение нулей"
                checked: true
            }
            Row {
                spacing: 15
                Label {
                    text:"Количество отображаемых чисел после запятой (0 - 10):"
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
                    text: "Точность (0 - 10):"
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
                    text: "Шаг (используется наш контрол):"
                    verticalAlignment: "AlignVCenter"
                    height: parent.height
                }
                NumBox {
                    id: step_setter // установщик шага
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
                text: "Включить привязку к сетке шага " + superRealSpinBox.step.toString() + " (можно поменять в коде)"
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

/*
    Внимание! Чтобы контрол работал, необходимо прописать слот на сигнал finishEdit(number)
    Пример:
        NumBox {
            value: 0
            // ...
            onFinishEdit: {
                control_root.value = number;
            }
        }
    Можно также переопределить метод отображения контрола, добавив внутри него следующее:
        Component.onCompleted: {
            displayTextValue = Qt.binding(function() {
                return (prefix + value/60+":"+(value%60<10?"0"+value%60:value%60) + suffix); // для того чтобы отобразить время в минутах и секундах
            });
        }
        editable: true // чаще всего все это требуется с этим параметром - без ввода (но это не точно, как вам угодно)
*/
```
