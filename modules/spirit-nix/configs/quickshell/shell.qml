import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io 

import "./components"
import "./theme"

ShellRoot {
    id: root

    property bool isLauncherOpen: false
    // NEU: Status für das Audio-Panel
    property bool isAudioOpen: false 
    property var activePopup: null

    IpcHandler {
        target: "spirit"
        
        function toggle(): void {
            root.isLauncherOpen = !root.isLauncherOpen;
            if (root.isLauncherOpen) root.isAudioOpen = false; // Schließt Audio, wenn Launcher öffnet
        }
        
        // NEU: Befehl für das Audio-Panel
        function toggleAudio(): void {
            root.isAudioOpen = !root.isAudioOpen;
            if (root.isAudioOpen) root.isLauncherOpen = false; // Schließt Launcher, wenn Audio öffnet
        }
    }

    Instantiator {
        model: Quickshell.screens
        delegate: Loader {
            active: true
            sourceComponent: (modelData.name === "DP-1" || modelData.primary) ? mainBar : secondaryBar
            
            Component { id: mainBar; Bar { screen: modelData; shellRoot: root } }
            Component { id: secondaryBar; SecondaryBar { screen: modelData; shellRoot: root } }
        }
    }

    Instantiator {
        model: Quickshell.screens
        delegate: Launcher {
            screen: modelData
            shellRoot: root
            visible: root.isLauncherOpen && (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === modelData.name)
        }
    }

    // NEU: Instantiator für das Audio-Panel
    Instantiator {
        model: Quickshell.screens
        delegate: AudioPanel {
            screen: modelData
            shellRoot: root
            visible: root.isAudioOpen && (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === modelData.name)
        }
    }
}
