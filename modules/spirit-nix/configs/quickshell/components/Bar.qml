import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../theme"

PanelWindow {
  id: panel
  property var shellRoot: null
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    implicitHeight: Theme.barHeight
    color: "transparent"

    visible: (Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWindow) 
             ? !Hyprland.focusedMonitor.activeWindow.fullscreen 
             : true

    Rectangle {
        anchors.fill: parent
        color: Theme.base
        opacity: 0.95
        
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 2
            color: Theme.accent
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // FIX: Text-Icon statt Bild
        Text {
            text: "" // NixOS Icon (Nerd Font)
            color: Theme.blue
            
            // FIX: "Property has already been assigned a value" behoben.
            // Wir setzen die Eigenschaften einzeln, damit wir pixelSize ändern dürfen.
            font.family: Theme.defaultFont.family
            font.bold: Theme.defaultFont.bold
            font.pixelSize: 20 
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: shellRoot.isLauncherOpen = !shellRoot.isLauncherOpen
            }
        }

        Workspaces {}

        Item { Layout.fillWidth: true }

        // Window Title
        Rectangle {
            color: Theme.surface0
            radius: Theme.radius
            Layout.preferredHeight: 32
            Layout.preferredWidth: Math.min(400, titleText.implicitWidth + 30)
            visible: titleText.text !== ""
            
            Text {
                id: titleText
                anchors.centerIn: parent
                text: Hyprland.focusedWindow ? Hyprland.focusedWindow.title : ""
                color: Theme.text
                font: Theme.defaultFont // Hier ist es okay (keine Überschreibung)
                elide: Text.ElideRight
                width: parent.width - 20
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Item { Layout.fillWidth: true }

        SystemStats {}

        // Tray (weiterhin auskommentiert)
        // Tray {}

        // Uhr
        Text {
            id: clock
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: Theme.text
            font: Theme.defaultFont
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }
    }
}
