import QtQuick 2.2

import org.kde.plasma.core 2.0 as PlasmaCore

import QtQuick.Controls.Styles 1.4 as QQCS
import QtQuick.Controls 1.3 as QQC

QQCS.MenuStyle {
    frame: Rectangle {
        color: PlasmaCore.ColorScope.backgroundColor
        border.color: Qt.tint(PlasmaCore.ColorScope.textColor, Qt.rgba(color.r, color.g, color.b, 0.7))
        border.width: 1
    }
    itemDelegate.label: QQC.Label {
        height: contentHeight * 1.2
        verticalAlignment: Text.AlignVCenter
        color: styleData.selected ? PlasmaCore.ColorScope.highlightedTextColor : PlasmaCore.ColorScope.textColor
        font.pointSize: config.fontSize
        text: styleData.text
    }
    itemDelegate.background: Rectangle {
        visible: styleData.selected
        color: PlasmaCore.ColorScope.highlightColor
    }
}
