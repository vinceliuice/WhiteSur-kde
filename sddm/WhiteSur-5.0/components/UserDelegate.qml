/*
    SPDX-FileCopyrightText: 2014 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Window 2.15

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: wrapper

    // If we're using software rendering, draw outlines instead of shadows
    // See https://bugs.kde.org/show_bug.cgi?id=398317
    readonly property bool softwareRendering: GraphicsInfo.api === GraphicsInfo.Software

    property bool isCurrent: true

    property string name
    property string userName
    property string avatarPath
    property string iconSource
    property bool needsPassword
    property var vtNumber
    property bool constrainText: true
    property alias nameFontSize: usernameDelegate.font.pointSize
    property int fontSize: PlasmaCore.Theme.defaultFont.pointSize + 2
    signal clicked()

    property real faceSize: PlasmaCore.Units.gridUnit * 7

    opacity: isCurrent ? 1.0 : 0.5

    Behavior on opacity {
        OpacityAnimator {
            duration: PlasmaCore.Units.longDuration
        }
    }

    // Draw a translucent background circle under the user picture
    Rectangle {
        anchors.centerIn: imageSource
        width: imageSource.width - 2 // Subtract to prevent fringing
        height: width
        radius: width / 2

        color: PlasmaCore.ColorScope.backgroundColor
        opacity: 0.6
    }

    Item {
        id: imageSource
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on width {
            PropertyAnimation {
                from: faceSize
                duration: PlasmaCore.Units.longDuration;
            }
        }
        width: isCurrent ? faceSize : faceSize - PlasmaCore.Units.largeSpacing
        height: width

        //Image takes priority, taking a full path to a file, if that doesn't exist we show an icon
        Image {
            id: face
            source: wrapper.avatarPath
            sourceSize: Qt.size(faceSize * Screen.devicePixelRatio, faceSize * Screen.devicePixelRatio)
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent
        }

        PlasmaCore.IconItem {
            id: faceIcon
            source: iconSource
            visible: (face.status == Image.Error || face.status == Image.Null)
            anchors.fill: parent
            colorGroup: PlasmaCore.ColorScope.colorGroup
        }
    }

    ShaderEffect {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: imageSource.width
        height: imageSource.height

        supportsAtlasTextures: true

        readonly property Item source: ShaderEffectSource {
            sourceItem: imageSource
            // software rendering is just a fallback so we can accept not having a rounded avatar here
            hideSource: wrapper.GraphicsInfo.api !== GraphicsInfo.Software
            live: true // otherwise the user in focus will show a blurred avatar
        }

        readonly property color colorBorder: PlasmaCore.ColorScope.textColor

        //draw a circle with an antialiased border
        //innerRadius = size of the inner circle with contents
        //outerRadius = size of the border
        //blend = area to blend between two colours
        //all sizes are normalised so 0.5 == half the width of the texture

        //if copying into another project don't forget to connect themeChanged to update()
        //but in SDDM that's a bit pointless
        fragmentShader: `
            varying highp vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp sampler2D source;
            uniform lowp vec4 colorBorder;

            const highp float blend = 0.01;
            const highp float innerRadius = 0.47;
            const highp float outerRadius = 0.49;
            const lowp vec4 colorEmpty = vec4(0.0, 0.0, 0.0, 0.0);

            void main() {
                lowp vec4 colorSource = texture2D(source, qt_TexCoord0.st);

                highp vec2 m = qt_TexCoord0 - vec2(0.5, 0.5);
                highp float dist = sqrt(m.x * m.x + m.y * m.y);

                if (dist < innerRadius)
                    gl_FragColor = colorSource;
                else if (dist < innerRadius + blend)
                    gl_FragColor = mix(colorSource, colorBorder, ((dist - innerRadius) / blend));
                else if (dist < outerRadius)
                    gl_FragColor = colorBorder;
                else if (dist < outerRadius + blend)
                    gl_FragColor = mix(colorBorder, colorEmpty, ((dist - outerRadius) / blend));
                else
                    gl_FragColor = colorEmpty;

                gl_FragColor = gl_FragColor * qt_Opacity;
            }
        `
    }

    PlasmaComponents3.Label {
        id: usernameDelegate

        anchors.top: imageSource.bottom
        anchors.topMargin: PlasmaCore.Units.gridUnit
        anchors.horizontalCenter: parent.horizontalCenter

        // Make it bigger than other fonts to match the scale of the avatar better
        font.pointSize: wrapper.fontSize + 4

        width: constrainText ? parent.width : implicitWidth
        text: wrapper.name
        style: softwareRendering ? Text.Outline : Text.Normal
        styleColor: softwareRendering ? PlasmaCore.ColorScope.backgroundColor : "transparent" //no outline, doesn't matter
        wrapMode: Text.WordWrap
        maximumLineCount: wrapper.constrainText ? 3 : 1
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        //make an indication that this has active focus, this only happens when reached with keyboard navigation
        font.underline: wrapper.activeFocus
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: wrapper.clicked()
    }

    Keys.onSpacePressed: wrapper.clicked()

    Accessible.name: name
    Accessible.role: Accessible.Button
    function accessiblePressAction() { wrapper.clicked() }
}
