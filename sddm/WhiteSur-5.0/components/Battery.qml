/*
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.workspace.components 2.0 as PW

RowLayout {
    id: root

    property int fontSize: PlasmaCore.Theme.defaultFont.pointSize

    function getOrDefault(source /*object?*/, prop /*string*/, fallback /*T*/) /*-> T*/ {
        return (source !== null && source !== undefined && source.hasOwnProperty(prop))
            ? source[prop] : fallback;
    }

    readonly property var acAdapter: pmSource.data["AC Adapter"]
    readonly property var battery: pmSource.data["Battery"]

    readonly property bool pluggedIn: getOrDefault(acAdapter, "Plugged in", false)
    readonly property bool hasBattery: getOrDefault(battery, "Has Battery", false)
    readonly property int percent: getOrDefault(battery, "Percent", 0)

    spacing: PlasmaCore.Units.smallSpacing
    visible: getOrDefault(battery, "Has Cumulative", false)

    PlasmaCore.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }

    PW.BatteryIcon {
        pluggedIn: root.pluggedIn
        hasBattery: root.hasBattery
        percent: root.percent

        Layout.preferredHeight: Math.max(PlasmaCore.Units.iconSizes.medium, batteryLabel.implicitHeight)
        Layout.preferredWidth: Layout.preferredHeight
        Layout.alignment: Qt.AlignVCenter
    }

    PlasmaComponents3.Label {
        id: batteryLabel
        font.pointSize: root.fontSize
        text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "%1%", root.percent)
        Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Battery at %1%", root.percent)
        Layout.alignment: Qt.AlignVCenter
    }
}
