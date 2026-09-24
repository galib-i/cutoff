/*
    SPDX-FileCopyrightText: 2011 Martin *Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

AbstractKickoffItemDelegate {
    id: root

    property bool compact: Plasmoid.configuration.compactMode

    leftPadding: (KickoffSingleton.listItemMetrics?.fixedMargins.left ?? 0)
        + (mirrored ? (KickoffSingleton.fontMetrics?.descent ?? 0) : 0)
        + Kirigami.Units.smallSpacing
    rightPadding: (KickoffSingleton.listItemMetrics?.fixedMargins.right ?? 0)
        + (!mirrored ? (KickoffSingleton.fontMetrics?.descent ?? 0) : 0)
        + Kirigami.Units.smallSpacing
    // Otherwise it's *too* compact :)
    topPadding: (compact ? Kirigami.Units.mediumSpacing : Kirigami.Units.smallSpacing) + Kirigami.Units.smallSpacing
    bottomPadding: (compact ? Kirigami.Units.mediumSpacing : Kirigami.Units.smallSpacing) + Kirigami.Units.smallSpacing

    icon.width: compact ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium
    icon.height: compact ? Kirigami.Units.iconSizes.smallMedium : Kirigami.Units.iconSizes.medium

    labelTruncated: label.truncated
    descriptionTruncated: descriptionLabel.truncated
    descriptionVisible: descriptionLabel.visible

    dragIconItem: icon

    contentItem: RowLayout {
        id: row
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            id: icon
            implicitWidth: root.icon.width
            implicitHeight: root.icon.height
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            animated: false
            selected: root.iconAndLabelsShouldlookSelected
            source: root.removalPlaceholderActive ? "list-remove" : (root.decoration || root.icon.name || root.icon.source)
        }

        Item {
            id: gridLayoutWrapper // exists to break implicitWidth propagation

            implicitHeight: gridLayout.implicitHeight
            Layout.fillWidth: true

            GridLayout {
                id: gridLayout

                readonly property color textColor: root.iconAndLabelsShouldlookSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

                anchors.fill: parent
                visible: !root.removalPlaceholderActive

                rows: root.compact ? 1 : 2
                columns: root.compact ? 2 : 1
                rowSpacing: 0
                columnSpacing: Kirigami.Units.largeSpacing

                PC3.Label {
                    id: label
                    Layout.fillWidth: !descriptionLabel.visible
                    Layout.preferredWidth: Math.min(gridLayoutWrapper.width, implicitWidth)
                    text: root.text
                    textFormat: root.isMultilineText ? Text.StyledText : Text.PlainText
                    elide: Text.ElideRight
                    wrapMode: root.isMultilineText ? Text.WordWrap : Text.NoWrap
                    verticalAlignment: Text.AlignVCenter
                    maximumLineCount: root.isMultilineText ? Infinity : 1
                    color: gridLayout.textColor
                }

                PC3.Label {
                    id: descriptionLabel
                    Layout.fillWidth: true
                    visible: {
                        let isApplicationSearchResult = root.model?.group === "Applications" || root.model?.group === "System Settings"
                        let isSearchResultWithDescription = root.isSearchResult && (Plasmoid.configuration?.appNameFormat > 1 || !isApplicationSearchResult)
                        return text.length > 0 && (isSearchResultWithDescription || (text !== label.text && Plasmoid.configuration?.appNameFormat > 1))
                    }
                    opacity: 0.75
                    text: root.description
                    textFormat: Text.PlainText
                    font: Kirigami.Theme.smallFont
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: root.compact ? Text.AlignRight : Text.AlignLeft
                    maximumLineCount: 1
                    color: gridLayout.textColor
                }
            }
        }

        Loader {
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight

            visible: active
            active: (root.model?.isNewlyInstalled ?? false) && !root.removalPlaceholderActive

            sourceComponent: Kirigami.Badge {
                text: ""

                type: Kirigami.Badge.Type.Positive

                Accessible.description: i18n("Newly-installed application")
            }
        }
    }

    Loader {
        id: separatorLoader

        anchors.left: root.left
        anchors.right: root.right
        anchors.verticalCenter: root.verticalCenter

        active: root.isSeparator

        asynchronous: false
        sourceComponent: KSvg.SvgItem {
            width: parent.width
            height: KickoffSingleton.lineSvg?.horLineHeight ?? 0

            Binding on svg {
                value: KickoffSingleton.lineSvg
                when: KickoffSingleton.lineSvg !== undefined
            }
            elementId: "horizontal-line"
        }
    }
}
