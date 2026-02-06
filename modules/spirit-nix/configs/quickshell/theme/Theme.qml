pragma Singleton
import QtQuick

QtObject {
    // Base Colors (Catppuccin Mocha)
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"
    
    readonly property color text: "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    
    // Accent (Mauve) - Das hier ändern wir, wenn du das Theme wechselst
    readonly property color accent: "#cba6f7" 
    readonly property color red: "#f38ba8"
    readonly property color green: "#a6e3a1"
    readonly property color yellow: "#f9e2af"
    readonly property color blue: "#89b4fa"

    // Layout
    readonly property int barHeight: 46
    readonly property int radius: 12
    readonly property font defaultFont: Qt.font({ family: "JetBrainsMono Nerd Font", pixelSize: 14, bold: true })
}
