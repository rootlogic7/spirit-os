import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    spacing: 15

    // RAM
    RowLayout {
        spacing: 6
        Text { text: ""; color: "#f9e2af"; font.pixelSize: 14 }
        Text { 
            id: ramText
            text: "Loading..." 
            color: "#cdd6f4"
            font.pixelSize: 12
        }
    }

    // CPU
    RowLayout {
        spacing: 6
        Text { text: ""; color: "#a6e3a1"; font.pixelSize: 14 }
        Text { 
            id: cpuText
            text: "Loading..." 
            color: "#cdd6f4"
            font.pixelSize: 12
        }
    }
    
    // --- LOGIK ---
    
    // RAM: Wir lesen /proc/meminfo direkt via "cat" (sicherer als free parsing)
    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: ramProcess.running = true
    }
    
    Process {
        id: ramProcess
        // free -h ist am einfachsten lesbar für Menschen
        command: ["free", "-h"] 
        stdout: function(data) { 
            // Parsing: Zeile "Mem:", 3. Spalte (Used) / 2. Spalte (Total)
            const lines = data.split("\n");
            if (lines.length > 1) {
                const parts = lines[1].match(/\S+/g); // Split by whitespace
                if (parts && parts.length >= 3) {
                    ramText.text = parts[2] + " / " + parts[1];
                }
            }
        }
    }

    // CPU: top kann zickig sein im Batch-Mode. Wir nutzen /proc/loadavg als Fallback oder vmstat
    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: cpuProcess.running = true
    }
    Process {
        id: cpuProcess
        // top im batch mode (-b), 1 iteration (-n1), grep cpu zeile
        command: ["sh", "-c", "top -b -n1 | grep 'Cpu(s)'"]
        stdout: function(data) { 
             // Format: %Cpu(s): 2.5 us, 1.0 sy ... -> Wir wollen user + sys oder idle invertieren
             // Einfacher: Wir nehmen den ersten wert (us)
             const parts = data.match(/(\d+\.\d+)/); 
             if (parts) {
                 cpuText.text = parts[0] + "%";
             }
        }
    }
}
