import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../theme"

RowLayout {
    spacing: 15

    // CPU Anzeige
    RowLayout {
        spacing: 6
        Text { 
            text: "" 
            color: Theme.green 
            font: Theme.defaultFont
        }
        Text { 
            id: cpuText
            text: "..." 
            color: Theme.subtext
            font: Theme.defaultFont
        }
    }

    // RAM Anzeige
    RowLayout {
        spacing: 6
        Text { 
            text: "" 
            color: Theme.yellow 
            font: Theme.defaultFont
        }
        Text { 
            id: ramText
            text: "..." 
            color: Theme.subtext
            font: Theme.defaultFont
        }
    }

    // --- LOGIK ---

    // 1. RAM Logic (/proc/meminfo)
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: ramProc.running = true
    }

    Process {
        id: ramProc
        command: ["cat", "/proc/meminfo"]
        
        // FIX: StdioCollector sammelt den Output für uns
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text // 'text' ist eine Eigenschaft des Collectors
                
                const lines = output.split("\n");
                let total = 0;
                let available = 0;
                
                for (let i = 0; i < lines.length; i++) {
                    if (lines[i].includes("MemTotal:")) 
                        total = parseInt(lines[i].match(/\d+/)[0]);
                    if (lines[i].includes("MemAvailable:")) 
                        available = parseInt(lines[i].match(/\d+/)[0]);
                }

                if (total > 0) {
                    const used = (total - available) / 1024 / 1024;
                    const totalGb = total / 1024 / 1024;
                    ramText.text = used.toFixed(1) + " / " + totalGb.toFixed(1) + " GiB";
                }
            }
        }
    }

    // 2. CPU Logic (/proc/loadavg)
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

    Process {
        id: cpuProc
        command: ["cat", "/proc/loadavg"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const output = text
                if (output) {
                    const parts = output.split(" ");
                    cpuText.text = "Load: " + parts[0];
                }
            }
        }
    }
}
