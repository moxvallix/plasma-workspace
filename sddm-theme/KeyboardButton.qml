import QtQuick 2.15
import QtQuick.Controls 1.6 as QQC // Don't bump it any further, this is the latest.

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents // Because PC3 ToolButton can't take a menu

PlasmaComponents.ToolButton {
    id: keyboardButton

    property int currentIndex: -1

    text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Keyboard Layout: %1", instantiator.objectAt(currentIndex).shortName)
    implicitWidth: minimumWidth

    visible: menu.items.length > 1

    Component.onCompleted: {
        currentIndex = Qt.binding(() => keyboard.currentLayout);
    }

    menu: QQC.Menu {
        id: keyboardMenu
        style: BreezeMenuStyle {}
        Instantiator {
            id: instantiator
            model: keyboard.layouts
            onObjectAdded: keyboardMenu.insertItem(index, object)
            onObjectRemoved: keyboardMenu.removeItem(object)
            delegate: QQC.MenuItem {
                text: modelData.longName
                property string shortName: modelData.shortName
                onTriggered: {
                    keyboard.currentLayout = model.index
                }
            }
        }
    }
}
