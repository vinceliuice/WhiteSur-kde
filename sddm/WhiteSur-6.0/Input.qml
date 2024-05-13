import QtQuick 2.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4

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
