/*
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQml 2.15

import org.kde.plasma.core 2.0 as PlasmaCore

PathAnimation {
    id: root

    /** The magnitude/distance/offset of the animation, in the usual device-independent pixels. */
    property real swing: 15

    /**
     * In which direction the target starts moving first.
     * Must be either Qt.LeftToRight or Qt.RightToLeft.
     *
     * By default it is opposite to the application's layout direction, to
     * make an animation feel more "disturbing".
     */
    property int initialDirection: Qt.application.layoutDirection === Qt.RightToLeft ? Qt.LeftToRight : Qt.RightToLeft

    alwaysRunToEnd: true

    // This animation's speed does not depend on user preferences, except when
    // we honor the "reduced animations" special case.
    // Animators with a duration of 0 do not fire reliably, which is why duration is at least 1.
    // see Bug 357532 and QTBUG-39766
    duration: PlasmaCore.Units.longDuration <= 1 ? 1 : 600
    easing.type: Easing.OutCubic

    path: Path {
        PathPolyline {
            path: {
                const directionFactor = root.initialDirection === Qt.RightToLeft ? -1 : 1;
                const extreme = root.swing * directionFactor;
                const here = Qt.point(extreme, 0);
                const there = Qt.point(-extreme, 0);
                return [
                    Qt.point(0, 0),
                    here, there,
                    here, there,
                    here, there,
                    Qt.point(0, 0),
                ];
            }
        }
    }
}
