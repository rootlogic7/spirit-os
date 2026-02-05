import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: launcher
    
    anchors {
        top: true
        left: true
    }

    margins {
        top: 42 // Angepasst an die neue Bar-Höhe
        left: 10
    }

    // FIX: deprecated properties ersetzt
    implicitWidth: 320
    implicitHeight: 450
    
    exclusionMode: ExclusionMode.Ignore

    color: "#1e1e2e"

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: "#89b4fa"
        border.width: 2
        radius: 8
    }

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            text: "Applications"
            color: "#89b4fa"
            font.bold: true
            font.pixelSize: 18
        }

        Repeater {
            model: ["Firefox", "Ghostty", "Files", "Steam", "Reboot"]
            delegate: Text {
                text: "• " + modelData
                color: "#cdd6f4"
                font.pixelSize: 16
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#89b4fa"
                    onExited: parent.color = "#cdd6f4"
                    onClicked: console.log("Launcher: " + modelData)
                }
            }
        }
    }
}
