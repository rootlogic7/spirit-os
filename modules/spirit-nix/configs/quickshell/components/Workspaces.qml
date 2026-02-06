import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

import "../theme"

RowLayout {
    spacing: 8

    // FIX: Wir nutzen ein festes Model für Workspaces 1-5
    Repeater {
        model: [1, 2, 3, 4, 5]
        
        delegate: Rectangle {
            width: 32
            height: 32
            radius: 8
            
            // Logik: Ist dieser Workspace gerade aktiv?
            property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData

            // Farbe: Akzent wenn aktiv, Surface0 wenn inaktiv
            color: isActive ? Theme.accent : Theme.surface0
            
            Behavior on color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: modelData
                // Textfarbe: Base (dunkel) wenn aktiv, Text (hell) wenn inaktiv
                color: isActive ? Theme.base : Theme.text
                font: Theme.defaultFont
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                // Hyprland Befehl zum Wechseln senden
                onClicked: Hyprland.dispatch("workspace", modelData)
            }
        }
    }
}
