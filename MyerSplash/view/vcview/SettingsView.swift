import Foundation
import UIKit
import SnapKit
import Nuke
import MessageUI
import MaterialComponents.MaterialDialogs

protocol SettingsViewDelegate: class {
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

        closeView = UIButton(type: .system)
        closeView.setImage(UIImage(named: R.icons.ic_clear), for: .normal)
        closeView.addTarget(self, action: #selector(onClickCloseButton), for: .touchUpInside)
        closeView.tintColor = UIColor.getDefaultLabelUIColor()

        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true

        let personalizationGroup = SettingsGroup()
        personalizationGroup.label = R.strings.settings_personalization

        let quickDownload = SettingsSwitchItem(Keys.METERED)
        quickDownload.title = R.strings.settings_metered
        quickDownload.content = R.strings.settings_metered_message

        personalizationGroup.addArrangedSubview(quickDownload)

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
        clearItem.content = R.strings.settings_clear_cache
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

    private func updateSingleChoiseItem() {
        loadingQualityItem.content = AppSettings.LOADING_OPTIONS[AppSettings.loadingQuality()]
        savingQualityItem.content = AppSettings.SAVING_OPTIONS[AppSettings.savingQuality()]
    }

    private func clearCache() {
        Nuke.ImageCache.shared.removeAll()
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

    @objc
    private func onClickCloseButton() {
        delegate?.onClickClose(shouldRefreshWhenDismiss: shouldRefreshWhenDismiss)
    }
}

extension DialogViewController {
    func makeNormalDialogSize() {
        self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 230)
    }
}
