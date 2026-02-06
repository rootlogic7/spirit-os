import QtQuick
import Quickshell
import Quickshell.Wayland

import "../theme"

PanelWindow {
    id: launcher
    
    anchors {
        top: true
        left: true
        bottom: true
    }
    
    // FIX: implicitWidth statt width
    implicitWidth: 300
    
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.base
        opacity: 0.95
        
        border.width: 1
        border.color: Theme.surface0
        radius: 0 
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "Applications"
            color: Theme.accent
            font.family: Theme.defaultFont.family
            font.bold: true
            font.pixelSize: 20
        }

        Rectangle {
            width: parent.width
            height: 2
            color: Theme.surface0
        }

        Repeater {
            model: ["Firefox", "Ghostty", "Steam", "Discord", "Obsidian"]
            delegate: Rectangle {
                width: parent.width
                height: 40
                color: mouseArea.containsMouse ? Theme.surface0 : "transparent"
                radius: 6

                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    Text {
                        text: "• " + modelData
                        color: Theme.text
                        font: Theme.defaultFont
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.log("Launching: " + modelData)
                    }
                }
            }
        }
    }
}
