import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import ThemeJson 1.0
import QtGraphicalEffects 1.15


ApplicationWindow {
    id: root
    property color backgroundColor:  "#fefefe"
    visible: true
    width: 500
    height: 1000
    minimumWidth: 1000
    minimumHeight: 1000
    title: "Theme Editor"
    color: backgroundColor
    property bool isExpanded: true
    property int borderWidth: 1  


    PaletteModel {
        id: palette
    }

    property int loadButtonShadow: 2
    property int saveButtonShadow: 2
    property int addColorButtonShadow: 2

    property int themeNameShadow : 20
    property int buttonsAnimTime: 120

    property color lightColor: "#ffffff"
    property color darkColor: "#000000"
    property string colorName: ""


    NumberAnimation {
        id: loadButtonUp
        target: root
        property: "loadButtonShadow"
        to: 4
        duration: buttonsAnimTime
    }

    NumberAnimation {
        id: saveButtonUp
        target: root
        property: "saveButtonShadow"
        to: 4
        duration: buttonsAnimTime
    }
    NumberAnimation {
        id: addButtonUp
        target: root
        property: "addColorButtonShadow"
        to: 4
        duration: buttonsAnimTime
    }

    ParallelAnimation {

        id: buttonsDown
        NumberAnimation {
            target: root
            property: "loadButtonShadow"
            to: 2
            duration: buttonsAnimTime
        }
        NumberAnimation {
            target: root
            property: "saveButtonShadow"
            to: 2
            duration: buttonsAnimTime
        }
        NumberAnimation {
            target: root
            property: "addColorButtonShadow"
            to: 2
            duration: buttonsAnimTime
        }
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        Pane {
            Layout.fillWidth: true
            Layout.preferredHeight: root.height * 0.1
            background: Rectangle {
                color: backgroundColor
            }
            contentItem: RowLayout {
                id: header
                property bool editing: false
                property int animationDur: 90

                ColorDialog {
                    id: lightColorDialog
                    title: "Choose Light Color"
                    onAccepted: lightColor = color
                }

                ColorDialog {
                    id: darkColorDialog
                    title: "Choose Dark Color"
                    onAccepted: darkColor = color
                }

                MessageDialog {
                    id: warningDialog
                    title: "Warning"
                    text: "Названия цветов для light и dark должны совпадать!"
                    icon: StandardIcon.Warning
                    standardButtons: StandardButton.Ok
                }

                Pane {
                    padding: 5
                    background: Rectangle {
                        border.color: "#6e6e6e" 
                        radius: 2
                    }
                     TextField {
                        id: searchInput
                        placeholderText: "Search..."
                        Layout.fillWidth: true
                        font.pixelSize: 16
                        background: Rectangle{
                            border.color: searchInput.activeFocus ? "#000000" : "#cccccc"  
                            border.width: root.borderWidth
                            radius: 2
                        }
                        onTextChanged: {
                            colorEditor.filterText = text
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: 10

                    // Pane {
                    //     padding: 5
                    //     background: Rectangle {
                    //         border.color: "#6e6e6e" 
                    //         radius: 2
                    //     }
                    //     TextField {
                    //         id: lightInput
                    //         placeholderText: "Name light color"
                    //         text: lightName
                    //         font.pixelSize: 16
                    //         onTextChanged: lightName = text
                    //         background: Rectangle{
                    //             border.color: lightInput.activeFocus ? "#000000" : "#cccccc"  
                    //             border.width: root.borderWidth
                    //             radius: 2
                    //         }
                    //     }
                    // }
                    Pane {
                        padding: 5
                        background: Rectangle {
                            border.color: "#6e6e6e" 
                            radius: 2
                        }
                        TextField {
                            id: nameColorInput
                            placeholderText: "Name color"
                            text: colorName
                            font.pixelSize: 16
                            onTextChanged: colorName = text
                            background: Rectangle{
                                border.color: nameColorInput.activeFocus ? "#000000" : "#cccccc"  
                                border.width: root.borderWidth
                                radius: 2
                            }                     
                        }
                    }
                    Rectangle {
                        width: 40; height: 40; color: lightColor; radius: 6
                        border.width: 1
                        border.color: "gray"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: lightColorDialog.open()
                        }
                    }
                    Rectangle {
                        width: 40; height: 40; color: darkColor; radius: 6
                        border.width: 1
                        border.color: "gray"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: darkColorDialog.open()
                        }
                    }

                    Button {
                        id: addColorBtn
                        text: "Add Color"
                        font.pixelSize: 16
                        padding: 12
                        background: Rectangle {
                            id: addBackground
                            color: Material.background
                            radius: addColorButtonShadow
                            layer.enabled: true
                            layer.effect: DropShadow {
                                color: "#444444"
                                radius: addColorButtonShadow
                                samples: 16
                                horizontalOffset: addColorButtonShadow
                                verticalOffset: addColorButtonShadow
                            }
                            MouseArea {
                                id: addArea
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onContainsMouseChanged: {
                                    if (containsMouse) {
                                        addButtonUp.start();
                                    }else{
                                        buttonsDown.start();
                                    }
                                }
                                onPressed: {
                                    buttonsDown.start()

                                    if (!palette.loaded) {
                                        warningDialog.text = "Файл с темой не загружен"
                                        warningDialog.open()
                                        return
                                    }

                                    if (colorName === "") {
                                        warningDialog.text = "Пожалуйста, введите имя для цвета"
                                        warningDialog.open()
                                        return
                                    }

                                    if (palette.hasColor("light", colorName) || palette.hasColor("dark", colorName)) {
                                        warningDialog.text = "Цвет с таким именем уже существует"
                                        warningDialog.open()
                                        return
                                    }

                                    palette.setColor("light", colorName, lightColor)
                                    palette.setColor("dark", colorName, darkColor)
                                    palette.save()
                                }
                            }
                        }
                    }
                }
                
                Item {
                    Layout.fillWidth: true
                }
                Button {
                    id: loadButton
                    text: "Load Theme"
                    font.pixelSize: 16
                    padding: 12
                    background: Rectangle {
                        id:loadBackground
                        color: Material.background
                        radius: loadButtonShadow
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#444444"
                            radius: loadButtonShadow
                            samples: 16
                            horizontalOffset: loadButtonShadow
                            verticalOffset: loadButtonShadow
                        }
                        MouseArea {
                            id: loadArea
                            hoverEnabled: true
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onContainsMouseChanged: {
                                if (containsMouse) {
                                    loadButtonUp.start();
                                }else{
                                    buttonsDown.start();
                                }
                            }
                            onPressed: buttonsDown.start();
                            onReleased: fileDialog.open();
                        }
                    }
                    contentItem: Text {
                        text: "Load Theme"
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

                Button {
                    id: saveButton
                    text: "Save Theme"
                    font.pixelSize: 16
                    padding: 12
                    background: Rectangle {
                        color: Material.background
                        radius: saveButtonShadow
                        layer.enabled: true
                        layer.effect: DropShadow {
                            color: "#444444"
                            radius: saveButtonShadow
                            samples: 20
                            horizontalOffset: saveButtonShadow
                            verticalOffset: saveButtonShadow
                        }
                    }
                    MouseArea {
                        id: saveArea
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onContainsMouseChanged: {
                            if (containsMouse) {
                                saveButtonUp.start();
                            }else{
                                buttonsDown.start();
                            }
                        }
                        onPressed: buttonsDown.start();
                        onReleased: {
                            
                            if (!palette.loaded) {
                                warningDialog.text = "Файл с темой не загружен"
                                warningDialog.open()
                                return
                            }
                            
                            palette.save();
                        }
                    }
                }
            }
        }
        Pane{
            Layout.fillWidth: true
            background: Rectangle {
                border.width: root.borderWidth
                border.color: "#6e6e6e"
                radius: 5
                color: "transparent"

            }
            GridLayout{
                rows: 1
                columns: 3
                columnSpacing: 0
                anchors.fill: parent
                Label { 
                    text: "Name:"
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                    Layout.minimumWidth: 230

                }

                Label {
                    text: "Light:"
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft  
                    Layout.fillWidth: true

                }


                Label {
                    text: "Dark:"
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight  
                    Layout.fillWidth: true

                }
            
                
            }

        }


        ColorEditor {
            id: colorEditor
            Layout.fillWidth: true
            Layout.preferredHeight: root.height * 0.84
            paletteModel: palette
        }

    }

    FileDialog {
        id: fileDialog
        title: "Открыть JSON файл темы"
        folder: shortcuts.home
        nameFilters: ["JSON файлы (*.json)"]
        onAccepted: palette.loadFromFile(fileDialog.fileUrl)
    }

}
