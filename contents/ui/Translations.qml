pragma Singleton
import QtQuick
import "../locale" as Locales

QtObject {
    id: root

    // The map for the active language, or null when untranslated.
    property var table: null
    property bool loaded: false

    Component.onCompleted: loadLanguage(Qt.locale().name)

    function loadLanguage(localeName) {
        const candidates = [localeName, localeName.split(/[._@-]/)[0]];

        for (const candidate of candidates) {
            const translation = Locales.Languages.languages[candidate];
            if (translation) {
                table = translation;
                loaded = true;
                return;
            }
        }

        // Fall back to en_US
        table = Locales.Languages.languages.en_US || null;
        loaded = true;
    }

    function tr(source, args) {
        let out = source;

        const translations = root.table;
        if (translations && typeof translations[source] === "string" && translations[source].length > 0) {
            out = translations[source];
        }

        if (args) {
            for (let i = 0; i < args.length; ++i) {
                out = out.split("%" + (i + 1)).join(args[i]);
            }
        }
        return out;
    }
}
