/*
    SPDX-FileCopyrightText: 2022 ivan (@ratijas) tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQml 2.15

QtObject {
    id: root

    property Item target

    readonly property Animation __animation: RejectPasswordPathAnimation {
        id: animation
        target: Item { id: fakeTarget }
    }

    property Binding __bindEnabled: Binding {
        target: root.target
        property: "enabled"
        value: false
        when: animation.running
        restoreMode: Binding.RestoreBindingOrValue
    }

    // real target is getting a Translate object which pulls coordinates from
    // a fake Item object
    property Binding __bindTransform: Binding {
        target: root.target
        property: "transform"
        value: Translate {
            x: fakeTarget.x
        }
        restoreMode: Binding.RestoreBindingOrValue
    }

    function start() {
        animation.start();
    }
}
