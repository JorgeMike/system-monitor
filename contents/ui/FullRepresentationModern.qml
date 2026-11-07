import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

// Tarjeta completa. Para gastar poco: nada de capas, blur ni animaciones
// infinitas; solo se redibuja cuando llegan datos nuevos (cada 2 s).
Item {
    id: full

    readonly property int gu: Kirigami.Units.gridUnit
    readonly property real cardRadius: gu * 1.1
    readonly property real shadowMargin: root.inPanel ? 0 : Kirigami.Units.largeSpacing
    readonly property color fgDim: Qt.rgba(1, 1, 1, 0.55)

    Layout.minimumWidth: gu * 18
    // La altura sale del contenido, para que nada se corte
    Layout.minimumHeight: content.implicitHeight + 2 * (full.gu + full.shadowMargin)
    Layout.preferredWidth: gu * 22
    Layout.preferredHeight: Layout.minimumHeight + gu * 2

    // Sombra (shader estático de Kirigami, se dibuja una vez)
    Kirigami.ShadowedRectangle {
        id: card
        anchors.fill: parent
        anchors.margins: full.shadowMargin
        radius: full.cardRadius
        color: "#111418"
        shadow.size: full.shadowMargin > 0 ? 28 : 0
        shadow.yOffset: 6
        shadow.color: Qt.rgba(0, 0, 0, 0.45)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.09)
    }
    // Resplandor de color arriba: un Rectangle con radio, sin máscaras
    Rectangle {
        anchors.fill: card
        anchors.margins: 1
        radius: full.cardRadius - 1
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(0.38, 0.65, 0.98, 0.16) }
            GradientStop { position: 0.4; color: "transparent" }
        }
    }

    component Tile: Rectangle {
        radius: full.gu * 0.7
        color: Qt.rgba(1, 1, 1, 0.045)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
    }

    ColumnLayout {
        id: content
        anchors.fill: card
        anchors.margins: full.gu
        spacing: full.gu * 0.7

        // ---- Encabezado ----
        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Rectangle {
                implicitWidth: full.gu * 2.4
                implicitHeight: implicitWidth
                radius: full.gu * 0.65
                gradient: Gradient {
                    GradientStop { position: 0; color: "#60a5fa" }
                    GradientStop { position: 1; color: "#7c3aed" }
                }
                Image {
                    anchors.centerIn: parent
                    width: Math.round(parent.width * 0.62)
                    height: width
                    source: Qt.resolvedUrl("../images/chip.svg")
                    sourceSize: Qt.size(width, height)
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: root.host
                    color: "white"
                    font.pixelSize: Math.round(full.gu * 1.2)
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                PlasmaComponents3.Label {
                    text: root.uptimeSeconds > 0 ? "Encendido hace " + root.formatUptime(root.uptimeSeconds) : " "
                    color: full.fgDim
                    font: Kirigami.Theme.smallFont
                }
            }
        }

        // ---- Medidores ----
        RowLayout {
            Layout.fillWidth: true
            spacing: full.gu * 0.5

            Gauge {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.minimumWidth: full.gu * 4
                value: root.cpu / 100
                text: Math.round(root.cpu) + "%"
                caption: "CPU"
                color: root.levelColor(root.cpuColor, root.cpu, 90)
            }
            Gauge {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.minimumWidth: full.gu * 4
                value: root.ram / 100
                text: Math.round(root.ram) + "%"
                caption: "RAM"
                detail: root.ramTotalBytes > 0
                    ? root.formatBytes(root.ramUsedBytes) + " / " + root.formatBytes(root.ramTotalBytes, 0) : ""
                color: root.levelColor(root.ramColor, root.ram, 90)
            }
            Gauge {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.minimumWidth: full.gu * 4
                value: root.temp / 100
                text: root.temp > 0 ? Math.round(root.temp) + "°" : "—"
                caption: "TEMP"
                color: root.levelColor(root.tempColor, root.temp, 85)
            }
        }

        // ---- Historial de CPU ----
        Tile {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: full.gu * 3.5

            PlasmaComponents3.Label {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: Kirigami.Units.largeSpacing
                text: "CPU · último minuto"
                color: full.fgDim
                font: Kirigami.Theme.smallFont
            }
            PlasmaComponents3.Label {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Kirigami.Units.largeSpacing
                text: Math.round(root.cpu) + "%"
                color: root.cpuColor
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.weight: Font.Bold
                font.features: { "tnum": 1 }
            }
            Sparkline {
                anchors.fill: parent
                anchors.topMargin: full.gu * 1.6
                anchors.leftMargin: 1
                anchors.rightMargin: 1
                anchors.bottomMargin: 1
                values: root.cpuHistory
                maximum: 100
                capacity: root.historyLength
                color: root.cpuColor
            }
        }

        // ---- Red y disco ----
        RowLayout {
            Layout.fillWidth: true
            spacing: full.gu * 0.5

            Tile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: full.gu * 4

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Kirigami.Units.largeSpacing
                    spacing: 0
                    PlasmaComponents3.Label {
                        text: "Red"
                        color: full.fgDim
                        font: Kirigami.Theme.smallFont
                    }
                    PlasmaComponents3.Label {
                        text: "↓ " + root.formatRate(root.down)
                        color: "white"
                        font.weight: Font.DemiBold
                        font.features: { "tnum": 1 }
                    }
                    PlasmaComponents3.Label {
                        text: "↑ " + root.formatRate(root.up)
                        color: full.fgDim
                        font: Kirigami.Theme.smallFont
                    }
                }
                Sparkline {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 1
                    width: parent.width * 0.45
                    height: parent.height * 0.6
                    values: root.netHistory
                    capacity: root.historyLength
                    color: root.netColor
                }
            }

            Tile {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: full.gu * 4

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.largeSpacing
                    spacing: 2
                    RowLayout {
                        Layout.fillWidth: true
                        PlasmaComponents3.Label {
                            text: "Disco"
                            color: full.fgDim
                            font: Kirigami.Theme.smallFont
                        }
                        Item { Layout.fillWidth: true }
                        PlasmaComponents3.Label {
                            text: Math.round(root.disk) + "%"
                            color: root.levelColor(root.diskColor, root.disk, 90)
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                            font.weight: Font.Bold
                        }
                    }
                    Item { Layout.fillHeight: true }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        color: Qt.rgba(1, 1, 1, 0.09)
                        Rectangle {
                            width: parent.width * Math.min(1, root.disk / 100)
                            height: parent.height
                            radius: 3
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0; color: Qt.lighter(root.diskColor, 1.25) }
                                GradientStop { position: 1; color: root.levelColor(root.diskColor, root.disk, 90) }
                            }
                        }
                    }
                    PlasmaComponents3.Label {
                        text: root.diskTotalBytes > 0
                            ? root.formatBytes(root.diskUsedBytes, 0) + " de " + root.formatBytes(root.diskTotalBytes, 0) : " "
                        color: full.fgDim
                        font: Kirigami.Theme.smallFont
                    }
                }
            }
        }
    }
}
