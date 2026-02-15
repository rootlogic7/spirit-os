import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

import "../theme"

PanelWindow {
    id: launcherWindow
    property var shellRoot: null
    
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    
    focusable: true 
    WlrLayershell.layer: WlrLayer.Overlay 
    
    Rectangle {
        anchors.fill: parent
        color: Theme.base
        opacity: 0.6 
        
        MouseArea {
            anchors.fill: parent
            onClicked: if (shellRoot) shellRoot.isLauncherOpen = false
        }
    }
    
    Rectangle {
        width: 600
        height: 450
        anchors.centerIn: parent
        color: Theme.base
        radius: 12
        border.color: Theme.accent
        border.width: 2
        
        MouseArea { anchors.fill: parent }
        
        ColumnLayout {
            id: layoutRoot
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            property var allApps: DesktopEntries.applications.values
            property var filteredApps: {
                var query = searchBox.text.toLowerCase();
                if (query === "") return allApps;
                return allApps.filter(app => app && app.name && app.name.toLowerCase().includes(query));
            }
            
            TextField {
                id: searchBox
                Layout.fillWidth: true
                placeholderText: "Search apps..."
                
                font.family: Theme.defaultFont.family
                font.pixelSize: 18
                color: Theme.text
                
                background: Rectangle {
                    color: Theme.surface0
                    radius: 8
                    border.color: searchBox.activeFocus ? Theme.accent : Theme.surface1
                    border.width: 1
                }
                
                Connections {
                    target: launcherWindow
                    function onVisibleChanged() {
                        if (launcherWindow.visible) {
                            searchBox.forceActiveFocus();
                            searchBox.text = ""; 
                            appList.currentIndex = 0;
                        }
                    }
                }
                
                onTextChanged: appList.currentIndex = 0

                Keys.onUpPressed: (event) => {
                    appList.decrementCurrentIndex();
                    event.accepted = true;
                }
                Keys.onDownPressed: (event) => {
                    appList.incrementCurrentIndex();
                    event.accepted = true;
                }
                
                onAccepted: {
                    if (layoutRoot.filteredApps.length > 0 && appList.currentIndex >= 0) {
                        var app = layoutRoot.filteredApps[appList.currentIndex];
                        if (app) app.execute();
                        if (shellRoot) shellRoot.isLauncherOpen = false;
                    }
                }
            }
            
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 5
                
                model: layoutRoot.filteredApps
                currentIndex: 0
                
                delegate: Rectangle {
                    // FIX 1: Direkte ID nutzen statt ListView.view.width
                    width: appList.width 
                    height: 50
                    radius: 8
                    
                    property bool isValid: modelData !== null && modelData !== undefined
                    visible: isValid
                    
                    // FIX 2: Die 100% sichere, eingebaute Methode nutzen
                    property bool isSelected: ListView.isCurrentItem 
                    property bool isHovered: mouseArea.containsMouse
                    
                    color: (isSelected || isHovered) ? Theme.surface1 : "transparent"
                    
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 15
                        text: parent.isValid ? modelData.name : ""
                        color: (isSelected || isHovered) ? Theme.accent : Theme.text
                        font.family: Theme.defaultFont.family
                        font.pixelSize: 16
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        
                        onEntered: {
                            if (parent.isValid) appList.currentIndex = index
                        }
                        
                        onClicked: {
                            if (parent.isValid) {
                                modelData.execute();
                                if (shellRoot) shellRoot.isLauncherOpen = false;
                            }
                        }
                    }
                }
            }
        }
    }
}
