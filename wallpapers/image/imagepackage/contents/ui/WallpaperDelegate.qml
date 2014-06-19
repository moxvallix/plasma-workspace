/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *  Copyright 2014 Sebastian Kügler <sebas@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls.Private 1.0
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
    id: wallpaperDelegate

    width: wallpapersGrid.cellWidth
    height: wallpapersGrid.cellHeight

    property bool selected: (wallpapersGrid.currentIndex == index)

    onSelectedChanged: {
        cfg_Image = model.path
    }

    hoverEnabled: true

    Column {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        QPixmapItem {
            id: walliePreview
            anchors.horizontalCenter: parent.horizontalCenter
            height: wallpaperDelegate.height + 1
            width: wallpaperDelegate.width + 1
            visible: model.screenshot != null
            smooth: true
            pixmap: model.screenshot
            fillMode: {
                if (cfg_FillMode == Image.Stretch) {
                    return QPixmapItem.Stretch;
                } else if (cfg_FillMode == Image.PreserveAspectFit) {
                    return QPixmapItem.PreserveAspectFit;
                } else if (cfg_FillMode == Image.PreserveAspectCrop) {
                    return QPixmapItem.PreserveAspectCrop;
                } else if (cfg_FillMode == Image.Tile) {
                    return QPixmapItem.Tile;
                } else if (cfg_FillMode == Image.TileVertically) {
                    return QPixmapItem.TileVertically;
                } else if (cfg_FillMode == Image.TileHorizontally) {
                    return QPixmapItem.TileHorizontally;
                }
                return QPixmapItem.Pad;
            }

            Rectangle {
                anchors.fill: parent
                color: cfg_Color
                z: parent.z - 1
            }

            Rectangle {
                opacity: selected ? 1.0 : 0
                anchors.fill: parent
                border.width: units.smallSpacing * 2
                border.color: syspal.highlight
                color: "transparent"
                Behavior on opacity {
                    PropertyAnimation {
                        duration: units.longDuration
                        easing.type: Easing.OutQuad
                    }
                }
            }
            PlasmaComponents.ToolButton {
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: units.smallSpacing
                }
                iconSource: "list-remove"
                flat: false
                visible: model.removable
                onClicked: imageWallpaper.removeWallpaper(model.packageName)
                opacity: wallpaperDelegate.containsMouse ? 1 : 0
                Behavior on opacity {
                    PropertyAnimation {
                        duration: units.longDuration
                        easing.type: Easing.OutQuad
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000 // FIXME TODO: Use platform value for tooltip activation delay.

        running: wallpaperDelegate.containsMouse && !pressed && model.display && model.author

        onTriggered: {
            Tooltip.showText(wallpaperDelegate, Qt.point(wallpaperDelegate.mouseX, wallpaperDelegate.mouseY),
                i18n("%1 by %2", model.display, model.author));
        }
    }

    onClicked: {
        wallpapersGrid.currentIndex = index
        cfg_Image = model.path
    }

    onExited: Tooltip.hideText()

    Component.onCompleted: {
        if (cfg_Image == model.path) {
            makeCurrentTimer.pendingIndex = model.index
            makeCurrentTimer.restart()
        }
    }
}
