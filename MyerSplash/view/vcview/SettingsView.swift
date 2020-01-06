import Foundation
import UIKit
import SnapKit
import Nuke
import MessageUI
import MaterialComponents.MaterialDialogs

protocol SettingsViewDelegate {
    func showDialog(content: DialogContent, key: String)
    func onClickClose(shouldRefreshWhenDismiss: Bool)
    func present(vc: UIViewController)
}

class SettingsView: UIView {
    private var closeView: UIButton!
    private var loadingQualityItem: SettingsItem!
    private var savingQualityItem: SettingsItem!

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

        closeView = UIButton(type: .system)
        closeView.setImage(UIImage(named: "ic_clear_white"), for: .normal)
        closeView.addTarget(self, action: #selector(onClickCloseButton), for: .touchUpInside)
        closeView.tintColor = UIColor.getDefaultLabelUIColor()

        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        let personalizationGroup = SettingsGroup()
        personalizationGroup.label = "PERSONALIZATION"

        let quickDownload = SettingsSwitchItem(Keys.METERED)
        quickDownload.title = "Metered network warning"
        quickDownload.content = "Notice you before downloading"

        personalizationGroup.addArrangedSubview(quickDownload)

        let qualityGroup = SettingsGroup()
        qualityGroup.label = "QUALITY"

        loadingQualityItem = SettingsItem(frame: CGRect.zero)
        loadingQualityItem.title = "Browsing Quality (WIP)"
        loadingQualityItem.content = AppSettings.LOADING_OPTIONS[AppSettings.loadingQuality()]
        loadingQualityItem.onClicked = {
            self.popupListQualityChosenDialog()
        }

        savingQualityItem = SettingsItem(frame: CGRect.zero)
        savingQualityItem.title = "Download Quality (WIP)"
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

        scrollView.addSubview(personalizationGroup)
        scrollView.addSubview(qualityGroup)

        addSubview(closeView)
        addSubview(scrollView)

        closeView.snp.makeConstraints { maker in
            maker.width.height.equalTo(Dimensions.NAVIGATION_ICON_SIZE)
            maker.right.equalTo(self.snp.right).offset(-12)
            maker.top.equalToSuperview()
        }
        personalizationGroup.snp.makeConstraints { (maker) in
            maker.left.right.equalTo(self)
            maker.top.equalTo(scrollView.snp.top).offset(Dimensions.TITLE_MARGIN)
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
        let content = SingleChoiceDialog(
                title: loadingQualityItem.title,
                options: AppSettings.LOADING_OPTIONS,
                selected: selected)
        presentBottomSheet(content)
    }

    private func popupSavingQualityChosenDialog() {
        let selected = UserDefaults.standard.integer(key: Keys.SAVING_QUALITY, defaultValue: 1)
        let content = SingleChoiceDialog(
                title: savingQualityItem.title,
                options: AppSettings.SAVING_OPTIONS,
                selected: selected)
        presentBottomSheet(content)
    }

    private func presentBottomSheet(_ content: SingleChoiceDialog) {
        let targetController = DialogViewController(dialogContent: content)
        let sheetController = MDCBottomSheetController(contentViewController: targetController)
        sheetController.makeNormalDialogSize()
        delegate?.present(vc: sheetController)
    }

    @objc
    private func onClickCloseButton() {
        delegate?.onClickClose(shouldRefreshWhenDismiss: shouldRefreshWhenDismiss)
    }
}

extension MDCBottomSheetController {
    func makeNormalDialogSize() {
        self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 230)
    }
}
