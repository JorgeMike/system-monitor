import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Estilo Plasma: barras de progreso estándar y colores del tema.
// Sin gráficas ni formas: lo más ligero posible.
Item {
    id: full

    readonly property int gu: Kirigami.Units.gridUnit

    Layout.minimumWidth: gu * 15
    Layout.minimumHeight: gu * 10
    Layout.preferredWidth: gu * 18
    Layout.preferredHeight: gu * 11

    // Color de alerta del tema cuando el valor es crítico
    function barColor(value, limit) {
        return value >= limit ? Kirigami.Theme.negativeTextColor : Kirigami.Theme.highlightColor
    }

    component Meter: PlasmaComponents3.ProgressBar {
        id: meter
        property real limit: 90
        Layout.fillWidth: true
        from: 0
        to: 100
        // Solo el color de la parte llena cambia al pasar el límite
        Kirigami.Theme.highlightColor: full.barColor(value, limit)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.smallSpacing
        spacing: Kirigami.Units.largeSpacing

        RowLayout {
            Layout.fillWidth: true
            Kirigami.Heading {
                Layout.fillWidth: true
                level: 4
                text: root.host
                elide: Text.ElideRight
            }
            PlasmaComponents3.Label {
                text: root.uptimeSeconds > 0 ? "Encendido hace " + root.formatUptime(root.uptimeSeconds) : ""
                font: Kirigami.Theme.smallFont
                opacity: 0.7
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: Kirigami.Units.largeSpacing
            rowSpacing: Kirigami.Units.smallSpacing

            PlasmaComponents3.Label { text: "CPU" }
            Meter { value: root.cpu }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight
                text: Math.round(root.cpu) + " %"
                font.features: { "tnum": 1 }
            }

            PlasmaComponents3.Label { text: "Memoria" }
            Meter { value: root.ram }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight
                text: root.ramTotalBytes > 0
                    ? root.formatBytes(root.ramUsedBytes) + " / " + root.formatBytes(root.ramTotalBytes, 0)
                    : Math.round(root.ram) + " %"
                font.features: { "tnum": 1 }
            }

            PlasmaComponents3.Label { text: "Temperatura" }
            Meter { value: root.temp; limit: 85 }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight
                text: root.temp > 0 ? Math.round(root.temp) + " °C" : "—"
                font.features: { "tnum": 1 }
            }

            PlasmaComponents3.Label { text: "Disco" }
            Meter { value: root.disk }
            PlasmaComponents3.Label {
                Layout.alignment: Qt.AlignRight
                text: root.diskTotalBytes > 0
                    ? root.formatBytes(root.diskUsedBytes, 0) + " / " + root.formatBytes(root.diskTotalBytes, 0)
                    : Math.round(root.disk) + " %"
                font.features: { "tnum": 1 }
            }

            PlasmaComponents3.Label { text: "Red" }
            PlasmaComponents3.Label {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: "↓ " + root.formatRate(root.down) + "     ↑ " + root.formatRate(root.up)
                font.features: { "tnum": 1 }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
