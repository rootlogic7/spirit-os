import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "./components"

PanelWindow {
    id: panel
    property var shellRoot: null
    property bool isPrimary: true

    // WICHTIG: visible muss true sein!
    visible: true

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 42 
    color: "#1e1e2e"

    // Debug-Log
    Component.onCompleted: console.log("Bar loaded on: " + (screen ? screen.name : "unknown"))

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 2
        color: "#313244"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 15

        // --- LINKS ---
        Text {
            text: "  KOHAKU"
            color: "#89b4fa"
            font.bold: true
            font.pixelSize: 14
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: if (shellRoot) shellRoot.isLauncherOpen = !shellRoot.isLauncherOpen
            }
        }

        Rectangle { width: 1; height: 16; color: "#45475a" }

        Workspaces {
            Layout.preferredWidth: 5 * 30 
            Layout.alignment: Qt.AlignVCenter
        }

        Rectangle { width: 1; height: 16; color: "#45475a" }

        SystemStats {}

        // --- MITTE ---
        Item { Layout.fillWidth: true }

        // --- RECHTS ---
        Text {
            id: timeText
            color: "#cdd6f4"
            font.bold: true
            font.pixelSize: 14
            Timer {
                interval: 1000; running: true; repeat: true; triggeredOnStart: true
                onTriggered: timeText.text = Qt.formatDateTime(new Date(), "dd. MMM  HH:mm")
            }
        }

        RowLayout {
            visible: isPrimary
            spacing: 15
            
            Rectangle { width: 1; height: 16; color: "#45475a"; visible: parent.visible }
            Tray {}
        }

        Rectangle { width: 1; height: 16; color: "#45475a" }
        
        Text {
            text: "⏻"
            color: "#f38ba8"
            font.pixelSize: 18
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: console.log("Shutdown clicked")
            }
        }
    }
}
