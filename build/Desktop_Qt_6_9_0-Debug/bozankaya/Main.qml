// === main.qml ===

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15

Window {
    id:window
    width: 800
    height: 600
    visible: true
    title: "Bozankaya Case - Oğuzhan Tunç"

    property var shapeList: []
    property string selectedUdpSocket: ""
    property bool isPublishing: false
    property bool isListening: false
    property var canInterfaces: []
    property string selectedCanInterface: ""
    property string canMessageMode: "List"
    property bool isCanListening: false
    property bool isListeningCan: false

    Component.onCompleted: {
        shapeList = xmlParser.parseScene("scene.xml")
        updateUdpList()
        udpUpdateTimer.start()
        canInterfaces = canManager.getCanInterfaces()
    }


    Timer {
        id: udpUpdateTimer
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            updateUdpList()
        }
    }

    Timer {
        id: canUpdateTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            canInterfaces = canManager.getCanInterfaces()
        }
    }
    Rectangle {
        id: udpArea
        width: parent.width
        height: parent.height / 2
        x: 0
        y: parent.height / 2
        color: "transparent"

            Row {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Rectangle {
                    id: messages
                    width: 2*parent.width/9
                    height: parent.height
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                    Column {
                        anchors.fill: parent
                        spacing: 0
                        padding: 10

                        ListView {
                            id: udpMessagesList
                            width: parent.width
                            height: parent.height / 2
                            model: udpMessagesModel
                            clip: true
                            anchors.horizontalCenter: parent.horizontalCenter
                            delegate: Rectangle {
                                width: parent.width
                                height: 40
                                color: "#ffffff"
                                border.color: "#cccccc"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: Math.max(12, window.width / 65)
                                    color: "black"
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: udpMessagesModel.count === 0
                                text: "No UDP message\nfound to display."
                                color: "#999999"
                                font.pixelSize: 14
                            }
                        }
                        TextArea {
                            id: udpMessageToSend
                            width: parent.width
                            height: parent.height / 2
                            font.pixelSize: Math.max(12, window.width / 65)
                            anchors.horizontalCenter: parent.horizontalCenter
                            placeholderText: "Enter the message to send..."
                            color: "#000000"
                            wrapMode: TextEdit.Wrap
                            background: Rectangle {
                                color: "white"
                                border.color: "#cccccc"
                                border.width: 1
                            }
                        }
                    }
                }
                Rectangle {
                    id: listBackground
                    width: 2*parent.width/9
                    height: parent.height
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1
                    radius: 4
                    Column {
                        anchors.fill: parent
                        spacing: 0
                        padding: 10
                        Text {
                            id:listName
                            text: "UDP Socket List"
                            font.bold: true
                            font.pixelSize: Math.max(16, window.width / 50)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: "#203040"
                        }
                        ListView {
                            id: udpListView
                            width: parent.width
                            height: parent.height - listName.height - refreshButton.height - 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            model: udpListModel
                            clip: true
                            delegate: Rectangle {
                                width: udpListView.width
                                height: 40
                                color: selectedUdpSocket === modelData ? "#cceeff" : "#ffffff"
                                border.color: "#cccccc"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: Math.max(12, window.width / 65)
                                    color: "black"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        selectedUdpSocket = modelData

                                        var parts = selectedUdpSocket.split(":")
                                        if (parts.length === 2) {
                                            addressTextField.text = parts[0]
                                            portTextField.text = parts[1]
                                        }
                                    }
                                }
                            }
                        }
                        Button {
                            id: refreshButton
                            text: "Update UDP Socket List"
                            width: parent.width
                            font.pixelSize: Math.max(12, window.width / 65)
                            height: parent.height/7
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: {
                                updateUdpList()
                            }
                        }
                    }
                }
                Rectangle {
                    id: listenPublishBackground
                    width: 2*parent.width/9
                    height: parent.height
                    color: "#ffffff"
                    border.color: "#cccccc"
                    border.width: 1

                    Column {
                        anchors.fill: parent
                        spacing: 5

                        Rectangle{
                            id: listenBoxes
                            width:parent.width
                            height: parent.height/3
                            border.color: "#cccccc"
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            Column {
                                anchors.fill: parent
                                spacing: 0
                                width:parent.width
                                height:parent.height
                                Rectangle{
                                    id: addressBox
                                    width:parent.width
                                    height: parent.height/2
                                    border.color: "#cccccc"
                                    border.width: 1
                                    Column {
                                        anchors.fill: parent
                                        spacing: 0
                                        width:parent.width
                                        height:parent.height
                                        Text {
                                            id: addressLabel
                                            text: "Address"
                                            width: parent.width
                                            height: parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            color: "#000000"
                                        }
                                        TextField {
                                            id: addressTextField
                                            width: parent.width
                                            height: 2*parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            placeholderText: "Enter Address"
                                            color: "#000000"
                                            horizontalAlignment: Text.AlignHCenter
                                            background: Rectangle {
                                                color: "white"
                                                border.color: "#cccccc"
                                                border.width: 1
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    id: portBox
                                    width:parent.width
                                    height: parent.height/2
                                    border.color: "#cccccc"
                                    border.width: 1
                                    Column {
                                        anchors.fill: parent
                                        spacing: 0
                                        width:parent.width
                                        height:parent.height
                                        Text {
                                            id: portLabel
                                            text: "Port"
                                            width: parent.width
                                            height: parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            color: "#000000"
                                        }
                                        TextField {
                                            id: portTextField
                                            width: parent.width
                                            height: 2*parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            placeholderText: "Enter Port"
                                            color: "#000000"
                                            horizontalAlignment: Text.AlignHCenter
                                            background: Rectangle {
                                                color: "white"
                                                border.color: "#cccccc"
                                                border.width: 1
                                            }
                                        }
                                    }
                                }

                            }
                        }
                        Button {
                            id: listenButton
                            text: isListening ? "Stop Listening" : "Listen"
                            width: parent.width
                            font.pixelSize: Math.max(12, window.width / 65)
                            height: parent.height/7
                            background: Rectangle {
                                color: isListening ? "red" : "green"
                                radius: 4
                            }
                            onClicked: {
                                if (addressTextField.text !== "" && portTextField.text !== "") {
                                    var addressPort = addressTextField.text + ":" + portTextField.text;
                                    var found = false;

                                    for (var i = 0; i < udpListModel.count; i++) {
                                        if (udpListModel.get(i).modelData === addressPort) {
                                            found = true;
                                            break;
                                        }
                                    }

                                    if (!found) {
                                        listenErrorDialog.open();
                                        return;
                                    }

                                    if (!isListening) {
                                        udpMessagesModel.clear();
                                        udpListener.startListening(addressTextField.text, parseInt(portTextField.text))
                                        isListening = true;
                                    } else {
                                        udpListener.stopListening();
                                        isListening = false;
                                    }
                                } else {

                                }
                            }
                        }
                        Rectangle{
                            id: publishBoxes
                            width:parent.width
                            height: parent.height/3
                            border.color: "#cccccc"
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            Column {
                                anchors.fill: parent
                                spacing: 0
                                width:parent.width
                                height:parent.height
                                Rectangle{
                                    id: addressBox2
                                    width:parent.width
                                    height: parent.height/2
                                    border.color: "#cccccc"
                                    border.width: 1
                                    Column {
                                        anchors.fill: parent
                                        spacing: 0
                                        width:parent.width
                                        height:parent.height
                                        Text {
                                            id: addressLabel2
                                            text: "Address"
                                            width: parent.width
                                            height: parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            color: "#000000"
                                        }
                                        TextField {
                                            id: addressTextField2
                                            width: parent.width
                                            height: 2*parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            placeholderText: "Enter Address"
                                            color: "#000000"
                                            horizontalAlignment: Text.AlignHCenter
                                            background: Rectangle {
                                                color: "white"
                                                border.color: "#cccccc"
                                                border.width: 1
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    id: portBox2
                                    width:parent.width
                                    height: parent.height/2
                                    border.color: "#cccccc"
                                    border.width: 1
                                    Column {
                                        anchors.fill: parent
                                        spacing: 0
                                        width:parent.width
                                        height:parent.height
                                        Text {
                                            id: portLabel2
                                            text: "Port"
                                            width: parent.width
                                            height: parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            color: "#000000"
                                        }
                                        TextField {
                                            id: portTextField2
                                            width: parent.width
                                            height: 2*parent.height/3
                                            font.pixelSize: Math.max(12, window.width / 65)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            placeholderText: "Enter Port"
                                            color: "#000000"
                                            horizontalAlignment: Text.AlignHCenter
                                            background: Rectangle {
                                                color: "white"
                                                border.color: "#cccccc"
                                                border.width: 1
                                            }
                                        }
                                    }
                                }

                            }
                        }
                        Button {
                            id: publishButton
                            width: parent.width
                            font.pixelSize: Math.max(12, window.width / 65)
                            height: parent.height/7
                            text: isPublishing ? "Stop Publishing" : "Publish"
                            background: Rectangle {
                                color: isPublishing ? "red" : "green"
                                radius: 4
                            }
                            onClicked: {
                                if (addressTextField2.text !== "" && portTextField2.text !== "" && udpMessageToSend.text !== "") {
                                    if (!isPublishing) {
                                        udpPublisher.startPublishing(addressTextField2.text, parseInt(portTextField2.text), udpMessageToSend.text)
                                        isPublishing = true
                                    } else {
                                        udpPublisher.stopPublishing()
                                        isPublishing = false
                                    }
                                } else {
                                }
                            }

                        }





                    }



                }
                Rectangle {
                    id: verticalDivider
                    width: 2
                    height: parent.height
                    color: "#000000"
                    z: 999
                }
                Rectangle {
                    id: canBackground
                    width: 1*parent.width/3 -15
                    height: parent.height
                    color: "#ffffff"

                    Column{
                        anchors.fill: parent
                        spacing: 2
                        Rectangle {
                            id: headerBackground
                            width: parent.width
                            height: 1*parent.height/12
                            color: "#ffffff"
                            Text {
                                id: canHeader
                                text: "socketCAN"
                                width: parent.width
                                height: parent.height
                                font.pixelSize: Math.max(20, window.width / 65)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: "#000000"
                            }

                    }

                        Rectangle {
                            id: horizontalDivider2
                            width: parent.width
                            height: 2
                            color: "#000000"
                            z: 999
                        }
                        Rectangle {
                            id: canSettingsRect
                            width: parent.width
                            height: parent.height - headerBackground.height -horizontalDivider2.height
                            color: "#ffffff"
                            Row{
                                anchors.fill:parent
                                height: parent.height
                                spacing: 2

                                Rectangle {
                                id: canArea
                                width: 1*parent.width/2
                                height: parent.height
                                color: "#ffffff"
                                border.color: "#cccccc"
                                border.width: 1

                                Column {
                                    anchors.fill: parent
                                    spacing: 5
                                    padding: 10

                                    Text {
                                        id:canListHeader
                                        text: "socketCAN\nInterfaces"
                                        font.pixelSize: Math.max(10, window.width / 70)
                                        font.bold:true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        color: "black"
                                    }

                                    ListView {
                                        id: canListView
                                        width: parent.width
                                        height: parent.height - refreshCanButton.height - canListHeader.height - 20
                                        model: canInterfaces
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        clip: true

                                        delegate: Rectangle {
                                            width: canListView.width
                                            height: canListView.height/4
                                            color: selectedCanInterface === modelData ? "#cceeff" : "#ffffff"
                                            border.color: "#cccccc"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData
                                                font.pixelSize: Math.max(12, window.width / 65)
                                                color: "black"
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    selectedCanInterface = modelData;
                                                    if (selectedCanInterface.startsWith("vcan")) {
                                                        baudrateField.enabled = false;
                                                    } else if (selectedCanInterface.startsWith("can")) {
                                                        baudrateField.enabled = true;
                                                    }
                                                }
                                            }

                                        }
                                    }

                                    Button {
                                        id: refreshCanButton
                                        text: "Update List"
                                        width: parent.width
                                        height: 40
                                        font.pixelSize: 12
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        onClicked: {
                                            canInterfaces = canManager.getCanInterfaces()
                                        }
                                    }
                                }
                            }

                                Rectangle {
                                    id: canSettingsArea
                                    width: parent.width/2
                                    height: parent.height
                                    color: "#ffffff"
                                    border.color: "#cccccc"
                                    border.width: 1
                                    Column{
                                        anchors.fill: parent
                                        spacing: 5
                                        Rectangle {
                                            id: asdsad
                                            width: parent.width
                                            height: parent.height / 2
                                            color: "transparent"
                                            Column{
                                                anchors.fill: parent
                                                spacing: 2


                                            Rectangle {
                                            id: baudrateArea
                                            width: parent.width
                                            height: parent.height / 3
                                            color: "transparent"

                                            Column {
                                                anchors.fill: parent
                                                spacing: 5

                                                Text {
                                                    text: "Baudrate (kbps)"
                                                    font.pixelSize: Math.max(12, window.width / 65)
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    color: "black"
                                                }

                                                TextField {
                                                    id: baudrateField
                                                    width: parent.width * 0.9
                                                    height: parent.height/2
                                                    font.pixelSize: 14
                                                    color: "black"
                                                    enabled: false
                                                    horizontalAlignment: Text.AlignHCenter
                                                    anchors.horizontalCenter: parent.horizontalCenter
                                                    background: Rectangle {
                                                        color: "white"
                                                        border.color: "#cccccc"
                                                        border.width: 1
                                                        radius: 4
                                                    }
                                                }
                                            }
                                            }
                                            Rectangle {
                                                    id: canModeArea
                                                    width: parent.width
                                                    color: "#ffffff"
                                                    height: parent.height/3

                                                    Column {
                                                        anchors.fill: parent
                                                        spacing: 4

                                                        Text {
                                                            text: "Message Mode"
                                                            font.pixelSize: Math.max(12, window.width / 70)
                                                            horizontalAlignment: Text.AlignHCenter
                                                            verticalAlignment: Text.AlignVCenter
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            color: "black"

                                                        }

                                                        ComboBox {
                                                            id: canModeComboBox
                                                            width: parent.width * 0.9
                                                            height: parent.height * 0.5
                                                            model: ["LIST", "UDP"]
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            currentIndex: 0
                                                            onCurrentTextChanged: {
                                                                canMessageMode = currentText;

                                                                if (canMessageMode === "UDP") {
                                                                    udpMessageToSend.enabled = false;
                                                                    udpMessageToSend.text = "";
                                                                } else if (canMessageMode === "LIST") {
                                                                    udpMessageToSend.enabled = true;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            Button {
                                                            id: listenCan
                                                            width: parent.width * 0.9
                                                            height: parent.height / 3
                                                            anchors.horizontalCenter: parent.horizontalCenter
                                                            font.pixelSize: Math.max(12, window.width / 70)
                                                            text: isListeningCan ? "Stop Listening" : "Listen"
                                                            background: Rectangle {
                                                                color: isListeningCan ? "red" : "green"
                                                                radius: 4
                                                            }
                                                            onClicked: {
                                                                if (!isListeningCan) {
                                                                    if (selectedCanInterface.startsWith("can")) {
                                                                        if (baudrateField.text !== "") {
                                                                            var baudrateValue = parseInt(baudrateField.text);
                                                                            if (!isNaN(baudrateValue) && baudrateValue > 0) {
                                                                                canManager.setBaudrate(selectedCanInterface, baudrateValue);
                                                                            } else {
                                                                            }
                                                                        } else {
                                                                        }
                                                                    }

                                                                    canMessagesModel.clear();
                                                                    canManager.startCanListener(selectedCanInterface)
                                                                    isListeningCan = true;
                                                                    canModeComboBox.enabled = false;

                                                                    if (canMessageMode === "UDP") {
                                                                        if (addressTextField2.text !== "" && portTextField2.text !== "") {
                                                                            udpPublisher.startPublishing(
                                                                                addressTextField2.text,
                                                                                parseInt(portTextField2.text),
                                                                                ""
                                                                            );
                                                                            isPublishing = true;
                                                                        } else {
                                                                        }
                                                                    }

                                                                } else {
                                                                    canManager.stopCanListener();
                                                                    isListeningCan = false;
                                                                    canModeComboBox.enabled = true;

                                                                    if (canMessageMode === "UDP") {
                                                                        udpPublisher.stopPublishing();
                                                                        isPublishing = false;
                                                                    }
                                                                }
                                                            }


                                            }
                                        }
                                        }
                                        Rectangle{
                                            id: canMessageListViewRect
                                            width: parent.width
                                            height: parent.height/2
                                            color: "#ffffff"
                                            border.color: "#cccccc"
                                            border.width: 1
                                            ListView {
                                                id: canMessageList
                                                width: parent.width
                                                height: parent.height
                                                model: canMessagesModel
                                                clip: true

                                                delegate: Rectangle {
                                                    width: canMessageList.width
                                                    height: 20
                                                    border.color: "#cccccc"
                                                    border.width: 1

                                                    Row {
                                                        anchors.fill: parent
                                                        spacing: 10

                                                        Text {
                                                            text: model.id
                                                            font.pixelSize: 12
                                                            color: "black"
                                                        }
                                                        Text {
                                                            text: model.dlc
                                                            font.pixelSize: 12
                                                            color: "black"
                                                        }
                                                        Text {
                                                            text: model.data
                                                            font.pixelSize: 12
                                                            color: "black"
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                    }
                            }
                        }
                    }
                }
            }
        }
}

    Rectangle {
        id: horizontalDivider
        width: parent.width
        height: 2
        x: 0
        y: parent.height / 2 - height / 2
        color: "#000000"
        z: 999
    }

    Rectangle {
        id: udpdatavisualizationarea
        width: parent.width
        height: parent.height / 2
        x: 0
        y: 0
        color: "transparent"
        clip: true

        Repeater {
            model: shapeList

            delegate: Item {
                property var shape: modelData

                Rectangle {
                    visible: shape.type === "Rectangle"
                    x: parseInt(shape.x)
                    y: parseInt(shape.y)
                    width: parseInt(shape.width)
                    height: parseInt(shape.height)
                    color: shape.color
                }

                Text {
                    visible: shape.type === "Text"
                    x: parseInt(shape.x)
                    y: parseInt(shape.y)
                    text: shape.text
                    font.pixelSize: parseInt(shape.size)
                    color: shape.color
                }
                Image {
                    visible: modelData.type === "Image"
                    x: parseInt(modelData.x)
                    y: parseInt(modelData.y)
                    width: parseInt(modelData.width)
                    height: parseInt(modelData.height)
                    source: modelData.path ? "qrc:/" + modelData.path : ""
                    fillMode: Image.PreserveAspectFit

                    Component.onCompleted: {
                        console.log("Image source:", source)
                    }
                }

                Shape {
                    visible: shape.type === "Line"
                    anchors.fill: parent

                    ShapePath {
                        strokeWidth: shape.thickness !== undefined ? parseInt(shape.thickness) : 2
                        strokeColor: shape.color !== undefined ? shape.color : "black"
                        startX: shape.x1 !== undefined ? parseInt(shape.x1) : 0
                        startY: shape.y1 !== undefined ? parseInt(shape.y1) : 0

                        PathLine {
                            x: shape.x2 !== undefined ? parseInt(shape.x2) : 0
                            y: shape.y2 !== undefined ? parseInt(shape.y2) : 0
                        }
                    }
                }

                Rectangle {
                    visible: shape.type === "Circle"
                    x: parseInt(shape.cx) - parseInt(shape.radius)
                    y: parseInt(shape.cy) - parseInt(shape.radius)
                    width: parseInt(shape.radius) * 2
                    height: parseInt(shape.radius) * 2
                    radius: width / 2
                    color: shape.color
                }
            }
        }
        Dialog {
            id: errorDialog
            title: "XML Hatası"
            modal: true
            standardButtons: Dialog.Ok

            width: Math.min(window.width * 0.8, errorLabel.paintedWidth + 40)
            height: Math.min(window.height * 0.6, errorLabel.paintedHeight + 80)

            x: (window.width - errorDialog.width) / 2
            y: (window.height - errorDialog.height) / 2

            onWidthChanged: {
                if (errorDialog.visible) {
                    errorDialog.x = (width - errorDialog.width) / 2
                    errorDialog.y = (height - errorDialog.height) / 2
                }
            }
            onHeightChanged: {
                if (errorDialog.visible) {
                    errorDialog.x = (width - errorDialog.width) / 2
                    errorDialog.y = (height - errorDialog.height) / 2
                }
            }

            Label {
                id: errorLabel
                text: ""
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.centerIn: parent
                padding: 10
            }
        }
    }


    Connections {
        target: xmlParser
        onSceneChanged: function(newScene) {
            shapeList = newScene
        }
    }
    Connections {
        target: xmlParser
        onErrorOccurred: function(message) {
            errorLabel.text = message
            errorDialog.open()
        }
    }
    Connections {
        target: udpListener
        onNewMessage: function(message) {
            udpMessagesModel.insert(0, { "modelData": message });
        }
        onErrorOccurred: function(errorMessage) {
            errorDialogText.text = errorMessage;
            errorDialogUDP.open();
        }
    }




    Connections {
        target: canManager
        onNewCanMessage: function(message) {
            var parts = message.split(" ");
            var idIndex = parts.indexOf("ID:") !== -1 ? parts.indexOf("ID:") + 1 : parts.indexOf("ID") + 1;
            var dlcIndex = parts.indexOf("DLC:") !== -1 ? parts.indexOf("DLC:") + 1 : parts.indexOf("DLC") + 1;
            var dataIndex = parts.indexOf("DATA:") !== -1 ? parts.indexOf("DATA:") + 1 : parts.indexOf("DATA") + 1;

            var id = idIndex !== -1 ? parts[idIndex] : "-";
            var dlc = dlcIndex !== -1 ? parts[dlcIndex] : "-";
            var data = dataIndex !== -1 ? parts.slice(dataIndex).join(" ") : "-";

            if (canMessageMode === "LIST") {
                canMessagesModel.insert(0, {
                    "id": id,
                    "dlc": dlc,
                    "data": data
                });
            }
            else if (canMessageMode === "UDP") {
                if (addressTextField2.text !== "" && portTextField2.text !== "") {
                    var udpMessage = id + " " + dlc + " " + data;
                    udpPublisher.startPublishing(
                        addressTextField2.text,
                        parseInt(portTextField2.text),
                        udpMessage
                    );
                } else {
                }
            }
        }
    }




    Dialog {
        id: listenErrorDialog
        title: "Socket Not Found"
        modal: true
        standardButtons: Dialog.Ok
        width: Math.min(window.width * 0.8, listenErrorLabel.paintedWidth + 40)
        height: Math.min(window.height * 0.6, listenErrorLabel.paintedHeight + 80)
        x: (window.width - listenErrorDialog.width) / 2
        y: (window.height - listenErrorDialog.height) / 2

        Label {
            id: listenErrorLabel
            text: "No such UDP socket found in the system."
            anchors.centerIn: parent
            wrapMode: Text.Wrap
            font.pixelSize: 14
        }
    }

    Dialog {
        id: errorDialogUDP
        title: "UDP Error"
        modal: true
        standardButtons: Dialog.Ok
        width: Math.min(window.width * 0.8, errorDialogText.paintedWidth + 40)
        height: Math.min(window.height * 0.6, errorDialogText.paintedHeight + 80)

        x: (window.width - errorDialogUDP.width) / 2
        y: (window.height - errorDialogUDP.height) / 2
        Label {
            id: errorDialogText
            text: ""
            wrapMode: Text.Wrap
            anchors.centerIn: parent
            padding: 10
        }
    }

    ListModel {
        id: udpListModel
    }
    ListModel {
        id: udpMessagesModel
    }
    ListModel {
        id: canMessagesModel
    }

    function parseCanId(msg) {
        var parts = msg.split(" ");
        return parts[1];
    }

    function parseCanDlc(msg) {
        var parts = msg.split(" ");
        return parts[3];
    }

    function parseCanData(msg) {
        var parts = msg.split(" ");
        return parts.slice(5).join(" ");
    }

    function updateUdpList() {
        var udpSockets = udpScanner.scanUdpSockets()
        udpListModel.clear()
        for (var i = 0; i < udpSockets.length; ++i) {
            if (isIPv4Address(udpSockets[i])) {
                udpListModel.append({ "modelData": udpSockets[i] })
            }
        }
    }
    function isIPv4Address(addressPortString) {
        return !addressPortString.startsWith("[")
    }
}
