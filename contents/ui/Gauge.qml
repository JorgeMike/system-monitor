import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

// Medidor con el valor grande al centro, su nombre abajo y un detalle opcional.
Item {
    id: gauge

    property real value: 0          // 0..1
    property string text
    property string caption
    property string detail
    property color color: "white"

    readonly property real ringSize: Math.min(width, Kirigami.Units.gridUnit * 5.2)
    // Siempre se reserva la línea del detalle para que los anillos queden alineados
    implicitHeight: Kirigami.Units.gridUnit * 5.2 + detailLabel.implicitHeight + 2

    Ring {
        id: ring
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: gauge.ringSize
        height: width
        value: gauge.value
        color: gauge.color

        PlasmaComponents3.Label {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
            text: gauge.text
            color: "white"
            font.pixelSize: Math.round(parent.width * 0.22)
            font.weight: Font.Bold
            font.features: { "tnum": 1 }
        }
        PlasmaComponents3.Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Math.round(parent.height * 0.02)
            text: gauge.caption
            color: gauge.color
            font.pixelSize: Math.round(parent.width * 0.11)
            font.weight: Font.DemiBold
        }
    }
    PlasmaComponents3.Label {
        id: detailLabel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: ring.bottom
        anchors.topMargin: 2
        text: gauge.detail !== "" ? gauge.detail : " "
        color: Qt.rgba(1, 1, 1, 0.5)
        font: Kirigami.Theme.smallFont
    }
}
