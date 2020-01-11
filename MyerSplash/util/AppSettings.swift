import Foundation

class AppSettings {
    static let SAVING_OPTIONS = [R.strings.settings_quality_download_large,
                                 R.strings.settings_quality_download_small,
                                 R.strings.settings_quality_download_thumb]
    static let LOADING_OPTIONS = [R.strings.settings_quality_browsing_large,
                                  R.strings.settings_quality_browsing_small,
                                  R.strings.settings_quality_browsing_thumb]

    static let LOADING_QUALITY_DEFAULT = 0
    static let SAVING_QUALITY_DEFAULT = 1

    static func isSettingsEnabled(key: String) -> Bool {
        return UserDefaults.standard.bool(key: key, defaultValue: true)
    }

    static func isQuickDownloadEnabled() -> Bool {
        return true
    }

    static func isMeteredEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.METERED)
    }

    static func setMeteredEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: Keys.METERED)
    }

    static func loadingQuality() -> Int {
        return UserDefaults.standard.integer(key: Keys.LOADING_QUALITY,
                defaultValue: AppSettings.LOADING_QUALITY_DEFAULT)
    }

    static func savingQuality() -> Int {
        return UserDefaults.standard.integer(key: Keys.SAVING_QUALITY,
                defaultValue: AppSettings.SAVING_QUALITY_DEFAULT)
    }
}
