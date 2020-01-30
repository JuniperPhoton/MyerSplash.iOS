import Foundation
import UIKit
import SnapKit
import Nuke
import MessageUI
import MaterialComponents.MaterialDialogs

protocol SettingsViewDelegate: class {
    func showDialog(content: DialogContent, key: String)
    func present(vc: UIViewController)
}

class SettingsView: UIView {
    private var loadingQualityItem: SettingsItem!
    private var savingQualityItem: SettingsItem!

    private var scrollView: UIScrollView!

    var shouldRefreshWhenDismiss = false

    weak var delegate: SettingsViewDelegate? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUi()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func initUi() {
        self.setDefaultBackgroundColor()

        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        let personalizationGroup = SettingsGroup()
        personalizationGroup.label = R.strings.settings_personalization

        let quickDownload = SettingsSwitchItem(Keys.METERED)
        quickDownload.title = R.strings.settings_metered
        quickDownload.content = R.strings.settings_metered_message
        
        let darkMaskSwitch = SettingsSwitchItem(Keys.DAKR_MASK)
        darkMaskSwitch.title = R.strings.settings_dark_mask_title
        darkMaskSwitch.content = R.strings.settings_dark_mask_content
        darkMaskSwitch.onCheckedChanged = { checked in
            NotificationCenter.default.post(name: NSNotification.Name(AppNotification.KEY_RELOAD), object: nil)
        }

        personalizationGroup.addArrangedSubview(quickDownload)
        personalizationGroup.addArrangedSubview(darkMaskSwitch)

        let qualityGroup = SettingsGroup()
        qualityGroup.label = R.strings.settings_quality

        loadingQualityItem = SettingsItem(frame: CGRect.zero)
        loadingQualityItem.title = R.strings.settings_quality_browsing
        loadingQualityItem.onClicked = {
            self.popupListQualityChosenDialog()
        }

        savingQualityItem = SettingsItem(frame: CGRect.zero)
        savingQualityItem.title = R.strings.settings_quality_download
        savingQualityItem.onClicked = {
            self.popupSavingQualityChosenDialog()
        }

        updateSingleChoiseItem()

        let clearItem = SettingsItem(frame: CGRect.zero)
        clearItem.title = R.strings.settings_clear
        clearItem.content = ImageIO.getFormattedDiskCacheSize()
        clearItem.onClicked = { [weak self] in
            self?.clearCache()
            clearItem.content = "0.0MB"
        }

        qualityGroup.addArrangedSubview(loadingQualityItem)
        qualityGroup.addArrangedSubview(savingQualityItem)
        qualityGroup.addArrangedSubview(clearItem)

        scrollView.addSubview(personalizationGroup)
        scrollView.addSubview(qualityGroup)

        addSubview(scrollView)

        personalizationGroup.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(self)
            maker.top.equalTo(scrollView.snp.top).offset(8)
        }
        qualityGroup.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(self)
            maker.top.equalTo(personalizationGroup.snp.bottom).offset(Dimensions.TITLE_MARGIN)
        }
        scrollView.snp.makeConstraints { (maker) in
            maker.left.right.bottom.equalTo(self)
            maker.top.equalToSuperview()
        }
    }

    private func updateSingleChoiseItem() {
        loadingQualityItem.content = AppSettings.LOADING_OPTIONS[AppSettings.loadingQuality()]
        savingQualityItem.content = AppSettings.SAVING_OPTIONS[AppSettings.savingQuality()]
    }

    private func clearCache() {
        ImageIO.clearCaches(includingDownloads: false)
        self.showToast(R.strings.cleared)
    }

    private func popupListQualityChosenDialog() {
        let selected = UserDefaults.standard.integer(key: Keys.LOADING_QUALITY, defaultValue: 0)
        let content = SingleChoiceDialog(
                title: loadingQualityItem.title,
                options: AppSettings.LOADING_OPTIONS,
                selected: selected)
        presentBottomSheet(content, { [weak self] i in
            UserDefaults.standard.setValue(i, forKey: Keys.LOADING_QUALITY)
            self?.updateSingleChoiseItem()
        })
    }

    private func popupSavingQualityChosenDialog() {
        let selected = UserDefaults.standard.integer(key: Keys.SAVING_QUALITY, defaultValue: 1)
        let content = SingleChoiceDialog(
                title: savingQualityItem.title,
                options: AppSettings.SAVING_OPTIONS,
                selected: selected)
        presentBottomSheet(content) { [weak self] i in
            UserDefaults.standard.setValue(i, forKey: Keys.SAVING_QUALITY)
            self?.updateSingleChoiseItem()
        }
    }

    private let transitionController = MDCDialogTransitionController()

    private func presentBottomSheet(_ content: SingleChoiceDialog, _ onSelected: @escaping (Int) -> Void) {
        let targetController = DialogViewController(dialogContent: content)
        targetController.modalPresentationStyle = .custom;
        targetController.transitioningDelegate = self.transitionController;
        targetController.makeNormalDialogSize()
        targetController.onItemSelected = onSelected
        delegate?.present(vc: targetController)
    }
}

extension DialogViewController {
    private static let MAX_WIDTH: CGFloat = 400
    private static let MAX_HEIGHT: CGFloat = 230

    func makeNormalDialogSize() {
        var width = UIScreen.main.bounds.width
        
        if UIDevice.current.userInterfaceIdiom == .pad && width > DialogViewController.MAX_WIDTH {
            width = DialogViewController.MAX_WIDTH
        }
        self.preferredContentSize = CGSize(
            width: width,
            height: DialogViewController.MAX_HEIGHT
        )
    }
}
