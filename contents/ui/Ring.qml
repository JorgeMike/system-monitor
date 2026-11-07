import QtQuick
import QtQuick.Shapes

// Medidor circular abierto abajo (270°). Se dibuja con Shapes vectoriales:
// sin capas ni efectos, así que redibujarlo cuesta casi nada.
Item {
    id: ring

    property real value: 0                 // 0..1
    property color color: "white"
    property color trackColor: Qt.rgba(1, 1, 1, 0.09)
    property real thickness: Math.max(3, Math.min(width, height) * 0.085)

    // Sin animación a propósito: animar el arco recalcula la curva en cada
    // cuadro y multiplicaba por 7 el consumo de CPU (3.6% → 0.5%).
    readonly property real shown: Math.max(0, Math.min(1, value))

    readonly property real r: (Math.min(width, height) - thickness) / 2

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: ring.trackColor
            strokeWidth: ring.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: ring.width / 2; centerY: ring.height / 2
                radiusX: ring.r; radiusY: ring.r
                startAngle: 135; sweepAngle: 270
            }
        }
        ShapePath {
            strokeColor: ring.color
            strokeWidth: ring.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: ring.width / 2; centerY: ring.height / 2
                radiusX: ring.r; radiusY: ring.r
                startAngle: 135; sweepAngle: Math.max(0.5, 270 * ring.shown)
            }
        }
    }
}
