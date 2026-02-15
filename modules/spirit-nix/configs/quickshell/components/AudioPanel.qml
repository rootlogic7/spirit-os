import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

import "../theme"

PanelWindow {
    id: audioWindow
    property var shellRoot: null
    
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    
    focusable: true 
    WlrLayershell.layer: WlrLayer.Overlay 

    PwObjectTracker {
        objects: Pipewire.nodes.values
    }

    // Hintergrund fängt Klicks ins Leere ab
    Rectangle {
        anchors.fill: parent
        color: "transparent" 
        MouseArea {
            anchors.fill: parent
            onClicked: if (shellRoot) shellRoot.isAudioOpen = false
        }
    }
    
    Rectangle {
        width: 400 
        height: 320 
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 50 
            rightMargin: 15
        }
        
        color: Theme.base
        radius: 12
        border.color: Theme.surface1
        border.width: 2
        
        MouseArea { anchors.fill: parent } 
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            property var allNodes: Pipewire.nodes.values || []
            property var outputNodes: allNodes.filter(n => n && n.audio && n.description && n.name && n.name.includes("output"))
            property var inputNodes: allNodes.filter(n => n && n.audio && n.description && n.name && n.name.includes("input"))
            
            // === OUTPUT BEREICH ===
            Text {
                text: "󰓃  Output Device"
                color: Theme.text
                font.family: Theme.defaultFont.family
                font.pixelSize: 16
            }
            
            ComboBox {
                id: outputCombo
                Layout.fillWidth: true
                model: parent.outputNodes
                textRole: "description" 
                font.family: Theme.defaultFont.family
                font.pixelSize: 14
                
                currentIndex: {
                    for (var i = 0; i < parent.outputNodes.length; i++) {
                        if (Pipewire.defaultAudioSink && parent.outputNodes[i].id === Pipewire.defaultAudioSink.id) return i;
                    }
                    return -1;
                }
                
                onActivated: (index) => {
                    var selected = parent.outputNodes[index];
                    if (selected) Pipewire.preferredDefaultAudioSink = selected;
                }
                
                background: Rectangle {
                    color: Theme.surface0
                    radius: 8
                    border.color: outputCombo.pressed ? Theme.accent : Theme.surface1
                    border.width: 1
                }
                contentItem: Text {
                    leftPadding: 10
                    text: outputCombo.currentText
                    color: Theme.text
                    font: outputCombo.font
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight 
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "󰕾  Volume"
                    color: Theme.subtext
                    font.family: Theme.defaultFont.family
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: Math.round(outputSlider.value * 100) + "%"
                    color: Theme.subtext
                    font.family: Theme.defaultFont.family
                }
            }
            
            Slider {
                id: outputSlider
                Layout.fillWidth: true
                
                // === DAS IST DER FIX! ===
                // Ohne diese Zeile ist der Slider für die Maus ungreifbar (Höhe: 0).
                implicitHeight: 24 
                
                from: 0.0
                to: 1.0
                stepSize: 0.01
                
                property var activeAudio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
                
                // Empfängt Werte vom System, solange wir den Slider nicht festhalten
                Binding {
                    target: outputSlider
                    property: "value"
                    value: outputSlider.activeAudio ? outputSlider.activeAudio.volume : 0.0
                    when: !outputSlider.pressed
                }
                
                // Sendet deine Mausbewegung an Pipewire
                onMoved: {
                    if (activeAudio) {
                        activeAudio.volume = value;
                    }
                }
                
                background: Rectangle {
                    x: outputSlider.leftPadding
                    y: outputSlider.height / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: outputSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Theme.surface0
                    
                    Rectangle {
                        width: outputSlider.visualPosition * parent.width
                        height: parent.height
                        color: Theme.accent
                        radius: 3
                    }
                }
                handle: Rectangle {
                    x: outputSlider.leftPadding + outputSlider.visualPosition * (outputSlider.availableWidth - width)
                    y: outputSlider.height / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: Theme.base
                    border.color: Theme.accent
                    border.width: 2
                }
            }
            
            // === INPUT BEREICH ===
            Text {
                Layout.topMargin: 10
                text: "󰍬  Input Device"
                color: Theme.text
                font.family: Theme.defaultFont.family
                font.pixelSize: 16
            }
            
            ComboBox {
                id: inputCombo
                Layout.fillWidth: true
                model: parent.inputNodes
                textRole: "description"
                font.family: Theme.defaultFont.family
                font.pixelSize: 14
                
                currentIndex: {
                    for (var i = 0; i < parent.inputNodes.length; i++) {
                        if (Pipewire.defaultAudioSource && parent.inputNodes[i].id === Pipewire.defaultAudioSource.id) return i;
                    }
                    return -1;
                }
                
                onActivated: (index) => {
                    var selected = parent.inputNodes[index];
                    if (selected) Pipewire.preferredDefaultAudioSource = selected;
                }
                
                background: Rectangle {
                    color: Theme.surface0
                    radius: 8
                    border.color: inputCombo.pressed ? Theme.accent : Theme.surface1
                    border.width: 1
                }
                contentItem: Text {
                    leftPadding: 10
                    text: inputCombo.currentText
                    color: Theme.text
                    font: inputCombo.font
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }
}
