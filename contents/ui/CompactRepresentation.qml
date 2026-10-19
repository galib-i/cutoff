/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

// qmllint disable missing-property

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

import "code/tools.js" as Tools

// Only exists because Plasma's built-in compactRepresentation doesn't:
// - open on drag
// - allow defining a custom drop handler
// - expose the ability to show text below or beside the icon
// TODO remove once it gains those features
MouseArea {
    id: compactRoot

    required property var kickoffItem

    // Taken from DigitalClock to ensure uniform sizing when next to each other
    readonly property bool tooSmall: Plasmoid.formFactor === PlasmaCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 5)) <= Kirigami.Theme.smallFont.pixelSize

    readonly property bool shouldHaveIcon: Plasmoid.formFactor === PlasmaCore.Types.Vertical || Plasmoid.icon !== ""
    readonly property bool shouldHaveLabel: Plasmoid.formFactor !== PlasmaCore.Types.Vertical && Plasmoid.configuration.menuLabel !== ""

    readonly property int iconSize: Kirigami.Units.iconSizes.large

    readonly property var sizing: {
        const displayedIcon = imageFallback.visible ? imageFallback : (buttonIcon.valid ? buttonIcon : buttonIconFallback);

        let impWidth = 0;
        if (shouldHaveIcon) {
            impWidth += displayedIcon.width;
        }
        if (shouldHaveLabel) {
            impWidth += labelTextField.contentWidth + labelTextField.Layout.leftMargin + labelTextField.Layout.rightMargin;
        }
        const impHeight = displayedIcon.height > 0 ? displayedIcon.height : iconSize

        // at least square, but can be wider/taller
        if (compactRoot.kickoffItem.inPanel) {
            if (compactRoot.kickoffItem.vertical) {
                return {
                    preferredWidth: iconSize,
                    preferredHeight: impHeight
                };
            } else { // horizontal
                return {
                    preferredWidth: impWidth,
                    preferredHeight: iconSize
                };
            }
        } else {
            return {
                preferredWidth: impWidth,
                preferredHeight: Kirigami.Units.iconSizes.small,
            };
        }
    }

    implicitWidth: iconSize
    implicitHeight: iconSize

    Layout.preferredWidth: sizing.preferredWidth
    Layout.preferredHeight: sizing.preferredHeight
    Layout.minimumWidth: Layout.preferredWidth
    Layout.minimumHeight: Layout.preferredHeight

    hoverEnabled: true

    property bool wasExpanded

    Accessible.name: Plasmoid.title
    Accessible.role: Accessible.Button

    onPressed: wasExpanded = compactRoot.kickoffItem.isMenuOpen
    onClicked: compactRoot.kickoffItem.toggleMenu(wasExpanded)

    DropArea {
        id: compactDragArea
        anchors.fill: parent
        onEntered: drag => {
            if (drag.hasUrls) {
                expandOnDragTimer.start()
            }
        }
        onExited: expandOnDragTimer.stop()
    }

    Timer {
        id: expandOnDragTimer
        // this is an interaction and not an animation, so we want it as a constant
        interval: 250
        onTriggered: compactRoot.kickoffItem.openMenu()
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Kirigami.Icon {
            id: buttonIcon

            Layout.fillWidth: compactRoot.kickoffItem.vertical
            Layout.fillHeight: !compactRoot.kickoffItem.vertical
            Layout.preferredWidth: compactRoot.kickoffItem.vertical ? -1 : height / (implicitHeight / implicitWidth)
            Layout.preferredHeight: !compactRoot.kickoffItem.vertical ? -1 : width * (implicitHeight / implicitWidth)
            Layout.maximumHeight: Kirigami.Units.iconSizes.huge
            Layout.maximumWidth: Kirigami.Units.iconSizes.huge
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            source: Tools.iconOrDefault(Plasmoid.formFactor === PlasmaCore.Types.Vertical, Plasmoid.icon)
            active: compactRoot.containsMouse || compactDragArea.containsDrag
            roundToIconSize: implicitHeight === implicitWidth
            visible: valid && !imageFallback.visible
        }

        Kirigami.Icon {
            id: buttonIconFallback
            // fallback is assumed to be square
            Layout.fillWidth: compactRoot.kickoffItem.vertical
            Layout.fillHeight: !compactRoot.kickoffItem.vertical
            Layout.preferredWidth: compactRoot.kickoffItem.vertical ? -1 : height
            Layout.preferredHeight: !compactRoot.kickoffItem.vertical ? -1 : width
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            source: buttonIcon.valid ? null : Tools.defaultIconName
            active: compactRoot.containsMouse || compactDragArea.containsDrag
            visible: !buttonIcon.valid && Plasmoid.icon !== "" && !imageFallback.visible
        }

        Image {
            id: imageFallback

            readonly property bool nonSquareImage: sourceSize.width != sourceSize.height

            visible: nonSquareImage && status == Image.Ready
            source: Plasmoid.icon.startsWith("/") ? "file:" + Plasmoid.icon.split("/").map(encodeURIComponent).join("/") : ""

            Layout.fillWidth: compactRoot.kickoffItem.vertical
            Layout.fillHeight: !compactRoot.kickoffItem.vertical
            Layout.preferredWidth: compactRoot.kickoffItem.vertical ? -1 : height / (implicitHeight / implicitWidth)
            Layout.preferredHeight: !compactRoot.kickoffItem.vertical ? -1 : width * (implicitHeight / implicitWidth)
            Layout.maximumHeight: compactRoot.kickoffItem.vertical ? -1 : Kirigami.Units.iconSizes.huge
            Layout.maximumWidth: compactRoot.kickoffItem.vertical ? Kirigami.Units.iconSizes.huge : -1
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }

        PC3.Label {
            id: labelTextField

            Layout.fillHeight: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing

            text: Plasmoid.configuration.menuLabel
            textFormat: Text.StyledText
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.NoWrap
            fontSizeMode: Text.VerticalFit
            font.pixelSize: compactRoot.tooSmall ? Kirigami.Theme.defaultFont.pixelSize : Kirigami.Units.iconSizes.roundedIconSize(Kirigami.Units.gridUnit * 2)
            minimumPointSize: Kirigami.Theme.smallFont.pointSize
            visible: compactRoot.shouldHaveLabel
        }
    }
}
