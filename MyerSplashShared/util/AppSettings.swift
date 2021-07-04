import Foundation

public class AppSettings {
    public static let SAVING_OPTIONS = [R.strings.settings_quality_download_large,
                                 R.strings.settings_quality_download_small,
                                 R.strings.settings_quality_download_thumb]
    public static let LOADING_OPTIONS = [R.strings.settings_quality_browsing_large,
                                  R.strings.settings_quality_browsing_small,
                                  R.strings.settings_quality_browsing_thumb]

    public static let LOADING_QUALITY_DEFAULT = 0
    public static let SAVING_QUALITY_DEFAULT = 1

    public static func isSettingsEnabled(key: String, defaultValue: Bool = true) -> Bool {
        return UserDefaults.standard.bool(key: key, defaultValue: defaultValue)
    }
    
    public static func setSettings(key: String, value: Bool) {
        UserDefaults.standard.set(value, forKey: key)
    }

    public static func isQuickDownloadEnabled() -> Bool {
        return true
    }

    public static func isMeteredEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.METERED)
    }
    
    public static func shouldShowWhatIsNew() -> Bool {
        return !isSettingsEnabled(key: Keys.ALREADY_SHOW_WHAT_IS_NEW, defaultValue: false)
    }
    
    public static func isDarkMaskEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.DAKR_MASK)
    }
    
    public static func isStatusBarEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.SHOW_STATUS_BAR)
    }
    
    public static func isShowDockEnabled() -> Bool {
        return isSettingsEnabled(key: Keys.SHOW_DOCK)
    }
    
    public static func isNoSponsorshipEnabled() -> Bool {
        return !isSettingsEnabled(key: Keys.SHOW_SPONSORSHIP)
    }

    public static func loadingQuality() -> Int {
        return UserDefaults.standard.integer(key: Keys.LOADING_QUALITY,
                defaultValue: AppSettings.LOADING_QUALITY_DEFAULT)
    }

    public static func savingQuality() -> Int {
        return UserDefaults.standard.integer(key: Keys.SAVING_QUALITY,
                defaultValue: AppSettings.SAVING_QUALITY_DEFAULT)
    }
}
