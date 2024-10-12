import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

TextField {
    placeholderTextColor: config.color
    palette.text: config.color
    font.pointSize: config.fontSize
    font.family: config.font
    width: parent.width
    background: Rectangle {
        color: parent.focus ? "#ffffff" : "#dddddd"
        radius: 100
        opacity: 0.45
    }
}
