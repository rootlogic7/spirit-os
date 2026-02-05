import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    spacing: 6

    Repeater {
        model: Hyprland.workspaces
        
        delegate: Item {
            // Logik: Nur anzeigen, wenn ID <= 5 (oder Index < 5)
            // Wir nutzen hier index, da Workspace-IDs Lücken haben können.
            visible: index < 5
            width: visible ? 24 : 0
            height: visible ? 24 : 0

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: modelData.active ? "#89b4fa" : "#313244"
                
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    color: modelData.active ? "#1e1e2e" : "#cdd6f4"
                    font.bold: true
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.focused = true
                }
            }
        }
    }
    
    // Kleiner Indikator, falls mehr als 5 Workspaces da sind
    Text {
        visible: Hyprland.workspaces.count > 5
        text: "+"
        color: "#6c7086"
        font.pixelSize: 12
    }
}
