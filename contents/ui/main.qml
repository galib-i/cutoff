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
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.plasma.private.kicker as Kicker
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: kickoff
    onExpandedChanged: expanded => {
        if (Plasmoid.configuration.centerOnScreen && expanded) {
            centerPopup.popupVisible = !centerPopup.popupVisible
            Qt.callLater(function() { kickoff.expanded = false })
        }
    }
    Connections {
        target: Plasmoid.configuration as QtObject
        function onCenterOnScreenChanged() {
            kickoff.expanded = false;
            centerPopup.popupVisible = false;
            // The pop-up tree is created lazily when the option is enabled, not only at startup.
            kickoff.ensureFloatingFullRep()
        }
    }
    property bool isMenuOpen: Plasmoid.configuration.centerOnScreen ? centerPopup.popupVisible : kickoff.expanded
    property alias centerDialogVisible: centerPopup.popupVisible
    function closeMenu() {
        if (Plasmoid.configuration.centerOnScreen) {
            centerDialogVisible = false;
        } else {
            kickoff.expanded = false;
        }
    }
    function openMenu() {
        if (Plasmoid.configuration.centerOnScreen) {
            centerDialogVisible = true;
        } else {
            kickoff.expanded = true;
        }
    }
    function toggleMenu(wasOpen) {
        if (Plasmoid.configuration.centerOnScreen) {
            centerDialogVisible = !wasOpen;
        } else {
            kickoff.expanded = !wasOpen;
        }
    }
    function ensureFloatingFullRep() {
        if (Plasmoid.configuration.centerOnScreen) {
            centerPopup.ensure()
        }
    }

    width: Kirigami.Units.iconSizes.huge
    height: Kirigami.Units.iconSizes.huge

    // "Center on screen" pop-up (see CenterPopup.qml).
    CenterPopup {
        id: centerPopup
        kickoffItem: kickoff
    }

    // The panel pop-up's real full representation (unwrapped from its wrapper).
    readonly property var fullRepresentationInner: fullRepresentationItem ? fullRepresentationItem.innerItem : null
    property var realFullRep: Plasmoid.configuration.centerOnScreen ? centerPopup.floatingFullRepItem : fullRepresentationInner

    switchWidth: realFullRep ? realFullRep.Layout.minimumWidth : Kirigami.Units.iconSizes.huge * 10
    switchHeight: realFullRep ? realFullRep.Layout.minimumHeight : Kirigami.Units.iconSizes.huge * 10

    // The properties are defined here instead of the singleton because each
    // instance of Kickoff requires different instances of these properties

    readonly property bool inPanel: [
        PlasmaCore.Types.TopEdge,
        PlasmaCore.Types.RightEdge,
        PlasmaCore.Types.BottomEdge,
        PlasmaCore.Types.LeftEdge,
    ].includes(Plasmoid.location)
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // Used to prevent the width from changing frequently when the scrollbar appears or disappears
    readonly property bool mayHaveVerticalScrollBar: kickoff.rootModel.favoritesModel.count > minimumRowCount * minimumRowCount

    //BEGIN Models
    readonly property Kicker.RootModel rootModel: Kicker.RootModel {
        autoPopulate: false

        // TODO: appletInterface property now can be ported to "applet" and have the real Applet* assigned directly
        appletInterface: kickoff

        appNameFormat: Plasmoid.configuration.appNameFormat
        flat: true // have categories, but no subcategories
        sorted: true
        showSeparators: false
        showRootSeparator: true
        showTopLevelItems: false

        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: true
        highlightNewlyInstalledApps: Plasmoid.configuration.highlightNewlyInstalledApps

        Component.onCompleted: {

            favoritesModel.initForClient("org.kde.plasma.kickoff.favorites.instance-" + Plasmoid.id)

        }
    }

    readonly property Kicker.RunnerModel runnerModel: Kicker.RunnerModel {
        query: kickoff.searchField ? kickoff.searchField.text : ""
        onRequestUpdateQuery: query => {
            if (kickoff.searchField) {
                kickoff.searchField.text = query;
            }
        }
        appletInterface: kickoff
        mergeResults: true
        favoritesModel: kickoff.rootModel.favoritesModel
    }

    //END

    //BEGIN UI elements
    // Set in FullRepresentation.qml
    property var header: null

    // Set in Header.qml
    property var searchField: null

    // Set in FullRepresentation.qml, ApplicationsPage.qml
    property var contentArea: null // is searchView when searching

    // Set in NormalPage.qml
    property var footer: null

    // References to items according to their focus chain order
    readonly property Item firstHeaderItem: searchField
    readonly property Item lastHeaderItem: header ? header.pinButton : null
    readonly property Item firstCentralPane: contentArea
    readonly property Item lastCentralPane: contentArea

    readonly property Item dragSource: Item {
        id: dragSource // BUG 449426
        property var sourceItem
        Drag.dragType: Drag.Automatic
        Drag.supportedActions: Qt.CopyAction | Qt.LinkAction | Qt.MoveAction
    }
    //END

    //BEGIN Metrics
    readonly property KSvg.FrameSvgItem backgroundMetrics: KSvg.FrameSvgItem {
        // Inset defaults to a negative value when not set by margin hints
        readonly property real leftPadding: Math.round(margins.left - Math.max(inset.left, 0))
        readonly property real rightPadding: Math.round(margins.right - Math.max(inset.right, 0))
        readonly property real topPadding: Math.round(margins.top - Math.max(inset.top, 0))
        readonly property real bottomPadding: Math.round(margins.bottom - Math.max(inset.bottom, 0))
        readonly property real spacing: Math.round(leftPadding)
        visible: false
        imagePath: Plasmoid.formFactor === PlasmaCore.Types.Planar ? "widgets/background" : "dialogs/background"
    }

    // Used to show smaller Kickoff on small screens
    readonly property int minimumRowCount:
        Math.min(Screen.desktopAvailableWidth, Screen.desktopAvailableHeight) * Screen.devicePixelRatio
            < KickoffSingleton.cellSize * 4 + KickoffSingleton.cellSize * 2
        ? 2 : 4
    //END

    Plasmoid.icon: Plasmoid.configuration.icon

    preferredRepresentation: compactRepresentation

    fullRepresentation: FullRepresentationWrapper { kickoffItem: kickoff }

    compactRepresentation: CompactRepresentation { kickoffItem: kickoff }

    Kicker.ProcessRunner {
        id: processRunner
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18nc("@action:inmenu launches kmenuedit", "Edit Applications…")
            icon.name: "kmenuedit"
            visible: Plasmoid.immutability !== PlasmaCore.Types.SystemImmutable
            onTriggered: processRunner.runMenuEditor()
        }
    ]

    Component.onCompleted: {
        kickoff.activationTogglesExpanded = true
        kickoff.ensureFloatingFullRep()
    }
} // root
