import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "components" as Components

ApplicationWindow {
    visible: true
    width: 640
    height: 480
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
                realValue: 0.0
                precision: 2
                minimumValue: -4.55
                maximumValue: 104.75
                enableSequenceGrid: chkEnableSeqGrid.checked //
                realStep: 0.05
                editable: chkEditable.checked
                enableButtons: chkButtons.checked
                suffix: " dB"
                fixed: chkFixedZeros.checked
            }
            CheckBox {
                id: chkFixedZeros
                text: "Фиксированное отображение нулей"
                checked: false
            }
            CheckBox {
                id: chkEnableSeqGrid
                text: "Включить привязку к сетке шага "+superRealSpinBox.realStep.toString()+" (можно поменять в коде)"
                checked: false
            }
            CheckBox {
                id: chkEditable
                text: "Включить редактирование"
                checked: true
            }
            CheckBox {
                id: chkButtons
                text: "Включить кнопки"
                checked: true
            }
        }
    }
}
