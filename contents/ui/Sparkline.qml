import QtQuick
import QtQuick.Shapes

// Gráfica de línea con relleno degradado. Se recalcula solo cuando llega
// un dato nuevo (cada 2 s), no en cada cuadro.
Item {
    id: spark

    property var values: []
    property real maximum: 0               // 0 = automático
    property int capacity: 30
    property color color: "white"

    readonly property real peak: maximum > 0 ? maximum
        : Math.max(1, ...values) * 1.15

    function point(i, v) {
        const step = width / Math.max(1, capacity - 1)
        const offset = (capacity - values.length) * step
        return Qt.point(offset + i * step, height - Math.min(1, v / peak) * (height - 2) - 1)
    }
    readonly property var line: values.map((v, i) => point(i, v))
    readonly property var area: line.length < 2 ? []
        : [Qt.point(line[0].x, height)].concat(line, [Qt.point(line[line.length - 1].x, height)])

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        visible: spark.line.length >= 2

        ShapePath {
            strokeColor: "transparent"
            fillColor: Qt.rgba(spark.color.r, spark.color.g, spark.color.b, 0.16)
            PathPolyline { path: spark.area }
        }
        ShapePath {
            strokeColor: spark.color
            strokeWidth: 1.6
            fillColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            PathPolyline { path: spark.line }
        }
    }
}
