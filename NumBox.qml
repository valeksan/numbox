import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

NumBoxForm {
    id: control

    // Basic settings
    property int precision: 2               /* Precision (for calculations) */
    property int decimalPlaces: precision   /* How many decimal places to display (for view) */
    property double value: 0.0              /* Actual value */
    property var memory: NaN                /* Stored value */
    property double step: 0.0               /* Actual increment */
    property bool enableSequenceGrid: false /* Enable grid of allowed values by step */
    property double from: -3.40282e+038/2.0 /* Valid minimum limit (inclusive) */
    property alias minimumValue: control.from
    property double to: 3.40282e+038/2.0    /* Valid maximum limit (inclusive) */
    property alias maximumValue: control.to
    property bool fixed: false              /* Show extra zeros in fractional parts for precision */

    // Display settings
    property string suffix: ""              /* The text that follows immediately after the output of the number (for example, you can specify the unit of measurement) */
    property string prefix: ""              /* The text that comes immediately before the output of the number */
    property bool strongIntegerPartOfNumber: false  /* Increase the boldness of the integer part of the number in the textual representation */
    property color colorMainPartOfValue: "transparent"              /* Color of the whole part */
    property color colorFractionPartOfValue: "transparent"          /* Fractional color */
    property color colorDotePartOfValue: colorFractionPartOfValue   /* Point color (defaults to the color of the fractional part) */
    property color colorSuffix: "black"                             /* Suffix text color */
    property color colorPrefix: "transparent"                       /* Prefix text color */
    property bool visibleSuffixInEdit: true /* Show suffix when editing */

    // Functional settings
    property bool editable: false           /* Enable input capability */
    property bool doubleClickEdit: false    /* Option. Edit only on double click (if editable is enabled) */
    property bool enableEditPanel: false    /* Option. Sending the showCustomEditPanel signal to start editing instead of editing (for example, if you have your own virtual keyboard for input, if the editable parameter is enabled) */
    property string displayTextValue: viewRegimeMethods.getDisplayValueString() /* You can override the display method */
    //state: "edit"                         /* To view states in the designer ("view" / "edit") - not used in working state */

    // Functional signals
    signal finishEdit(double number);       /* Signal to change the stored real value. Comment out or override the onFinishEdit handler (if the signal should be processed in a special way) */
    signal showCustomEditPanel(string name, double current); /* Signal for the needs of the connection to your input keyboard (for communication: control name, current value) */
    signal clicked(QtObject mouse);         /* The signal is sent when you click on the control */
    signal doubleClicked(QtObject mouse);   /* The signal is sent when you double click on the control */
    signal editStart();                     /* Signal start editing from the keyboard */
    signal editEnd();                       /* Signal of the end of editing from the keyboard */
    signal up();                            /* Signal is sent when the mouse wheel is scrolled up */
    signal down();                          /* Signal is sent when the mouse wheel is scrolled down */

    padding: 3
    wheelEnabled: editable

    background: Rectangle {
        opacity: enabled ? 1 : 0.3
        Material.elevation: 4
        color: "#EEEEEE"
    }

    Material.foreground: Material.Pink

    // Control methods
    /* Save the current value in memory */
    function saveValueInMemory() {
        memory = value;
    }
    /* Clear memory from a previously saved value */
    function clearValueInMemory() {
        memory = NaN;
    }
    /* Send a signal to replace the actual value with a value from memory */
    function loadValueFromMemory() {
        control.finishEdit(memory);
    }
    /* Copy value to clipboard */
    function copy() {
        clipboard.copy(textFromValue(value, precision));
    }
    /* Paste the value from the clipboard into the signal to set the actual value */
    function past() {
        if (clipboard.canPast()) {
            let number = valueFromText(clipboard.past())
            if (valueInRange(number)) {
                if (mathMethods.isNumberInSequenceGrid())
                    control.finishEdit(mathMethods.adj(number));
                else
                    control.finishEdit(number);
            }
        }
    }

    // Clipboard implementation
    TextEdit {
        id: clipboard
        text: ""
        visible: false

        function copy(_text) {
            clipboard.text = _text;
            selectAll();
            copy();
        }

        function cut(_text) {
            clipboard.text = _text;
            selectAll();
            cut();
        }

        function canPast() {
            return canPaste;
        }

        function past() {
            if (canPaste) {
                clipboard.text = " ";
                selectAll();
                paste();
                return clipboard.text;
            }
            return "";
        }
    }

    // Mouse wheel handling
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        enabled: wheelEnabled
        onWheel: {
            if (wheel.angleDelta.y < 0) {
                if (!inputText.activeFocus)
                    control.down();
                else
                    inputRegimeMethods.decrease();
            } else {
                if (!inputText.activeFocus)
                    control.up();
                else
                    inputRegimeMethods.increase();
            }
        }
    }

    // Setting displayText
    displayText.text: displayTextValue
    displayTextMouseArea.onClicked: {
        control.clicked(mouse);
        if (!control.doubleClickEdit) {
            if (control.editable) {
                if (!control.enableEditPanel) {
                    inputText.forceActiveFocus();
                    control.editStart();
                } else {
                    if (control.editable) {
                        control.editStart();
                        control.showCustomEditPanel(control.name, control.value);
                    }
                }
            }
        } else {
            mouse.accepted = false;
        }
    }
    displayTextMouseArea.onDoubleClicked: {
        control.doubleClicked(mouse);
        if (control.doubleClickEdit) {
            if (control.editable) {
                if (!control.enableEditPanel) {
                    inputText.forceActiveFocus();
                    control.editStart();
                } else {
                    control.editStart();
                    control.showCustomEditPanel(control.name, control.value);
                }
            }
        } else {
            mouse.accepted = false;
        }
    }

    // Setting up inputText
    inputTextMouseArea.onClicked: {
        inputRegimeMethods.counterNumPutSymbols = 0;
        displayText.forceActiveFocus();
        control.editEnd();
    }
    inputText.validator: DoubleValidator {
        bottom: minimumValue
        top: maximumValue
        decimals: control.precision
        notation: DoubleValidator.StandardNotation
    }
    inputText.readOnly: !control.editable
    inputText.inputMethodHints: Qt.ImhFormattedNumbersOnly
    inputText.selectByMouse: true
    inputText.onTextChanged: {
        const number = controlInMethods.valueFromText(inputText.text);
        if (number > maximumValue) {
            inputRegimeMethods.counterToUpErrors += 1;
            if (inputRegimeMethods.counterToUpErrors < 2) {
                inputText.text = inputText.text.substring(0, inputText.text.length - 1);
            } else {
                inputRegimeMethods.counterToUpErrors = 0;
                inputText.text = controlInMethods.textFromValue(maximumValue, precision);
            }
        } else if (number < minimumValue) {
            inputRegimeMethods.counterToDownErrors += 1;
            if (inputRegimeMethods.counterToDownErrors < 2) {
                inputText.text = inputText.text.substring(0, inputText.text.length - 1);
            } else {
                inputRegimeMethods.counterToDownErrors = 0;
                inputText.text = controlInMethods.textFromValue(minimumValue, precision);
            }
        }
        inputRegimeMethods.counterNumPutSymbols += 1;
        if (inputRegimeMethods.counterNumPutSymbols < inputText.text.length) {
            while (inputRegimeMethods.fixInput());
        }
    }
    inputText.onEditingFinished: {
        inputRegimeMethods.counterNumPutSymbols = 0;
        inputRegimeMethods.valueEditFinisher();
    }

    // Setting placeholderText
    placeholderText.text: controlInMethods.textFromValue(value, precision)

    // Setting sufInfoInEdit
    sufInfoInEdit.text: control.suffix

    // Handling keyboard keys in input mode
    Keys.onEscapePressed: {
        if (inputText.activeFocus) {
            inputRegimeMethods.counterNumPutSymbols = 0;
            inputText.text = "";
            displayText.forceActiveFocus();
            control.editEnd();
        }
    }
    Keys.onReleased: {
        if (inputText.activeFocus) {
            if (event.key === Qt.Key_M) {
                inputText.text = controlInMethods.textFromValue(memory, precision);
            } else if (event.key === Qt.Key_C) {
                inputText.text = "";
            } else if (event.key === 46 || event.key === 44) {
                if (controlInMethods.getSystemLocaleDecimalChar() === ',' && event.key === 46) {
                    inputText.insert(inputText.cursorPosition, ',');
                } else if (controlInMethods.getSystemLocaleDecimalChar() === '.' && event.key === 44) {
                    inputText.insert(inputText.cursorPosition, '.');
                }
            }
        }
    }

    QtObject {
        id: controlInMethods
        /* Get integer separator character from fractional in environment localization */
        function getSystemLocaleDecimalChar() {
            return Qt.locale("").decimalPoint;
        }
        /* Checking color for emptiness */
        function isColorEmpty(_color) {
            return Qt.colorEqual(_color, "transparent");
        }
        function textFromValue(_number, _precision) {
            const doteSymbol = getSystemLocaleDecimalChar();
            let index_dote = -1;
            let text = _number.toFixed(_precision);
            if (doteSymbol !== '.') {
                text = text.replace('.', doteSymbol);
            }
            index_dote = text.indexOf(doteSymbol);
            if (!fixed && _precision > 0) {
                for (let i = 0; i < (_precision + 1); i++) {
                    if (text.charAt(text.length - i - 1) !== '0') {
                        text = text.substr(0, text.length - i);
                        break;
                    }
                }
                if (text.charAt(text.length - 1) === doteSymbol) {
                    text = text.substring(0, text.length - 1);
                }
            }
            if (strongIntegerPartOfNumber && text.length > 0) {
                if (index_dote !== -1) {
                    text = [ text.slice(0, index_dote), "</strong>", text.slice(index_dote) ].join('');
                    text = "<strong>" + text;
                } else {
                    text = "<strong>" + text + "</strong>";
                }
            }
            if (!isColorEmpty(colorMainPartOfValue)) {
                index_dote = text.indexOf(doteSymbol);
                if (index_dote !== -1) {
                    text = [ text.slice(0, index_dote), "</font>", text.slice(index_dote) ].join('');
                    text = "<font color=\"" + colorMainPartOfValue + "\">" + text;
                } else {
                    text = "<font color=\"" + colorMainPartOfValue + "\">" + text + "</strong>";
                }
            }
            if (!isColorEmpty(colorFractionPartOfValue)) {
                index_dote = text.indexOf(doteSymbol);
                if (index_dote !== -1) {
                    text = [ text.slice(0, index_dote + 1), "<font color=\"" + colorFractionPartOfValue + "\">", text.slice(index_dote + 1), "</font>" ].join('');
                }
            }
            if (!isColorEmpty(colorDotePartOfValue)) {
                index_dote = text.indexOf(doteSymbol);
                if (index_dote !== -1) {
                    text = [ text.slice(0, index_dote), "<font color=\"" + colorDotePartOfValue + "\">", doteSymbol , text.slice(index_dote + 1), "</font>" ].join('');
                }
            }
            if (control.name === "testOutput") {
                console.log(text);
            }
            return text;
        }
        /* Convert text to number according to the format of the default environment locale */
        function valueFromText(_text) {
            let index_dote = -1;
            let textConv = _text;
            index_dote = textConv.indexOf(".");
            if (index_dote === -1) {
                index_dote = textConv.indexOf(",");
            }
            if (index_dote !== -1) {
                textConv = textConv.replace(',', '.');
            }
            return parseFloat(textConv);
        }
        /* Checking for a number in a range */
        function valueInRange(_x) {
            if (_x >= minimumValue && _x <= maximumValue) {
                return true;
            }
            return false;
        }
    }

    QtObject {
        id: mathMethods
        /* Discarding the insignificant part of the number according to the accuracy */
        function fixValue(_x, _precision) {
            return Math.round(_x * Math.pow(10, _precision)) / Math.pow(10, _precision);
        }
        /* The number is included in the sequence grid (real_value is a multiple of the realStep number, with _precision) */
        function isNumberInSequenceGrid(_fstep, _number, _precision) {
            if (isNaN(_number)) {
                return false;
            }
            let tmp_value = fixValue(_number, _precision);
            let valPr = parseInt((tmp_value * Math.pow(10, _precision)).toFixed(0));
            let valArgPr = parseInt((_fstep * Math.pow(10, _precision)).toFixed(0));
            if ((valPr % valArgPr) === 0) {
                return true;
            }
            return false; // the resulting value is not a multiple of the sequence step!
        }
        /* Bring number to grid */
        function adj(_x) {
            return (Math.round((_x - minimumValue) / step) * step + minimumValue);
        }
    }

    QtObject {
        id: inputRegimeMethods

        property int counterToUpErrors: 0
        property int counterToDownErrors: 0
        property int counterNumPutSymbols: 0

        function fixInput() {
            const number = controlInMethods.valueFromText(inputText.text);
            if (inputText.text.length === 0) {
                return false;
            }
            if (number > maximumValue || number < minimumValue) {
                inputText.text = inputText.text.substring(0, inputText.text.length - 1);
                return true;
            }
            return false;
        }
        /* Completion editing method */
        function valueEditFinisher() {
            if (inputText.text.length > 0) {
                const rValue = controlInMethods.valueFromText(inputText.text);
                const newValue = controlInMethods.valueFromText(placeholderText.text);
                if (rValue !== newValue) {
                    if (control.enableSequenceGrid) {
                        // check for multiples of a sequence step
                        if (mathMethods.isNumberInSequenceGrid(step, rValue, precision)) {
                            control.finishEdit(rValue);
                        } else {
                            // conversion to multiple
                            let conv_value = mathMethods.adj(rValue);
                            if (conv_value > maximumValue) {
                                conv_value -= step;
                            }
                            conv_value = mathMethods.fixValue(conv_value, precision);
                            control.finishEdit(conv_value);
                        }
                    } else {
                        control.finishEdit(rValue);
                    }
                }
                control.editEnd();
                displayText.forceActiveFocus();
                inputText.clear();
            }
        }
        function decrease() {
            let numberStr;
            if (inputText.text.length === 0) {
                numberStr = placeholderText.text;
            } else {
                numberStr = inputText.text;
            }
            const number = mathMethods.fixValue((controlInMethods.valueFromText(numberStr) - step), precision);
            if (number >= minimumValue) {
                inputText.text = controlInMethods.textFromValue(number, precision);
            }
        }
        function increase() {
            let numberStr;
            if (inputText.text.length === 0) {
                numberStr = placeholderText.text;
            } else {
                numberStr = inputText.text;
            }
            const number = mathMethods.fixValue((controlInMethods.valueFromText(numberStr) + step), precision);
            if (number <= maximumValue) {
                inputText.text = controlInMethods.textFromValue(number, precision);
            }
        }
    }

    QtObject {
        id: viewRegimeMethods
        /* Send a signal to increase the value to step */
        function increase() {
            if (mathMethods.fixValue((value + step), precision) <= maximumValue) {
                control.finishEdit(mathMethods.fixValue((value + step), precision));
            }
        }
        /* Send a signal to decrease the value by step */
        function decrease() {
            if (mathMethods.fixValue((value - step), precision) >= minimumValue) {
                control.finishEdit(mathMethods.fixValue((value - step), precision));
            }
        }
        /* Display method (which can still be redefined externally, show as needed) */
        function getDisplayValueString() {
            if (value.toString().length > 0) {
                const prefixFull = controlInMethods.isColorEmpty(colorPrefix) ? prefix : "<font color=\"" + colorPrefix + "\">" + prefix + "</font>";
                const suffixFull = controlInMethods.isColorEmpty(colorSuffix) ? suffix : "<font color=\"" + colorSuffix + "\">" + suffix + "</font>";
                return (prefixFull + controlInMethods.textFromValue(value, decimalPlaces) + suffixFull);
            }
            return "";
        }
    }

    // Signal handlers (default, can be overridden)
    onUp: {
        viewRegimeMethods.increase();
    }
    onDown: {
        viewRegimeMethods.decrease();
    }

    // FIX_1: input correction handler (system)
    onEnableSequenceGridChanged: {
        if (enableSequenceGrid) {
            if (!mathMethods.isNumberInSequenceGrid(step, value, precision)) {
                control.finishEdit(mathMethods.adj(value));
            }
        }
    }
}
