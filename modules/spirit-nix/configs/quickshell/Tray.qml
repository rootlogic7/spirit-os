import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "theme"

RowLayout {
    spacing: 5
    Repeater {
        model: SystemTray.items
        
        delegate: Image {
            source: modelData.icon
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            fillMode: Image.PreserveAspectFit
            
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) modelData.activate();
                    else if (mouse.button === Qt.RightButton) modelData.menu.open();
                }
            }
        }
    }
}
