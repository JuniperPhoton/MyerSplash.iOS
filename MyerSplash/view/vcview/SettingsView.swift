import Foundation
import UIKit
import SnapKit
import Nuke
import MessageUI

protocol SettingsViewDelegate {
    func showDialog(content: DialogContent, key: String)
    func onClickFeedback()
    func onClickClose(shouldRefreshWhenDismiss: Bool)
}

class SettingsView: UIView {
    private var titleView:          UILabel!
    private var closeView:          UIButton!
    private var loadingQualityItem: SettingsItem!
    private var savingQualityItem:  SettingsItem!

    private var scrollView: UIScrollView!

    var shouldRefreshWhenDismiss = false

    var delegate: SettingsViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUi()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func initUi() {

        self.setDefaultBackgroundColor()

        titleView = UILabel()
        titleView.setDefaultLabelColor()
        
        titleView.text = "SETTINGS"
        titleView.font = titleView.font.with(traits: .traitBold, fontSize: FontSizes.TITLE_FONT_SIZE)

        closeView = UIButton(type: .system)
        closeView.setImage(UIImage(named: "ic_clear_white"), for: .normal)
        closeView.addTarget(self, action: #selector(onClickCloseButton), for: .touchUpInside)
        closeView.tintColor = UIView.getDefaultLabelUIColor()

        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        let personalizationGroup = SettingsGroup()
        personalizationGroup.label = "PERSONALIZATION"

        let quickDownload = SettingsSwitchItem(Keys.QUICK_DOWNLOAD)
        quickDownload.title = "Download shortcut"
        quickDownload.content = "Show download button in list"
        quickDownload.onCheckedChanged = { newValue in
            self.shouldRefreshWhenDismiss = true
        }

        personalizationGroup.addArrangedSubview(quickDownload)

        let qualityGroup = SettingsGroup()
        qualityGroup.label = "QUALITY"

        loadingQualityItem = SettingsItem(frame: CGRect.zero)
        loadingQualityItem.title = "Thumbnails"
        loadingQualityItem.content = AppSettings.LOADING_OPTIONS[AppSettings.loadingQuality()]
        loadingQualityItem.onClicked = {
            self.popupListQualityChosenDialog()
        }

        savingQualityItem = SettingsItem(frame: CGRect.zero)
        savingQualityItem.title = "Save"
        savingQualityItem.content = AppSettings.SAVING_OPTIONS[AppSettings.savingQuality()]
        savingQualityItem.onClicked = {
            self.popupSavingQualityChosenDialog()
        }
        
        let clearItem = SettingsItem(frame: CGRect.zero)
        clearItem.title = "Clear cache"
        clearItem.content = "Remove all cached images"
        clearItem.onClicked = {
            self.clearCache()
        }

        qualityGroup.addArrangedSubview(loadingQualityItem)
        qualityGroup.addArrangedSubview(savingQualityItem)
        qualityGroup.addArrangedSubview(clearItem)
        
        let aboutGroup = SettingsGroup()
        aboutGroup.label = "ABOUT"
        
        let feedbackView = SettingsItem(frame: CGRect.zero)
        feedbackView.title = "Feedback"
        feedbackView.content = "Tell me your thoughts :)"
        feedbackView.onClicked = {
            self.delegate?.onClickFeedback()
        }
        
        let versionView = SettingsItem(frame: CGRect.zero)
        versionView.title = "Versions"
        versionView.content = UIApplication.shared.versionBuild()

        aboutGroup.addArrangedSubview(feedbackView)
        aboutGroup.addArrangedSubview(versionView)

        scrollView.addSubview(personalizationGroup)
        scrollView.addSubview(qualityGroup)
        scrollView.addSubview(aboutGroup)

        addSubview(titleView)
        addSubview(closeView)
        addSubview(scrollView)

        titleView.snp.makeConstraints { maker in
            maker.left.equalTo(self.snp.left).offset(Dimensions.TITLE_MARGIN)
            maker.top.equalTo(self.snp.top).offset(40)
        }
        closeView.snp.makeConstraints { maker in
            maker.width.height.equalTo(Dimensions.NAVIGATION_ICON_SIZE)
            maker.right.equalTo(self.snp.right).offset(-12)
            maker.top.equalTo(titleView.snp.top)
            maker.bottom.equalTo(titleView.snp.bottom)
        }
        personalizationGroup.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(self)
            maker.top.equalTo(scrollView.snp.top).offset(Dimensions.TITLE_MARGIN)
        }
        qualityGroup.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(self)
            maker.top.equalTo(personalizationGroup.snp.bottom).offset(Dimensions.TITLE_MARGIN)
        }
        aboutGroup.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(self)
            maker.top.equalTo(qualityGroup.snp.bottom).offset(Dimensions.TITLE_MARGIN)
        }
        scrollView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalTo(self)
            maker.top.equalTo(titleView.snp.bottom).offset(0)
        }
    }
    
    private func clearCache() {
        Nuke.ImageCache.shared.removeAll()
        self.showToast("Cleared")
    }

    func updatingSingleChoiceSelected(selectedIndex: Int, key: String) {
        if (key == Keys.SAVING_QUALITY) {
            savingQualityItem.content = AppSettings.SAVING_OPTIONS[selectedIndex]
        } else {
            loadingQualityItem.content = AppSettings.LOADING_OPTIONS[selectedIndex]
        }
    }

    private func popupListQualityChosenDialog() {
        let selected = UserDefaults.standard.integer(key: Keys.LOADING_QUALITY, defaultValue: 0)
        let content  = SingleChoiceDialog(
                title: loadingQualityItem.title,
                options: AppSettings.LOADING_OPTIONS,
                selected: selected)
        delegate?.showDialog(content: content, key: Keys.LOADING_QUALITY)
    }

    private func popupSavingQualityChosenDialog() {
        let selected = UserDefaults.standard.integer(key: Keys.SAVING_QUALITY, defaultValue: 1)
        let content  = SingleChoiceDialog(
                title: savingQualityItem.title,
                options: AppSettings.SAVING_OPTIONS,
                selected: selected)
        delegate?.showDialog(content: content, key: Keys.SAVING_QUALITY)
    }

    @objc
    private func onClickCloseButton() {
        delegate?.onClickClose(shouldRefreshWhenDismiss: shouldRefreshWhenDismiss)
    }
}
