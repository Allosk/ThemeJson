import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs 1.0
import ThemeJson 1.0

ListView {
    id: colorEditor
    property var paletteModel
    property string filterText: ""
    spacing: font.pixelSize / 2
    model: filteredColors()
    clip: true

    property int nameWidth: name_text_metrics.max_width
    property int lightWidth: 0
    property int darkWidth: 0
    property int color_text_min_width: 60

    delegate: Pane {
        id: main_palette
        implicitWidth: ListView.view.width
        padding: 0

        property real lightGradientValue: 0.0
        property real darkGradientValue: 1.0

        ParallelAnimation {
            id: lightAnimation
            NumberAnimation { target: main_palette; property: "lightGradientValue"; to: 0.7; duration: 150 }
            NumberAnimation { target: main_palette; property: "darkGradientValue"; to: 1.0; duration: 150 }
        }

        ParallelAnimation {
            id: defaultAnimation
            NumberAnimation { target: main_palette; property: "lightGradientValue"; to: 0.2; duration: 150 }
            NumberAnimation { target: main_palette; property: "darkGradientValue"; to: 0.8; duration: 150 }
        }

        ParallelAnimation {
            id: darkAnimation
            NumberAnimation { target: main_palette; property: "lightGradientValue"; to: 0.0; duration: 150 }
            NumberAnimation { target: main_palette; property: "darkGradientValue"; to: 0.3; duration: 150 }
        }

        background: Rectangle {
            anchors.fill: parent
            radius: font.pixelSize
            color: "transparent"
        }

        contentItem: RowLayout {
            Label {
                id: __name_label
                Layout.preferredWidth: name_text_metrics.max_width
                padding: font.pixelSize / 3
                text: modelData.name
                font.pixelSize: 18
                color: "#333"
                onTextChanged: name_text_metrics.text = text
                Component.onCompleted: name_text_metrics.text = text
            }

            Rectangle {
                id: deleteButton
                width: 30
                height: 30
                radius: width / 2
                color: "#FFF"
                border.width: 1
                border.color: "#000"
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        paletteModel.removeColor(modelData.name)
                    }
                }

                Text {
                    text: "✖"
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    color: "#e53935"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Pane {
                id: editor_container
                Layout.fillWidth: true
                background: Rectangle {
                    radius: 5
                    border.color:"#000"
                    border.width: root.borderWidth
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: lightGradientValue; color: modelData.light }
                        GradientStop { position: darkGradientValue; color: modelData.dark }
                    }
                }

                contentItem: RowLayout {
                    ColorEditorField {
                        id: light_editor
                        color: modelData.light
                        isLight: true
                        onRequestChangeColor: (requestedColor) => {
                            paletteModel.setColor("light", modelData.name, requestedColor)
                        }
                        Component.onCompleted: {
                            let w = this.implicitWidth - leftInset - rightInset - leftPadding - rightPadding
                            if (w > lightWidth) lightWidth = w
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ColorEditorField {
                        id: dark_editor
                        color: modelData.dark
                        isLight: false
                        onRequestChangeColor: (requestedColor) => {
                            paletteModel.setColor("dark", modelData.name, requestedColor)
                        }
                        Component.onCompleted: {
                            let w = this.implicitWidth - leftInset - rightInset - leftPadding - rightPadding
                            if (w > darkWidth) darkWidth = w
                        }
                    }
                }
            }
        }
    }

    TextMetrics {
        id: name_text_metrics
        property int max_width: 0
        font.pixelSize: 18
        font.bold: true
        onTextChanged: {
            if (width > max_width)
                max_width = width
        }
    }

    component ColorEditorField : Pane {
        id: __color_editor_field
        implicitHeight: 40
        background: Rectangle {
            color: Qt.rgba(255, 255, 0, 0)
            radius: font.pixelSize / 2
        }
        padding: 3

        property string color
        property bool isLight
        signal requestChangeColor(string requestedColor)

        property string inputText: color.length > 1 ? color.substring(1) : ""


        GridLayout {
            columns: 2
            rows: 1

            Pane {
                id: color_text
                padding: font.pixelSize / 2
                Layout.row: 0
                Layout.column: __color_editor_field.isLight ? 1 : 0
                background: Rectangle {
                    color: Material.background
                    radius: font.pixelSize / 2
                    border.color:"#000"
                    border.width: root.borderWidth
                }
                contentItem: RowLayout {
                    Label {
                        text: "#"
                        font.pixelSize: 14
                        color: "#333"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    TextInput {
                        id: colorName
                        font.pixelSize: 14
                        selectByMouse: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        maximumLength: 8
                        height: 10
                        Layout.preferredWidth: color_text_metrics.advanceWidth
                        color: isValidHex("#" + text) ? "black" : "red"
                        text: __color_editor_field.color.substring(1)
                        onAccepted: {
                            if (isValidHex("#" + text)) {
                                __color_editor_field.color = "#" + text
                                requestChangeColor(__color_editor_field.color)
                            }
                        }

                        onActiveFocusChanged: {
                            if (isValidHex("#" + text)) {
                                __color_editor_field.color = "#" + text
                                requestChangeColor(__color_editor_field.color)
                            }

                        }
                    }
                }
            }

            Rectangle {
                width: color_text.implicitHeight
                height: color_text.implicitHeight
                Layout.row: 0
                Layout.column: __color_editor_field.isLight ? 0 : 1
                color: __color_editor_field.color
                border.width: root.borderWidth
                border.color: mouseArea.containsMouse ? "#4A90E2" : getContrastingColor(__color_editor_field.color)
                radius: 5
                Layout.alignment: Qt.AlignHCenter

                ColorDialog {
                    id: colorDialog
                    currentColor: __color_editor_field.color
                    onAccepted: requestChangeColor(this.color)
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        colorDialog.color = __color_editor_field.color
                        colorDialog.open()
                    }
                    onContainsMouseChanged: {
                        if (containsMouse) {
                            isLight ? lightAnimation.start() : darkAnimation.start()
                        } else {
                            defaultAnimation.start()
                        }
                    }
                }
            }
        }
    TextMetrics {
        id: color_text_metrics 
        font.pixelSize: 14
        text: colorName.text  
    }

    }



    function getContrastingColor(hexColor) {
        let color = hexColor.charAt(0) === "#" ? hexColor.substring(1) : hexColor;

        if (color.length !== 6)
            return "black";

        let r = parseInt(color.substr(0, 2), 16);
        let g = parseInt(color.substr(2, 2), 16);
        let b = parseInt(color.substr(4, 2), 16);

        if (r < 30 && g < 30 && b < 30)
            return "white";
        if (r > 225 && g > 225 && b > 225)
            return "black";

        let brightness = (r * 299 + g * 587 + b * 114) / 1000;

        return brightness < 128 ? "white" : "black";
    }

    function filteredColors() {
        if (!filterText || filterText.trim() === "")
            return paletteModel.colors;

        return paletteModel.colors.filter(function(color) {
            return color.name.toLowerCase().indexOf(filterText.toLowerCase()) !== -1;
        });
    }

    function isValidHex(value) {
        return /^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$/.test(value); // допускает и 6, и 8 символов
    }

}
