import QtQuick
import Quickshell
import Quickshell.Wayland

import "./components"
import "./theme"

ShellRoot {
    id: root

    // Globale Variablen für Popups
    property bool isLauncherOpen: false
    property var activePopup: null // Für Audio/Netzwerk Popups später

    // Singleton für Theme laden (optional, falls wir es so lösen wollen)
    // Theme {} 

    // Wir suchen explizit nach dem Screen, den wir wollen.
    // Entweder der erste (Index 0) oder der "Primary".
    // Quickshell aktualisiert dieses Model automatisch, wenn Hyprland fertig ist.
    
    Instantiator {
        model: Quickshell.screens
        
        delegate: Loader {
            // Lade die Bar NUR, wenn es der primäre Monitor ist
            // Oder du kannst hartcodieren: modelData.name === "DP-1"
            active: modelData.primary || modelData.name === "DP-1"
            
            sourceComponent: Bar {
              screen: modelData
              shellRoot: root
            }
            
            onLoaded: console.log("Bar loaded on primary screen: " + modelData.name)
        }
    }

    // Launcher (Global, öffnet sich auf dem aktiven Screen)
    Launcher {
        visible: root.isLauncherOpen
    }
}
