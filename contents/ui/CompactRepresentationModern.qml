import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3

// En el panel: dos mini medidores (CPU y RAM) con el porcentaje dentro.
MouseArea {
    id: compact

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real side: vertical ? width : height

    Layout.minimumWidth: vertical ? -1 : side * 2 + 2
    Layout.preferredWidth: Layout.minimumWidth
    Layout.minimumHeight: vertical ? side * 2 + 2 : -1
    Layout.preferredHeight: Layout.minimumHeight

    onClicked: root.expanded = !root.expanded

    GridLayout {
        anchors.fill: parent
        columns: compact.vertical ? 1 : 2
        columnSpacing: 2
        rowSpacing: 2

        Repeater {
            model: [
                { value: root.cpu, color: root.levelColor(root.cpuColor, root.cpu, 90) },
                { value: root.ram, color: root.levelColor(root.ramColor, root.ram, 90) }
            ]
            Ring {
                required property var modelData
                Layout.preferredWidth: compact.side
                Layout.preferredHeight: compact.side
                value: modelData.value / 100
                color: modelData.color
                trackColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g,
                                    Kirigami.Theme.textColor.b, 0.15)
                thickness: Math.max(2, compact.side * 0.11)

                PlasmaComponents3.Label {
                    anchors.centerIn: parent
                    text: Math.round(parent.modelData.value)
                    color: Kirigami.Theme.textColor
                    font.pixelSize: Math.round(parent.width * 0.32)
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                    visible: parent.width >= 18
                }
            }
        }
    }
}
