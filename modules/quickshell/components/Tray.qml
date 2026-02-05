import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    spacing: 8

    Repeater {
        // Das Modell liefert alle Tray-Items
        model: SystemTray.items

        delegate: Image {
            source: modelData.icon
            width: 20
            height: 20
            fillMode: Image.PreserveAspectFit
            
            MouseArea {
                anchors.fill: parent
                // Rechtsklick öffnet meist das Kontextmenü des Tray-Items
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        modelData.menu.open()
                    } else {
                        modelData.activate()
                    }
                }
            }
        }
    }
}
