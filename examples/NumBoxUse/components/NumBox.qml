import QtQuick 2.2

Item {
    id: control_root

    /* Внимание! Чтобы контрол работал, необходимо прописать слот на сигнал finishEdit(number)
      // Пример:
        NumBox {
            value: 0
            // ...
            onFinishEdit: {
                control_root.value = number;
            }
        }
      // Можно также переопределить метод отображения контрола, добавив внутри него следующее
            Component.onCompleted: {
                displayTextValue = Qt.binding(function() {
                    return (prefix + value/60+":"+(value%60<10?"0"+value%60:value%60) + suffix); // для того чтобы отобразить время в минутах и секундах
                });
            }
            editable: true // чаще всего все это требуется с этим параметром - без ввода (но это не точно, как вам угодно)
    */

    property string name    // [Опционально] Имя контрола (нужен если включен параметр enableEditPanel)

    /* Размеры */
    width: 180
    height: 46
    property int widthButtons: height*1.618033988749
    property int widthButtonUp: (buttonsAlignType !== 4) ? widthButtons : width
    property int widthButtonDown: (buttonsAlignType !== 4) ? widthButtons : width
    property int widthSpaces: 3
    property int heightButtons: (buttonsAlignType !== 3) ? ((buttonsAlignType !== 4) ? height : height/4) : (height-widthSpaces)/2
    property int heightButtonUp: heightButtons
    property int heightButtonDown: heightButtons

    /* Вид */
    property color colorValue: "black"
    property color colorValueSelect: "white"
    property color colorBackground: "#f1f3f1"
    property color colorSelect: "black"
    property color colorButtons: "#f7a363"
    property color colorButtonsPressed: "#ace86c"
    property color colorTextButtons: "black"
    property color colorTextButtonsPressed: "black"
    property color colorDecorateBorders: Qt.darker(colorBackground, 1.2)
    property color colorMainPartOfValue: "transparent"  // цвет целой части
    property color colorFractionPartOfValue: "transparent"    // цвет дробной части
    property color colorDotePartOfValue: colorFractionPartOfValue        // цвет точки (по умолчанию заимствует цвет дробной части)
    property color colorSuffix: "transparent"
    property color colorPrefix: "transparent"

    property bool decorateBorders: true
    property int decorateBordersWidth: 1
    property int decorateBordersRadius: 0
    property int buttonsAlignType: 0                        /* Тип выравнивания управляющих кнопок
                                                                ( 0 - отключить показ; 1 - слева и справа; 2 - только справа на 2 клетки; 3 - только справа на 1 клетку; 4 - сверху и снизу;) */
    antialiasing: true                                      // Сглаживание линий
    property int radius: 0                                  // Скругление краев

    /* Шрифты */
    property alias font: displayText.font                   // настройка шрифта отображаемых значений
    property alias fontInEditMode: input.font               // настройка шрифта в режиме ввода значения
    property alias fontButtons: buttonsFontProvider.font    // настройка шрифта для отображения надписей на кнопках
    property alias fontPreffixInEditMode: pre.font          // настройка шрифта для отображения преффикса
    property alias fontSuffixInEditMode: suf.font           // настройка шрифта для отображения cуффикса (измерения)
    Text {
        id: buttonsFontProvider
        visible: false
        font.bold: true
    }

    /* Дополнительные информационные строки */
    property string suffix: ""                  // текст который идет сразу за выводом числа (например можно указать единицу измерения) - "суфикс"
    property string prefix: ""                  // текст который идет сразу перед выводом числа - "префикс"
    property bool visibleSuffixInEdit: true     // показывать "суфикс" при редактировании
    property bool visiblePrefixInEdit: false    // показывать "префикс" при редактировании
    property bool isBoldMainPartOfValue: false      // увеличить жирность числителя в дробных чисел на вывод

    /* Названия кнопок шагового приращения -/+  */
    property string labelButtonUp: "+"          // текст кнопки увеличения значения на шаг приращения
    property string labelButtonDown: "-"        // текст кнопки уменьшения значения на шаг приращения

    /* Функциональные параметры */
    property bool editable: false               // Включить возможность ввода с клавиатуры
    property bool doubleClickEdit: false        // Опция: редактировать только при двойном клике (если включен параметр editable)
    property bool enableEditPanel: false        /* Опция: отправка сигнала showCustomEditPanel начала редактирования вместо редактирования
                                                     (например если имеется своя виртуальная клавиатура ввода, если включен параметр editable) */
    property bool enableMouseWheel: (buttonsAlignType !== 0) // Разрешить приращение значения по step колесом мыши (по умолчанию вкл. если видны кнопки)
    property alias editing: input_area.visible     // Только для чтения: идет редактирование (флаг)

    /* Параметры чисел */
    property string displayTextValue: getDisplayValueString()
    property int precision: 2                   // Точность
    property int decimals: precision            // Сколько знаков после запятой отображать (в режиме отображения действующего значения)
    property double value: 0.0                  // Действительное значение
    property var memory: undefined              // Хранимое в памяти значение
    property double step: 0.0                   // Действительный шаг приращения
    property bool enableSequenceGrid: false     // Включить сетку разрешенных значений по шагу step
    property double minimumValue: -3.40282e+038/2.0 // Действительный минимальный предел (включительно)
    property double maximumValue: 3.40282e+038/2.0    // Действительный максимальный предел (включительно)
    property bool fixed: false                  // Показывать лишние нули в дробной части под точность

    /* Функциональные сигналы*/
    signal finishEdit(var number);              // Сигнал на изменение хранимого реального значения (закомментировать или переопределить обработчик onFinishEdit если сигнал должен обрабатываться как-то по особенному)
    signal showCustomEditPanel(var name, var current); // Сигнал для нужд коннекта к своей клавиатуре ввода (для связи: имя контрола, текущее значение)
    signal clicked(var mouse);                  // Сигнал посылается при клике на контрол
    signal doubleClicked(var mouse);            // Сигнал посылается при двойном клике на контрол
    signal editStart();                         // Началось редактирование с клавиатуры
    signal editEnd();                           // Закончилось редактирование с клавиатуры
    signal up();                                // Сигнал посылается при нажатии кнопки увеличения числа на step (+)
    signal down();                              // Сигнал посылается при нажатии кнопки уменьшения числа на step (-)

    /* Обработка колеса мыши */
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        enabled: enableMouseWheel
        onWheel: {
            if (wheel.angleDelta.y < 0) {
                if(!control_root.editing) parent.down();
                else input_area.decreaseInEditMode();
            } else {
                if(!control_root.editing) parent.up();
                else input_area.increaseInEditMode();
            }
        }
    }

    /* Обработчики нажатий кнопок (по умолчанию) */
    onUp: {
        // можно переопределить
        increase();
    }
    onDown: {
        // можно переопределить
        decrease();
    }

    /* Методы */
    // Послать сигнал на уменьшение значения на step
    function decrease() {
        if(fixValue((value-step),precision) >= minimumValue) {
            finishEdit(fixValue((value - step), precision));
        }
    }
    // Послать сигнал на увеличение значения на step
    function increase() {
        if(fixValue((value+step),precision) <= maximumValue) {
            finishEdit(fixValue((value + step), precision));
        }
    }
    // Сохранить действующее значение в память
    function saveValueInMemory() {
        memory = value;
    }
    // Очистить память от сохраненного ранее значения
    function clearValueInMemory() {
        memory = undefined;
    }
    // Отправить сигнал на замену действующего значения значением из памяти
    function loadValueFromMemory() {
        finishEdit(memory);
    }
    // Копировать значение в буфер обмена
    function copy() {
        clipboard.copy(textFromValue(value, precision));
    }
    // Вставить значение из буфера обмена в сигнал установки действующего значения
    function past() {
        if(clipboard.canPast()) {
            var number = valueFromText(clipboard.past())
            if(valueInRange(number)) {
                if(isNumberInSequenceGrid()) finishEdit(adj(number));
                else finishEdit(number);
            }
        }
    }

    // -------------------------------------------------------------------------------------------
    /* Cистемные методы (не используемые извне) */
    // Метод отображения (который всеже можно переопределить извне, показывать так как нужно)
    function getDisplayValueString() {
        if(value.toString().length > 0) {
            var prefixFull = isColorEmpty(colorPrefix) ? prefix : "<font color=\""+colorPrefix+"\">"+prefix+"</font>";
            var suffixFull = isColorEmpty(colorSuffix) ? suffix : "<font color=\""+colorSuffix+"\">"+suffix+"</font>";
            return (prefixFull + textFromValue(value, decimals) + suffixFull);
        }
        return "";
    }    
    // Преобразование текста в число по формату дефолтной локали окружения
    function valueFromText(text) {
        var doteSymbol = getSystemLocaleDecimalChar();
//        console.log(doteSymbol)
        var index_dote = -1;
        index_dote = text.indexOf(".");
        if(index_dote === -1) {
            index_dote = text.indexOf(",");
        }
//        console.log(index_dote)
        if(index_dote !== -1) {
            text = text.replace(',','.');
        }
        return parseFloat(text);
    }
    function textFromValue(number, precision) {
        var doteSymbol = getSystemLocaleDecimalChar();
        var index_dote = -1;
        var text = number.toFixed(precision);
        var i;
        if(doteSymbol !== '.') {
            text = text.replace('.', doteSymbol);
        }
        index_dote = text.indexOf(doteSymbol);
        if(!fixed && precision > 0) {
            for(i=0; i<precision+1; i++) {
                if(text.charAt(text.length-i-1) !== '0') {
                    text = text.substr(0, text.length-i);
                    break;
                }
            }
            if(text.charAt(text.length-1) === doteSymbol) {
                text = text.substring(0, text.length-1);
            }
        }
        if(isBoldMainPartOfValue && text.length > 0) {
            if(index_dote !== -1) {
                text = [ text.slice(0,index_dote), "</strong>", text.slice(index_dote) ].join('');
                text = "<strong>" + text;
            } else {
                text = "<strong>" + text + "</strong>";
            }
        }
        if(!isColorEmpty(colorMainPartOfValue)) {
            index_dote = text.indexOf(doteSymbol);
            if(index_dote !== -1) {
                text = [ text.slice(0,index_dote), "</font>", text.slice(index_dote) ].join('');
                text = "<font color=\"" + colorMainPartOfValue + "\">" + text;
            } else {
                text = "<font color=\"" + colorMainPartOfValue + "\">" + text + "</strong>";
            }
        }
        if(!isColorEmpty(colorFractionPartOfValue)) {
            index_dote = text.indexOf(doteSymbol);
            if(index_dote !== -1) {
                text = [ text.slice(0,index_dote+1), "<font color=\"" + colorFractionPartOfValue + "\">", text.slice(index_dote+1), "</font>" ].join('');
            }
        }
        if(!isColorEmpty(colorDotePartOfValue)) {
            index_dote = text.indexOf(doteSymbol);
            if(index_dote !== -1) {
                text = [ text.slice(0,index_dote), "<font color=\"" + colorDotePartOfValue + "\">", doteSymbol ,text.slice(index_dote+1), "</font>" ].join('');
            }
        }
        if(name === "testOutput")
            console.log(text);

        return text;
    }
    // Отброс незначащей части числа согласно точности
    function fixValue(x, precision) {
        return Math.round(x*Math.pow(10,precision))/Math.pow(10,precision);
    }    
    // Получить символ разделителя целого числа от дробного в локализации среды
    function getSystemLocaleDecimalChar() {
        return Qt.locale("").decimalPoint;
    }
    // Число входит в сетку последовательности (real_value кратно числу realStep, с точностью precision)
    function isNumberInSequenceGrid(fstep, number, precision) {
        if(isNaN(number)) return false;
        var tmp_value = fixValue(number, precision);
        var valPr = parseInt((tmp_value*Math.pow(10, precision)).toFixed(0));
        var valArgPr = parseInt((fstep*Math.pow(10, precision)).toFixed(0));
        if((valPr % valArgPr) === 0) {
            return true;
        }
        return false; // получившееся значение не кратно шагу последовательности!
    }
    // Привести число к сетки
    function adj(x) {
        return (Math.round((x-minimumValue)/step)*step + minimumValue);
    }
    // Проверка цвета на пустоту
    function isColorEmpty(color_arg) {
        return Qt.colorEqual(color_arg, "transparent");
    }
    // Проверка на вхождение числа в диапазон
    function valueInRange(x) {
        if(x >= minimumValue && x <= maximumValue) return true;
        return false;
    }
    // Завершение редактирования метод
    function valueEditFinisher() {
        if(input.text.length > 0) {
            var rValue = valueFromText(input.text);
            console.log(rValue)
            var newValue = valueFromText(placeholder.text);
            if(rValue !== newValue) {
                if(control_root.enableSequenceGrid) {
                    // проверка на кратность
                    if(isNumberInSequenceGrid(control_root.step, rValue, control_root.precision)) {
                        control_root.finishEdit(rValue);
                    } else {
                        // преобразование к кратному числу
                        var conv_value = adj(rValue);

                        if(conv_value > control_root.maximumValue)
                            conv_value -= control_root.step;

                        conv_value = fixValue(conv_value, control_root.precision);
                        control_root.finishEdit(conv_value);
                    }
                } else {
                    control_root.finishEdit(rValue);
                }
            }
            control_root.editEnd();
            display.forceActiveFocus();
            input.text = "";
        }
    }
    function appendArithmeticalMeanValue()
    {
        if(arithmeticalMeanStackSize > 1) {
            if(__arithmeticalMeanStack.length >= arithmeticalMeanStackSize && __arithmeticalMeanStack.length !== 0) {
                __arithmeticalMeanStack.shift();
            }
            __arithmeticalMeanStack.push(value);
        }
    }
    function meanValue() {
        var sum = 0;
        for(var i=0; i<__arithmeticalMeanStack.length; i++) {
            sum = fixValue(sum + __arithmeticalMeanStack[i], precision);
        }
        return fixValue(sum/__arithmeticalMeanStack.length, precision);
    }

    /* Обработчик исправления ввода FIX_1 (системное) */
    onEnableSequenceGridChanged: {
        if(enableSequenceGrid) {
            if(!isNumberInSequenceGrid(step, value, precision)) {
                finishEdit(adj(value));
            }
        }
    }

    /* Функционал для работы с буфером обмена */
    Item {
        id: clipboard
        property alias buffer: helper.text
        function copy(text) {
            buffer = text;
            helper.selectAll();
            helper.copy();
        }
        function cut(text) {
            buffer = text;
            helper.selectAll();
            helper.cut();
        }
        function canPast() {
            return helper.canPaste;
        }
        function past() {
            if(helper.canPaste) {
                buffer = " ";
                helper.selectAll();
                helper.paste();
                return buffer;
            }
            return "";
        }
        TextEdit {
            id: helper
            text: ""
            visible: false
        }
    }

    Rectangle {
        id: decorateBorderLayer
        function getLeftMargin() {
            if(buttonsAlignType === 1) return widthButtonDown+widthSpaces;
            return 0;
        }
        function getRightMargin() {
            if(buttonsAlignType === 1) return (widthButtonUp + widthSpaces);
            if(buttonsAlignType === 2) return (widthButtonDown + widthButtonUp + 2*widthSpaces);
            if(buttonsAlignType === 3) return ((widthButtonDown > widthButtonUp)?(widthButtonDown+widthSpaces):(widthButtonUp+widthSpaces));
            return 0;
        }
        function getTopMargin() {
            if(buttonsAlignType === 4) return (heightButtonUp + widthSpaces);
            return 0;
        }
        function getBottomMargin() {
            if(buttonsAlignType === 4) return (heightButtonDown + widthSpaces);
            return 0;
        }
        radius: parent.radius
        antialiasing: parent.antialiasing
        anchors.fill: parent
        anchors.leftMargin: getLeftMargin()
        anchors.rightMargin: getRightMargin()
        anchors.topMargin:  getTopMargin()
        anchors.bottomMargin: getBottomMargin()
        color: colorDecorateBorders
        Rectangle {
            id: backgroundLayer
            anchors.fill: parent
            anchors.margins: decorateBorders ? decorateBordersWidth : 0
            radius: !decorateBorders ? parent.radius : 0
            color: colorBackground
            antialiasing: control_root.antialiasing
            Item {
                id: display
                z: 3
                anchors.fill: parent
                clip: true
                visible: !input.activeFocus
                Text {
                    id: displayText
                    text: displayTextValue //getDisplayValueString()
                    color: control_root.colorValue
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    anchors.fill: parent
                    //textFormat: Text.StyledText
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        control_root.clicked(mouse);
                        if(!control_root.doubleClickEdit) {
                            if(control_root.editable) {
                                if(!control_root.enableEditPanel) {
                                    input.forceActiveFocus();
                                    control_root.editStart();
                                } else {
                                    if(control_root.editable) {
                                        control_root.editStart();
                                        control_root.showCustomEditPanel(control_root.name, control_root.value);
                                    }
                                }
                            }
                        } else {
                            mouse.accepted = false;
                        }
                    }
                    onDoubleClicked: {
                        control_root.doubleClicked(mouse);
                        if(control_root.doubleClickEdit) {
                            if(control_root.editable) {
                                if(!control_root.enableEditPanel) {
                                    input.forceActiveFocus();
                                    control_root.editStart();
                                } else {
                                    control_root.editStart();
                                    control_root.showCustomEditPanel(control_root.name, control_root.value);
                                }
                            }
                        } else {
                            mouse.accepted = false;
                        }
                    }
                }
            }
            Item {
                id: input_area
                // Приращение в режиме ввода
                function decreaseInEditMode() {
                    var numberStr, number;
                    if(input.text.length === 0) {
                        numberStr = placeholder.text;
                    } else {
                        numberStr = input.text;
                    }
                    number = fixValue((valueFromText(numberStr) - step), precision);
                    if(number >= minimumValue) {
                        input.text = textFromValue(number, precision);
                    }
                }
                function increaseInEditMode() {
                    var numberStr, number;
                    if(input.text.length === 0) {
                        numberStr = placeholder.text;
                    } else {
                        numberStr = input.text;
                    }
                    number = fixValue((valueFromText(numberStr) + step), precision);
                    if(number <= maximumValue) {
                        input.text = textFromValue(number, precision);
                    }
                }
                visible: !display.visible
                z: 2
                anchors.fill: parent
                TextInput {
                    id: input
                    function fixInput() {
                        var number = valueFromText(text);
                        if(text.length === 0) return false;
                        if(number > maximumValue || number < minimumValue) {
                            text = text.substring(0, text.length-1);
                            //console.log("fix!")
                            return true;
                        }
                        return false;
                    }
                    property int counterToUpErrors: 0
                    property int counterToDownErrors: 0
                    property int counterNumPutSymbols: 0
                    anchors.fill: parent
                    anchors.rightMargin: 3
                    selectByMouse: true
                    text: ""
                    color: control_root.colorValue
                    selectionColor: control_root.colorSelect
                    selectedTextColor: control_root.colorValueSelect
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    readOnly: !control_root.editable
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    validator: DoubleValidator {
                        id: defaultValidator
                        bottom: minimumValue
                        top: maximumValue
                        decimals: control_root.precision
                        notation: DoubleValidator.StandardNotation
                    }
                    Keys.onEscapePressed: {
                        input.counterNumPutSymbols = 0;
                        input.text = "";
                        display.forceActiveFocus();
                        control_root.editEnd();
                    }
                    Keys.onSpacePressed: {
                        if(input.text.length === 0) {
                            input.text = placeholder.text;
                        } else {
                            input.text = "";
                        }
                    }
                    Keys.onReleased: {
                        if(event.key === Qt.Key_M && memory !== undefined) {
                            input.text = textFromValue(memory, precision);
                        } else if(event.key === Qt.Key_C) {
                            input.text = "";
                        } else if(event.key === 46 || event.key === 44) {
                            if(getSystemLocaleDecimalChar() === ',' && event.key === 46) {
                                input.insert(input.cursorPosition, ',');
                            } else if(getSystemLocaleDecimalChar() === '.' && event.key === 44) {
                                input.insert(input.cursorPosition, '.');
                            }
                        }
                        //console.log("Key "+/*String.fromCharCode*/(event.key)+" pressed")
                    }

                    onTextChanged: {                        
                        var number = valueFromText(text)
//                        console.log(number)
                        if(number > maximumValue) {
                            ++counterToUpErrors;
                            if(counterToUpErrors < 2) {
                                text = text.substring(0,text.length-1);
                            } else {
                                counterToUpErrors = 0;
                                text = textFromValue(maximumValue, precision);
                            }
                        } else if(number < minimumValue) {
                            ++counterToDownErrors;
                            if(counterToDownErrors < 2) {
                                text = text.substring(0, text.length-1);
                            } else {
                                counterToDownErrors = 0;
                                text = textFromValue(minimumValue, precision);
                            }
                        }
                        counterNumPutSymbols += 1;
                        if(counterNumPutSymbols < text.length) {
                            while(fixInput());
                        }
                    }
                    onEditingFinished: {
                        counterNumPutSymbols = 0;
                        valueEditFinisher();
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            input.counterNumPutSymbols = 0;
                            display.forceActiveFocus();
                            control_root.editEnd();
                        }
                    }
                }
                Text {
                    id: placeholder
                    text: textFromValue(value, precision)
                    opacity: 0.4
                    visible: input.visible && input.text.length === 0
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    anchors.fill: parent
                    font.pixelSize: input.font.pixelSize
                    font.bold: input.font.pixelSize
                    font.italic: input.font.italic
                    font.capitalization: input.font.capitalization
                    font.family: input.font.family
                    font.strikeout: input.font.strikeout
                    font.overline: input.font.overline
                    font.styleName: input.font.styleName
                    font.weight: input.font.weight
                    font.wordSpacing: input.font.wordSpacing
                }
                Text {
                    id: pre
                    visible: visiblePrefixInEdit ? input.visible : false
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
                    visible: visibleSuffixInEdit ? input.visible : false
                    verticalAlignment: Qt.AlignVCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                }
            }
        }        
    }
    Loader {
        id: buttonUpLoader
        function getRightMargin() {
            if(buttonsAlignType === 2) {
                return (widthButtonDown + widthSpaces);
            }
            return 0;
        }
        anchors.right: parent.right
        anchors.rightMargin: getRightMargin()
        anchors.top: parent.top
        width: widthButtonUp
        height: heightButtonUp
        sourceComponent: (buttonsAlignType !== 0) ? btUpComponent : null
        property bool pressedUp: false
    }
    Loader {
        id: buttonDownLoader
        function getLeftMargin() {
            if(buttonsAlignType === 2) {
                return (decorateBorderLayer.width + widthButtonUp + 2*widthSpaces);
            }
            if(buttonsAlignType === 3) {
                return (decorateBorderLayer.width + widthSpaces);
            }
            return 0;
        }
        anchors.left: parent.left
        anchors.leftMargin: getLeftMargin()
        anchors.bottom: parent.bottom
        width: widthButtonDown
        height: heightButtonDown
        sourceComponent: (buttonsAlignType !== 0) ? btDownComponent : null
        property bool pressedDown: false
    }

    Component {
        id: btUpComponent
        Rectangle {
            width: widthButtonUp
            height: heightButtonUp
            implicitWidth: width
            enabled: (fixValue((value+step), precision) <= maximumValue)
            color: !enabled ? Qt.lighter(control_root.colorButtons, 1.5) : pressedUp ? control_root.colorButtonsPressed : control_root.colorButtons
            border.color: Qt.darker(color, 1.5)
            border.width: 1
            radius: control_root.radius
            antialiasing: control_root.antialiasing
            Text {
                text: labelButtonUp
                font.bold: buttonsFontProvider.font.bold
                font.pixelSize: buttonsFontProvider.font.pixelSize
                font.capitalization: buttonsFontProvider.font.capitalization
                font.family: buttonsFontProvider.font.family
                font.hintingPreference: buttonsFontProvider.font.hintingPreference
                font.italic: buttonsFontProvider.font.italic
                font.overline: buttonsFontProvider.font.overline
                font.strikeout: buttonsFontProvider.font.strikeout
                font.styleName: buttonsFontProvider.font.styleName
                font.underline: buttonsFontProvider.font.underline
                font.weight: buttonsFontProvider.font.weight
                font.wordSpacing: buttonsFontProvider.font.wordSpacing
                color: parent.enabled ? (pressedUp ? control_root.colorTextButtonsPressed : control_root.colorTextButtons) : Qt.lighter(control_root.colorTextButtons, 5.5)
                anchors.fill: parent
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                id: btUpMouseArea
                anchors.fill: parent
                onPressed: {
                    pressedUp = true;
                }
                onReleased: {
                    pressedUp = false;
                    increase();
                }
            }
        }
    }
    Component {
        id: btDownComponent
        Rectangle {
            width: widthButtonDown
            height: heightButtonDown
            implicitWidth: width
            enabled: (fixValue((value-step), precision) >= minimumValue)
            color: !enabled ? Qt.lighter(control_root.colorButtons, 1.5) : pressedDown ? control_root.colorButtonsPressed : control_root.colorButtons
            border.color: Qt.darker(color, 1.5)
            border.width: 1
            radius: control_root.radius
            antialiasing: control_root.antialiasing
            Text {
                text: labelButtonDown
                font.bold: buttonsFontProvider.font.bold
                font.pixelSize: buttonsFontProvider.font.pixelSize
                font.capitalization: buttonsFontProvider.font.capitalization
                font.family: buttonsFontProvider.font.family
                font.hintingPreference: buttonsFontProvider.font.hintingPreference
                font.italic: buttonsFontProvider.font.italic
                font.overline: buttonsFontProvider.font.overline
                font.strikeout: buttonsFontProvider.font.strikeout
                font.styleName: buttonsFontProvider.font.styleName
                font.underline: buttonsFontProvider.font.underline
                font.weight: buttonsFontProvider.font.weight
                font.wordSpacing: buttonsFontProvider.font.wordSpacing
                color: parent.enabled ? (pressedDown ? control_root.colorTextButtonsPressed : control_root.colorTextButtons) : Qt.lighter(control_root.colorTextButtons, 5.5)
                anchors.fill: parent
                fontSizeMode: Text.Fit
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            MouseArea {
                id: btDownMouseArea
                anchors.fill: parent
                onPressed: {
                    pressedDown = true;
                }
                onReleased: {
                    pressedDown = false;
                    decrease();
                }
            }
        }
    }
}
