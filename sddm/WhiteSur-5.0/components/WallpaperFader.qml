/*
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.private.sessions 2.0
import "../components"

Item {
    id: wallpaperFader
    property Item clock
    property Item mainStack
    property Item footer
    property alias source: wallpaperBlur.source
    state: lockScreenRoot.uiVisible ? "on" : "off"
    property real factor: 0
    readonly property bool lightColorScheme: Math.max(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b) > 0.5

    property bool alwaysShowClock: typeof config === "undefined" || typeof config.alwaysShowClock === "undefined" || config.alwaysShowClock === true

    Behavior on factor {
        NumberAnimation {
            target: wallpaperFader
            property: "factor"
            duration: PlasmaCore.Units.veryLongDuration * 2
            easing.type: Easing.InOutQuad
        }
    }
    FastBlur {
        id: wallpaperBlur
        anchors.fill: parent
        radius: 50 * wallpaperFader.factor
    }
    ShaderEffect {
        id: wallpaperShader
        anchors.fill: parent
        supportsAtlasTextures: true
        property var source: ShaderEffectSource {
            sourceItem: wallpaperBlur
            live: true
            hideSource: true
            textureMirroring: ShaderEffectSource.NoMirroring
        }

        readonly property real contrast: 0.65 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real saturation: 1.6 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real intensity: (wallpaperFader.lightColorScheme ? 1.7 : 0.6) * wallpaperFader.factor + (1 - wallpaperFader.factor)

        readonly property real transl: (1.0 - contrast) / 2.0;
        readonly property real rval: (1.0 - saturation) * 0.2126;
        readonly property real gval: (1.0 - saturation) * 0.7152;
        readonly property real bval: (1.0 - saturation) * 0.0722;

        property var colorMatrix: Qt.matrix4x4(
            contrast, 0,        0,        0.0,
            0,        contrast, 0,        0.0,
            0,        0,        contrast, 0.0,
            transl,   transl,   transl,   1.0).times(Qt.matrix4x4(
                rval + saturation, rval,     rval,     0.0,
                gval,     gval + saturation, gval,     0.0,
                bval,     bval,     bval + saturation, 0.0,
                0,        0,        0,        1.0)).times(Qt.matrix4x4(
                    intensity, 0,         0,         0,
                    0,         intensity, 0,         0,
                    0,         0,         intensity, 0,
                    0,         0,         0,         1
                ));

        fragmentShader: `
            uniform mediump mat4 colorMatrix;
            uniform mediump sampler2D source;
            varying mediump vec2 qt_TexCoord0;
            uniform lowp float qt_Opacity;

            void main(void)
            {
                mediump vec4 tex = texture2D(source, qt_TexCoord0);
                gl_FragColor = tex * colorMatrix * qt_Opacity;
            }
        `
    }

    states: [
        State {
            name: "on"
            PropertyChanges {
                target: mainStack
                opacity: 1
            }
            PropertyChanges {
                target: footer
                opacity: 1
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 1
            }
            PropertyChanges {
                target: clock.shadow
                opacity: 0
            }
            PropertyChanges {
                target: clock
                opacity: 1
            }
        },
        State {
            name: "off"
            PropertyChanges {
                target: mainStack
                opacity: 0
            }
            PropertyChanges {
                target: footer
                opacity: 0
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 0
            }
            PropertyChanges {
                target: clock.shadow
                opacity: wallpaperFader.alwaysShowClock ? 1 : 0
            }
            PropertyChanges {
                target: clock
                opacity: wallpaperFader.alwaysShowClock ? 1 : 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "off"
            to: "on"
            //Note: can't use animators as they don't play well with parallelanimations
            NumberAnimation {
                targets: [mainStack, footer, clock]
                property: "opacity"
                duration: PlasmaCore.Units.veryLongDuration
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "on"
            to: "off"
            NumberAnimation {
                targets: [mainStack, footer, clock]
                property: "opacity"
                duration: PlasmaCore.Units.veryLongDuration
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
