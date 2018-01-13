import Foundation

class AppSettings {
    static let SAVING_OPTIONS = ["Raw", "High(Default)", "Medium(Not recommended)"]
    static let LOADING_OPTIONS = ["Large(Recommended)", "Small", "Thumbnail"]

    static let LOADING_QUALITY_DEFAULT = 0
    static let SAVING_QUALITY_DEFAULT = 1

    static func isSettingsEnabled(key: String) -> Bool {
        return UserDefaults.standard.bool(key: key, defaultValue: true)
    }

    static func isTodayEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.ENABLE_TODAY)
    }

    static func isQuickDownloadEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.QUICK_DOWNLOAD)
    }

    static func isMeteredEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.METERED)
    }

    static func loadingQuality() -> Int {
        return UserDefaults.standard.integer(key: Keys.LOADING_QUALITY, defaultValue: AppSettings.LOADING_QUALITY_DEFAULT)
    }

    static func savingQuality() -> Int {
        return UserDefaults.standard.integer(key: Keys.SAVING_QUALITY, defaultValue: AppSettings.SAVING_QUALITY_DEFAULT)
    }
}