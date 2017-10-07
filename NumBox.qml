import QtQuick 2.7
import QtQuick.Controls 2.2


Item {
	id: control_root
    property string name                        // [Опционально] Имя контрола (нужен если включен параметр enableEditPanel)

	/* Размеры */
    width: 180
    height: 46
    property int widthButtons: -1
    property int widthButtonUp: widthButtons
    property int widthButtonDown: widthButtons
    property int heightButtons: -1
    property int heightButtonUp: heightButtons
    property int heightButtonDown: heightButtons

    /* Вид */
    property color colorValue: "black"
    property color colorValueSelect: "white"
    property color color: "#f1f3f1"
    property color colorSelect: "black"
    property color colorButton: "#f7a363"
    property color colorButtonPressed: "#ace86c"
    property color colorTextButtons: "black"
    property color colorTextButtonsPressed: "black"
    antialiasing: true 		// Сглаживание линий
    property int radius: 0	// Скругление краев

    /* Шрифт */
    property alias font: controlSpin.font // настройка шрифта

    /* Дополнительные информационные строки */
    property string suffix: ""                  // текст который идет сразу за выводом числа (например можно указать единицу измерения)
    property string prefix: ""                  // текст который идет сразу перед выводом числа
    property string memory: ""                  // текст мелким шрифтом у края (например можно хранить старое значение)

    /* Названия кнопок шагового приращения -/+ */
    property string labelUp: "+"                // текст кнопки увеличения значения на шаг приращения
    property string labelDown: "-"              // текст кнопки уменьшения значения на шаг приращения

	/* Функциональные параметры */
    property bool editable: true                // Включить ручное редактирование
    property bool doubleClickEdit: false 		// Опция: редактировать только при двойном клике (если включен параметр editable)
    property bool enableEditPanel: false 		/* Опция: отправка сигнала showCustomEditPanel начала редактирования вместо редактирования
     												(например если имеется своя виртуальная клавиатура ввода, если включен параметр editable) */
    property bool enableButtons: false 			// Включить отображение кнопок приращения (если включен параметр editable)
    property alias editing: input_area.visible 	// Только для чтения: идет редактирование (флаг)
    property bool enableSequenceGrid: false 	// Включить сетку разрешенных значений по шагу realStepSize

	/* Параметры чисел */
	property int precision: 2 					// Точность  
    property double realValue: 0.0              // Действительное значение
    property double realStep: 0.5               // Действительный шаг приращения
	property double minimumValue: 0.0			// Действительный минимальный предел (включительно)
	property double maximumValue: 1000000.0		// Действительный максимальный предел (включительно)
    property bool fixed: false                  // Показывать лишние нули в дробной части под точность
    property bool validated: true               // Включить валидацию (не давать ввести если неправильно, инач будет подставлено граничное значение)
	
	/* Функциональные сигналы*/
    signal finishEdit(var number);              // Сигнал на изменение хранимого реального значения (закомментировать или переопределить обработчик onFinishEdit если сигнал должен обрабатываться как-то по особенному)
    signal showCustomEditPanel(var name, var current); // Сигнал для нужд коннекта к своей клавиатуре ввода (для связи: имя контрола, текущее значение)
    signal clicked();                           // Сигнал посылается при слике на контрол если параметр editable=false, либо включен параметр doubleClickEdit
    signal editStart();                         // Началось редактирование с клавиатуры
    signal editEnd();                           // Закончилось редактирование с клавиатуры

	/* Для преопределений */
    property alias locale: controlSpin.locale               // Локаль (по умолчанию локаль операционной системы)
    property alias validator: controlSpin.validator 		// Валидатор (если нужен свой)
    property alias textFromValue: controlSpin.textFromValue	// Преобразователь из значения в текст (если нужен свой)
    property alias valueFromText: controlSpin.valueFromText	// Преобразователь из текста в значение (если нужен свой)

    /* Обработчик ввода по умолчанию () */
    // !!! нужно переопределить, если хочется инициализировать действующее значение после какой лиибо манипуляции !!!
    onFinishEdit: {
        control_root.realValue = number
        //console.log(number)
    }

    /* Методы (по аналогии со стандартными от SpinBox) */
    function decrease() {
        if(controlSpin.down.indicator.enabled) {
            control_root.editEnd() // завершать ввод с клавиатуры принудительно, но сохраняет ввод в памяти
            control_root.finishEdit(roundPlus(control_root.realValue - control_root.realStep, precision))
        }
    }
    function increase() {
        if(controlSpin.up.indicator.enabled) {
            control_root.editEnd() // завершать ввод с клавиатуры принудительно, но сохраняет ввод в памяти
            control_root.finishEdit(roundPlus(control_root.realValue + control_root.realStep, precision))
        }
    }

	SpinBox {
        id: controlSpin
        anchors.fill: parent

	    /* Н.У. */ 
        antialiasing: control_root.antialiasing
	    locale: Qt.locale("") 	        
	    font.pointSize: 12
        value: roundPlus(control_root.realValue*Math.pow(10, control_root.precision), 0)
        stepSize: 0
        editable: control_root.editable

		/* Валидатор по умолчанию */
        validator: validated ? defaultValidator : null
        DoubleValidator {
            id: defaultValidator
            bottom: control_root.minimumValue
            top: control_root.maximumValue
            //decimals: control_root.precision
        }

	    /* Пределы */
        from: control_root.minimumValue*Math.pow(10.0, control_root.precision)
        to: control_root.maximumValue*Math.pow(10.0, control_root.precision)

	    /* Преобразователи по умолчанию */
        textFromValue: function(value, locale) {
            return Number(value/Math.pow(10.0, control_root.precision)).toLocaleString(locale, 'f', control_root.precision)
	    }
	    valueFromText: function(text, locale) {
            var value = Number.fromLocaleString(locale, text);
            return value;
	    }	    

	    /* Вспомогательные методы */
        // Получить символ разделителя целого числа от дробного в локализации среды
        function getSystemLocaleDecimalChar() {
            return Qt.locale("").decimalPoint;
        }
        // Преобразование числовой строки в формат posix (для преобразований с помощью javascript)
        function toPosixTextValue(arg) {
            var doteSymbol = getSystemLocaleDecimalChar();
            var strValue = arg;
            if(doteSymbol !== '.') {
                if(strValue.length > 0)
                    strValue = strValue.replace(doteSymbol,'.')
            }
            return strValue;
        }
        // Преобразование числовой строки в формат локализации среды (для отображения)
        function toLocaleTextValue(arg) {
            var doteSymbol = getSystemLocaleDecimalChar();
            var strValue = arg;
            if(doteSymbol !== '.') {
                strValue = strValue.replace('.', doteSymbol)
            } else {
                strValue = strValue.replace(',', doteSymbol)
            }
            return strValue;
        }
	    // Из строкового числа по локали получить строковое число posix (для корректных преобразований с помощью javascript)
	    function simplify(vtext) {
            var value = Number.fromLocaleString(controlSpin.locale, vtext)
            var strValue = control_root.fixed ? value.toFixed(control_root.precision) : value.toString();
            strValue = strValue.replace('.', controlSpin.getLocaleDecimalChar(controlSpin.locale))
	        return strValue;
	    }
	    // Получить символ локали разделителя целого числа от дробной части
	    function getLocaleDecimalChar(locale) {
	        return locale.decimalPoint;
	    }
	    // Округлить число до точности n (n - количество знаков)
	    function roundPlus(x, n) {
	      var m = Math.pow(10,n);
	      return Math.round(x*m)/m;
	    }
        // Число входит в сетку последовательности (real_value кратно числу realStep, с точностью precision)
        function isNumberInSequenceGrid(fstep, real_value, precision) {
	        if(isNaN(real_value)) return false;
            var tmp_value = controlSpin.roundPlus(real_value, precision);
            var valPr = parseInt((tmp_value*Math.pow(10, precision)).toFixed(0));
            var valArgPr = parseInt((fstep*Math.pow(10, precision)).toFixed(0));
	        if((valPr % valArgPr) === 0) {
	            return true;
	        }
	        return false; // получившееся значение не кратно шагу последовательности!
        }
        // Привести число к сетки
        function getCorrectSequenceGridValue(stepSeq, real_value, precision) {
            var result_value = roundPlus(real_value, precision);
            var modulo_value = result_value % stepSeq;
            if(result_value >= roundPlus(stepSeq/2, precision)) {
                result_value -= modulo_value;
                result_value += stepSeq;
            } else if(modulo_value !== 0) {
                result_value -= modulo_value;
            }
            return result_value;
        }

	    /* Кастомизация вида */
	    background: Rectangle {
            color: control_root.color
            border.color: Qt.darker(color, 1.5)
            radius: control_root.radius
            width: control_root.enableButtons ? control_root.width-controlSpin.up.indicator.width-controlSpin.down.indicator.width : control_root.width
            antialiasing: control_root.antialiasing
	    }
        contentItem: Item {
            anchors.fill: parent
            anchors.rightMargin: control_root.enableButtons ? controlSpin.up.indicator.width + controlSpin.down.indicator.width+2 : 2
            anchors.topMargin: 2
            anchors.leftMargin: 2
            anchors.bottomMargin: 2
	        Item {
	            id: display
	            z: 3
	            anchors.fill: parent
	            visible: !input.activeFocus
	            Text {
                    text: control_root.prefix + controlSpin.simplify(controlSpin.textFromValue(controlSpin.value, controlSpin.locale)) + control_root.suffix
                    color: control_root.colorValue
                    font: control_root.font
	                horizontalAlignment: Qt.AlignHCenter
	                verticalAlignment: Qt.AlignVCenter
	                anchors.fill: parent
	            }
	            MouseArea {
                    enabled: control_root.editable
	                anchors.fill: parent
	                onClicked: {
                        if(!control_root.doubleClickEdit) {
                            if(control_root.editable) {
                                if(!control_root.enableEditPanel) {
	                                input.forceActiveFocus()
	                                control_root.editStart()
	                            } else {
	                                control_root.editStart()
                                    control_root.showCustomEditPanel(control_root.name, control_root.realValue)
	                            }
	                        } else {
	                            control_root.clicked()
	                        }
	                    } else {
                            control_root.clicked()
	                        mouse.accepted = false
	                    }
	                }
	                onDoubleClicked: {
                        if(control_root.doubleClickEdit) {
                            if(control_root.editable) {
                                if(!control_root.enableEditPanel) {
	                                input.forceActiveFocus()
	                                control_root.editStart()
	                            } else {
	                                control_root.editStart()
                                    control_root.showCustomEditPanel(control_root.name, control_root.realValue)
	                            }
	                        } else {
	                            control_root.clicked()
	                        }
	                    } else {
	                        mouse.accepted = false
	                    }
	                }
	            }
	            Text {
	                id: mem
	                visible: !input.visible
                    text: (control_root.memory.length > 0 && control_root.memory !== "0") ? control_root.memory + control_root.suffix : ""
	                font.pixelSize: 10
	                verticalAlignment: Qt.AlignVCenter
	                anchors.left: parent.left
	                anchors.leftMargin: 2
	                anchors.bottom: parent.bottom
	                anchors.bottomMargin: 1
	                opacity: 0.4
	            }
	        }
	        Item {
	            id: input_area
	            visible: !display.visible
	            z: 2
	            anchors.fill: parent                
	            TextField {
	                id: input
                    anchors.fill: parent
                    anchors.rightMargin: 3
	                selectByMouse: true
                    background: Item{} //Rectangle { color:"red"; }
	                text: ""                    
                    font: control_root.font
                    color: control_root.colorValue
                    selectionColor: control_root.colorSelect
                    selectedTextColor: control_root.colorValueSelect
	                horizontalAlignment: Qt.AlignHCenter                    
	                verticalAlignment: Qt.AlignVCenter
                    readOnly: !control_root.editable
                    validator: text.length > 0 ? controlSpin.validator : null
	                inputMethodHints: Qt.ImhFormattedNumbersOnly
	                focusReason: Qt.MouseFocusReason
                    onEditingFinished: {
                        if(text.length > 0) {
                            var rValue = controlSpin.valueFromText(text, locale)
                            var newValue = controlSpin.valueFromText(placeholder.text, locale)
                            if(rValue !== newValue) {
                                if(control_root.enableSequenceGrid) {
                                    // проверка на кратность
                                    if(controlSpin.isNumberInSequenceGrid(control_root.realStep, rValue, control_root.precision)) {
                                        control_root.finishEdit(rValue)
                                        console.log("rValue:"+rValue)
                                    } else {
                                        // преобразование к кратному числу
                                        console.log("rValue:"+rValue)
                                        var conv_value = controlSpin.getCorrectSequenceGridValue(control_root.realStep, rValue, control_root.precision);
                                        if(conv_value > control_root.maximumValue) conv_value -= control_root.realStep;
                                        conv_value = controlSpin.roundPlus(conv_value, control_root.precision)
                                        control_root.finishEdit(conv_value)
                                        console.log("rValueFix:"+conv_value)
                                    }
                                } else {
                                    console.log("rValue:"+rValue)
                                    control_root.finishEdit(rValue)
                                }
                            }
                            control_root.editEnd()
                            display.forceActiveFocus()
                            input.text = ""
                        }
                    }
	                MouseArea {
	                    anchors.fill: parent
	                    onClicked: {
	                        display.forceActiveFocus()
	                        control_root.editEnd()
	                    }
	                }
	            }
	            Text {
	                id: placeholder
                    text: controlSpin.simplify(controlSpin.textFromValue(controlSpin.value, locale))
	                opacity: 0.4
	                visible: input.visible && input.text.length === 0
                    font: controlSpin.font
	                horizontalAlignment: Qt.AlignHCenter
	                verticalAlignment: Qt.AlignVCenter
	                anchors.fill: parent
	            }
	            Text {
	                id: pre
	                visible: input.visible
                    text: control_root.prefix
	                font.pixelSize: 10
	                verticalAlignment: Qt.AlignVCenter
	                anchors.left: parent.left
	                anchors.leftMargin: 5
	                anchors.bottom: parent.bottom
	                anchors.bottomMargin: 2
	            }
	            Text {
	                id: suf
                    text: control_root.suffix
	                font.pixelSize: 10
	                visible: input.visible
	                verticalAlignment: Qt.AlignVCenter
	                anchors.right: parent.right
	                anchors.rightMargin: 5
	                anchors.bottom: parent.bottom
	                anchors.bottomMargin: 2
	            }
	        }        
	    }

	    /* Подгрузка кнопок приращения */
	    up.indicator: Loader {
	        id: loaderUpButton        
            sourceComponent: control_root.enableButtons ? btUpComponent : null
            x: control_root.width - 2*width + 1
            visible: control_root.enableButtons
	        anchors.verticalCenter: parent.verticalCenter
            property string labelText: control_root.labelUp //"+"
	    }
        up.onPressedChanged: {
            if(up.pressed && control_root.enableButtons) {
                control_root.finishEdit(controlSpin.roundPlus(control_root.realValue + control_root.realStep, control_root.precision))
                control_root.editEnd()
            }
        }
	    down.indicator: Loader {
	        id: loaderDownButton        
            sourceComponent: control_root.enableButtons ? btDownComponent : null
            x: control_root.width - width + 2
            visible: control_root.enableButtons
	        anchors.verticalCenter: parent.verticalCenter
            property string labelText: control_root.labelDown //"-"
	    }
        down.onPressedChanged: {
            if(down.pressed && control_root.enableButtons) {
                control_root.finishEdit(controlSpin.roundPlus(control_root.realValue - control_root.realStep, control_root.precision))
                control_root.editEnd()
            }
        }

	    /* Подгружаемые компоненты */
	    Component {
	        id: btUpComponent
	        Rectangle {
                height: control_root.height
                implicitWidth: control_root.widthButtonUp === -1 ? (control_root.width >= 180 ? 40 : control_root.width*0.2 - 1) : control_root.widthButtonUp
                implicitHeight: control_root.heightButtonUp === -1 ? control_root.height : control_root.heightButtonUp
                width: implicitWidth
                color: !enabled ? Qt.lighter(control_root.colorButton, 1.5) : controlSpin.up.pressed ? control_root.colorButtonPressed : control_root.colorButton
	            border.color: Qt.darker(color, 1.5)
	            border.width: 1
                radius: control_root.radius
                antialiasing: control_root.antialiasing                
	            Text {
	                text: labelText
                    font.pixelSize: controlSpin.font.pixelSize*3/2
	                font.bold: true
                    color: parent.enabled ? (controlSpin.up.pressed ? control_root.colorTextButtonsPressed : control_root.colorTextButtons) : Qt.lighter(control_root.colorTextButtons, 5.5)
	                anchors.fill: parent
	                fontSizeMode: Text.Fit
	                horizontalAlignment: Text.AlignHCenter
	                verticalAlignment: Text.AlignVCenter
	            }
	        }
	    }
	    Component {
	        id: btDownComponent
	        Rectangle {
                height: control_root.height
                implicitWidth: control_root.widthButtonDown === -1 ? (control_root.width >= 180 ? 40 : control_root.width*0.2 - 1) : control_root.widthButtonDown
                implicitHeight: control_root.heightButtonDown === -1 ? control_root.height : control_root.heightButtonDown
                width: implicitWidth
                color: !enabled ? Qt.lighter(control_root.colorButton, 1.5) : controlSpin.down.pressed ? control_root.colorButtonPressed : control_root.colorButton
	            border.color: Qt.darker(color, 1.5)
	            border.width: 1
                radius: control_root.radius
                antialiasing: control_root.antialiasing                
	            Text {
	                text: labelText
                    font.pixelSize: controlSpin.font.pixelSize*3/2
	                font.bold: true
                    color: parent.enabled ? (controlSpin.down.pressed ? control_root.colorTextButtonsPressed : control_root.colorTextButtons) : Qt.lighter(control_root.colorTextButtons, 5.5)
	                anchors.fill: parent
	                fontSizeMode: Text.Fit
	                horizontalAlignment: Text.AlignHCenter
	                verticalAlignment: Text.AlignVCenter
	            }
	        }
	    }
	}
}
