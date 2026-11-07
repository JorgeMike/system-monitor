import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksysguard.sensors as Sensors

PlasmoidItem {
    id: root

    // ---- Dónde estamos y qué tanto actualizar ----
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                                 || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    // Los detalles (temperatura, red, disco, historial) solo se piden cuando se ven.
    readonly property bool detailsVisible: !inPanel || expanded
    readonly property int interval: detailsVisible ? 2000 : 4000
    readonly property int historyLength: 30          // 30 × 2 s = 1 minuto

    // ---- Sensores: los lee ksystemstats, el mismo servicio de los monitores de Plasma ----
    // No se lanza ningún proceso: solo recibimos valores por D-Bus.
    Sensors.Sensor { id: cpuSensor;  sensorId: "cpu/all/usage";               updateRateLimit: root.interval }
    Sensors.Sensor { id: ramSensor;  sensorId: "memory/physical/usedPercent"; updateRateLimit: root.interval }
    Sensors.Sensor { id: ramUsed;    sensorId: "memory/physical/used";        updateRateLimit: root.interval; enabled: root.detailsVisible }
    Sensors.Sensor { id: ramTotal;   sensorId: "memory/physical/total";       updateRateLimit: 60000;         enabled: root.detailsVisible }
    Sensors.Sensor { id: tempSensor; sensorId: "cpu/all/averageTemperature";  updateRateLimit: root.interval; enabled: root.detailsVisible }
    Sensors.Sensor { id: downSensor; sensorId: "network/all/download";        updateRateLimit: root.interval; enabled: root.detailsVisible }
    Sensors.Sensor { id: upSensor;   sensorId: "network/all/upload";          updateRateLimit: root.interval; enabled: root.detailsVisible }
    Sensors.Sensor { id: diskPct;    sensorId: "disk/all/usedPercent";        updateRateLimit: 30000;         enabled: root.detailsVisible }
    Sensors.Sensor { id: diskUsed;   sensorId: "disk/all/used";               updateRateLimit: 30000;         enabled: root.detailsVisible }
    Sensors.Sensor { id: diskTotal;  sensorId: "disk/all/total";              updateRateLimit: 60000;         enabled: root.detailsVisible }
    Sensors.Sensor { id: uptime;     sensorId: "os/system/uptime";            updateRateLimit: 60000;         enabled: root.detailsVisible }
    Sensors.Sensor { id: hostname;   sensorId: "os/system/hostname";          updateRateLimit: 600000;        enabled: root.detailsVisible }

    function num(s) { const v = Number(s.value); return isFinite(v) ? v : 0 }

    readonly property real cpu: num(cpuSensor)
    readonly property real ram: num(ramSensor)
    readonly property real temp: num(tempSensor)
    readonly property real down: num(downSensor)
    readonly property real up: num(upSensor)
    readonly property real disk: num(diskPct)
    readonly property real ramUsedBytes: num(ramUsed)
    readonly property real ramTotalBytes: num(ramTotal)
    readonly property real diskUsedBytes: num(diskUsed)
    readonly property real diskTotalBytes: num(diskTotal)
    readonly property real uptimeSeconds: num(uptime)
    readonly property string host: hostname.value ? String(hostname.value) : "Sistema"

    // ---- Historial para las gráficas (solo mientras se ve) ----
    property var cpuHistory: []
    property var netHistory: []

    function pushed(arr, v) {
        const a = arr.slice(arr.length >= historyLength ? 1 : 0)
        a.push(v)
        return a
    }
    Timer {
        interval: 2000
        repeat: true
        running: root.detailsVisible
        triggeredOnStart: true
        onTriggered: {
            root.cpuHistory = root.pushed(root.cpuHistory, root.cpu)
            root.netHistory = root.pushed(root.netHistory, root.down)
        }
    }

    // ---- Colores y formatos ----
    readonly property color cpuColor: "#60a5fa"
    readonly property color ramColor: "#a78bfa"
    readonly property color tempColor: "#fb923c"
    readonly property color netColor: "#34d399"
    readonly property color diskColor: "#f472b6"
    readonly property color dangerColor: "#f87171"

    // El color pasa a rojo cuando el valor es crítico.
    function levelColor(base, value, limit) { return value >= limit ? dangerColor : base }

    function formatBytes(b, digits) {
        const units = ["B", "KB", "MB", "GB", "TB"]
        let i = 0
        while (b >= 1024 && i < units.length - 1) { b /= 1024; i++ }
        return b.toFixed(i === 0 ? 0 : (digits ?? 1)) + " " + units[i]
    }
    function formatRate(b) { return formatBytes(b, b >= 1024 * 1024 * 10 ? 0 : 1) + "/s" }
    function formatUptime(s) {
        const d = Math.floor(s / 86400)
        const h = Math.floor((s % 86400) / 3600)
        const m = Math.floor((s % 3600) / 60)
        if (d > 0) return d + " d " + h + " h"
        if (h > 0) return h + " h " + m.toString().padStart(2, "0") + " min"
        return m + " min"
    }

    Plasmoid.icon: "utilities-system-monitor"
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    toolTipMainText: "Monitor del sistema"
    toolTipSubText: "CPU " + Math.round(cpu) + "%  ·  RAM " + Math.round(ram) + "%"

    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
