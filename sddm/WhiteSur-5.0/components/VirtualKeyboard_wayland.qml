/*
    SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.15

import org.kde.plasma.workspace.keyboardlayout 1.0 as Keyboards

Item {
    id: inputPanel
    readonly property bool active: Keyboards.KWinVirtualKeyboard.visible
    property bool activated: false
    visible: Keyboards.KWinVirtualKeyboard.visible

    x: Qt.inputMethod.keyboardRectangle.x
    y: Qt.inputMethod.keyboardRectangle.y
    height: Qt.inputMethod.keyboardRectangle.height
    width: Qt.inputMethod.keyboardRectangle.width

    onActivatedChanged: if (activated) {
        Keyboards.KWinVirtualKeyboard.enabled = true
    }
}
