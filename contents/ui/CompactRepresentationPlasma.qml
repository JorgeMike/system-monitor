import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// Estilo Plasma en el panel: dos barras verticales (CPU y RAM) con los
// colores del tema, como el clásico monitor de carga de KDE.
MouseArea {
    id: compact

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real side: vertical ? width : height

    Layout.minimumWidth: vertical ? -1 : Math.round(side * 0.7)
    Layout.preferredWidth: Layout.minimumWidth
    Layout.minimumHeight: vertical ? Math.round(side * 0.7) : -1
    Layout.preferredHeight: Layout.minimumHeight

    onClicked: root.expanded = !root.expanded

    Row {
        anchors.centerIn: parent
        height: compact.height * 0.8
        spacing: Math.max(2, Math.round(compact.side * 0.08))

        Repeater {
            model: [
                { value: root.cpu, color: Kirigami.Theme.highlightColor },
                { value: root.ram, color: Kirigami.Theme.positiveTextColor }
            ]
            Rectangle {
                required property var modelData
                width: Math.max(4, Math.round(compact.side * 0.22))
                height: parent.height
                radius: 2
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g,
                               Kirigami.Theme.textColor.b, 0.15)
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Math.max(2, parent.height * Math.min(1, modelData.value / 100))
                    radius: 2
                    color: modelData.value >= 90 ? Kirigami.Theme.negativeTextColor : modelData.color
                }
            }
        }
    }
}
