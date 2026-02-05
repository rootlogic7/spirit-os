import QtQuick
import QtQml // WICHTIG: Für Instantiator
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root
    
    property bool isLauncherOpen: false

    Component.onCompleted: {
        console.log("Quickshell started.")
        console.log("Screens found: " + Quickshell.screens.length)
    }

    // FIX: Instantiator statt Repeater nutzen!
    Instantiator {
        model: Quickshell.screens
        
        delegate: Bar {
            shellRoot: root
            
            // Wir weisen den Screen direkt zu. 
            // PanelWindow hat eine built-in 'screen' Eigenschaft.
            screen: modelData 
            
            isPrimary: index === 0 
        }
        
        // Debug: Bestätigung, wenn eine Bar erstellt wurde
        onObjectAdded: (index, object) => console.log("Bar created for screen index: " + index)
    }

    Launcher {
        visible: root.isLauncherOpen
    }
}
