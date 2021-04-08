/*
    SPDX-FileCopyrightText: 2016 David Edmundson <davidedmundson@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick 2.2

import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "../components"

SessionManagementScreen {

    property Item mainPasswordBox: passwordBox
    property bool lockScreenUiVisible: false

    enum VisibleScreen {
        V2Screen,
        BlankScreen,
        PromptEchoOnScreen,
        PromptEchoOffScreen,
        InfoMsgScreen,
        ErrorMsgScreen,
        SuccessScreen /* Currently same as BlankScreen, i.e. empty */
    }

    property int visibleScreen: (root.interfaceVersion < 3) ? MainBlock.VisibleScreen.V2Screen : MainBlock.VisibleScreen.BlankScreen
    property Item loginButton: _loginButtonV2
    property Item echoOnMessageLabel: _echoOnMessage
    property Item echoOnBox: _echoOnBox
    property Item echoOffMessageLabel: _echoOffMessage
    property Item echoOffBox: _echoOffBox
    property Item infoMessageLabel: _infoMessage
    property Item errorMessageLabel: _errorMessage

    //the y position that should be ensured visible when the on screen keyboard is visible
    property int visibleBoundary: mapFromItem(loginButton, 0, 0).y
    onHeightChanged: visibleBoundary = mapFromItem(loginButton, 0, 0).y + loginButton.height + PlasmaCore.Units.smallSpacing
    /*
     * Login has been requested with the following username and password
     * If username field is visible, it will be taken from that, otherwise from the "name" property of the currentIndex
     */
    signal loginRequestV2(string password)

    signal promptEchoOnResult(string value)
    signal promptEchoOffResult(string value)

    function startLoginV2() {
        var password = passwordBox.text

        //this is partly because it looks nicer
        //but more importantly it works round a Qt bug that can trigger if the app is closed with a TextField focused
        //See https://bugreports.qt.io/browse/QTBUG-55460
        _loginButtonV2.forceActiveFocus();
        loginRequestV2(password);
    }

    RowLayout {
        Layout.fillWidth: true
        visible: visibleScreen == MainBlock.VisibleScreen.V2Screen
        enabled: visible

        PlasmaComponents3.TextField {
            id: passwordBox
            font.pointSize: PlasmaCore.Theme.defaultFont.pointSize + 1
            Layout.fillWidth: true

            placeholderText: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Password")
            focus: visible
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            enabled: !authenticator.graceLocked
            revealPasswordButtonShown: true

            // In Qt this is implicitly active based on focus rather than visibility
            // in any other application having a focussed invisible object would be weird
            // but here we are using to wake out of screensaver mode
            // We need to explicitly disable cursor flashing to avoid unnecessary renders
            cursorVisible: visible

            onAccepted: {
                if (lockScreenUiVisible) {
                    startLoginV2();
                }
            }

            //if empty and left or right is pressed change selection in user switch
            //this cannot be in keys.onLeftPressed as then it doesn't reach the password box
            Keys.onPressed: {
                if (event.key == Qt.Key_Left && !text) {
                    userList.decrementCurrentIndex();
                    event.accepted = true
                }
                if (event.key == Qt.Key_Right && !text) {
                    userList.incrementCurrentIndex();
                    event.accepted = true
                }
            }

            Connections {
                target: root
                function onClearPassword() {
                    if (root.interfaceVersion < 3) {
                        passwordBox.forceActiveFocus()
                        passwordBox.text = "";
                    } else {
                        echoOffBox.text = "";
                    }
                }
            }
        }

        PlasmaComponents3.Button {
            id: _loginButtonV2
            Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Unlock")
            Layout.preferredHeight: passwordBox.implicitHeight
            Layout.preferredWidth: _loginButtonV2.Layout.preferredHeight

            icon.name: "go-next"

            onClicked: startLoginV2()
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: visibleScreen == MainBlock.VisibleScreen.PromptEchoOnScreen
        enabled: visible

        PlasmaComponents3.Label {
            id: _echoOnMessage
            visible: text ? true : false
            font.pointSize: PlasmaCore.Theme.defaultFont.pointSize + 2
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents3.TextField {
                id: _echoOnBox
                font.pointSize: theme.defaultFont.pointSize + 1
                Layout.fillWidth: true

                focus: visible
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

                // In Qt this is implicitly active based on focus rather than visibility
                // in any other application having a focussed invisible object would be weird
                // but here we are using to wake out of screensaver mode
                // We need to explicitly disable cursor flashing to avoid unnecessary renders
                cursorVisible: visible

                onAccepted: {
                    if (lockScreenUiVisible) {
                        visibleScreen = MainBlock.VisibleScreen.BlankScreen;
                        promptEchoOnResult(echoOnBox.text);
                    }
                }
            }

            PlasmaComponents3.Button {
                id: echoOnButton
                Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Ok")
                Layout.preferredHeight: echoOnBox.implicitHeight
                Layout.preferredWidth: echoOnButton.Layout.preferredHeight

                icon.name: "go-next"

                onClicked: {
                    visibleScreen = MainBlock.VisibleScreen.BlankScreen;
                    promptEchoOnResult(echoOnBox.text);
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: visibleScreen == MainBlock.VisibleScreen.PromptEchoOffScreen
        enabled: visible

        PlasmaComponents3.Label {
            id: _echoOffMessage
            visible: text ? true : false
            font.pointSize: PlasmaCore.Theme.defaultFont.pointSize + 2
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true

            PlasmaComponents3.TextField {
                id: _echoOffBox
                font.pointSize: theme.defaultFont.pointSize + 1
                Layout.fillWidth: true

                focus: visible
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhHiddenText | Qt.ImhSensitiveData | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                revealPasswordButtonShown: true

                // In Qt this is implicitly active based on focus rather than visibility
                // in any other application having a focussed invisible object would be weird
                // but here we are using to wake out of screensaver mode
                // We need to explicitly disable cursor flashing to avoid unnecessary renders
                cursorVisible: visible

                onAccepted: {
                    if (lockScreenUiVisible) {
                        visibleScreen = MainBlock.VisibleScreen.BlankScreen;
                        promptEchoOffResult(echoOffBox.text);
                    }
                }
            }

            PlasmaComponents3.Button {
                id: echoOffButton
                Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Ok")
                Layout.preferredHeight: echoOffBox.implicitHeight
                Layout.preferredWidth: echoOffButton.Layout.preferredHeight

                icon.name: "go-next"

                onClicked: {
                    visibleScreen = MainBlock.VisibleScreen.BlankScreen;
                    promptEchoOffResult(echoOffBox.text);
                }
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: visibleScreen == MainBlock.VisibleScreen.InfoMsgScreen
        enabled: visible

        PlasmaComponents3.Label {
            id: _infoMessage
            font.pointSize: PlasmaCore.Theme.defaultFont.pointSize + 2
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: visibleScreen == MainBlock.VisibleScreen.ErrorMsgScreen
        enabled: visible

        PlasmaComponents3.Label {
            id: _errorMessage
            font.pointSize: PlasmaCore.Theme.defaultFont.pointSize + 2
            Layout.maximumWidth: units.gridUnit * 16
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }
    }
}
