/* SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound
pragma Singleton // NOTE: Singletons are shared between all instances of a plasmoid

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PC3
// Trying to create a default property for a QtObject seems to cause segfaults.
Item {
    id: root

    visible: false

    //BEGIN Reusable Objects
    readonly property KSvg.Svg lineSvg: KSvg.Svg {
        imagePath: "widgets/line"
        property int horLineHeight: elementSize("horizontal-line").height
    }
    //END

    //BEGIN Metrics
    readonly property KSvg.FrameSvgItem listItemMetrics: KSvg.FrameSvgItem {
        visible: false
        imagePath: "widgets/listitem"
        prefix: "normal"
    }

    readonly property FontMetrics fontMetrics: FontMetrics {
        id: fontMetrics
        font: Kirigami.Theme.defaultFont
    }

    // Approximate grid cell size based on standard Kickoff grid delegates
    // (large icon + 2 lines of text + padding)
    readonly property real gridCellSize: Kirigami.Units.iconSizes.large + (fontMetrics.height * 2) + (Kirigami.Units.largeSpacing * 2)
    readonly property real compactListDelegateHeight: compactListDelegate.implicitHeight
    //END

    //BEGIN Private
    KickoffListDelegate {
        id: compactListDelegate
        kickoffItem: null
        visible: false
        enabled: false
        compact: true
        model: null
        index: -1
        text: "asdf"
        url: ""
        decoration: "start-here-kde"
        PC3.ToolTip.text: ""
        description: "asdf"
        action: null
        indicator: null
        isMultilineText: false
    }
    //END
}
