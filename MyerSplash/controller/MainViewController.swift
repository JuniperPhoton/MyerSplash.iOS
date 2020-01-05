import Foundation
import Tabman
import Pageboy
import UIKit
import SnapKit
import Alamofire
import MaterialComponents.MaterialTabs

class MainViewController: TabmanViewController, ImageDetailViewDelegate, ImagesViewControllerDelegate {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return appStatusBarStyle
        }
    }

    private let viewControllers = [ImagesViewController(NewImageRepo()),
                                   ImagesViewController(HighlightsImageRepo()),
                                   ImagesViewController(RandomImageRepo()),
                                   ImagesViewController(DeveloperImageRepo())]

    private var imageDetailView: ImageDetailView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIView.getDefaultBackgroundUIColor()
    
        self.dataSource = self
        
        viewControllers.forEach { (controller) in
            controller.delegate = self
        }

        // Create bar
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.layout.alignment = .leading
        bar.layout.contentInset = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 12.0, right: 50)
        bar.backgroundView.style = .flat(color: UIView.getDefaultBackgroundUIColor())
        bar.layout.interButtonSpacing = 12
        bar.buttons.customize { (button) in
            button.tintColor = UIView.getDefaultLabelUIColor().withAlphaComponent(0.3)
            button.selectedTintColor = UIView.getDefaultLabelUIColor()
            button.font = UIFont.preferredFont(forTextStyle: .largeTitle).with(traits: .traitBold).withSize(13)
        }
        bar.indicator.tintColor = UIView.getDefaultLabelUIColor()
        bar.indicator.weight = .custom(value: 4)

        // Add to view
        addBar(bar, dataSource: self, at: .top)
        
        let statusBarPlaceholder = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIView.topInset))
        statusBarPlaceholder.backgroundColor = UIView.getDefaultBackgroundUIColor()
        self.view.addSubview(statusBarPlaceholder)
        
        let moreButton = UIButton()
        let moreImage = UIImage.init(named: "ic_more_horiz_white")!.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(moreImage, for: .normal)
        moreButton.tintColor = UIView.getDefaultLabelUIColor().withAlphaComponent(0.3)
        moreButton.backgroundColor = UIView.getDefaultBackgroundUIColor()
        moreButton.addTarget(self, action: #selector(onClickSettings), for: .touchUpInside)
        self.view.addSubview(moreButton)
        
        moreButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(statusBarPlaceholder.snp.bottom)
            maker.right.equalTo(self.view.snp.right)
            maker.bottom.equalTo(bar.snp.bottom).offset(-15)
            maker.width.equalTo(50)
        }
        
        let fab = MDCFloatingButton()
        let searchImage = UIImage.init(named: "round_search")?.withRenderingMode(.alwaysTemplate)
        fab.setImage(searchImage, for: .normal)
        fab.tintColor = UIColor.black
        fab.backgroundColor = UIColor.white
        self.view.addSubview(fab)
        
        fab.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.view).offset(-16)
            maker.bottom.equalTo(self.view).offset(UIView.hasTopNotch ? -24: -16)
            maker.width.equalTo(50)
            maker.height.equalTo(50)
        }
        
        imageDetailView = ImageDetailView(frame: CGRect(x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height))
        imageDetailView.delegate = self
        self.view.addSubview(imageDetailView)
    }
    
    // MARK: ImagesViewControllerDelegate
    func onClickImage(rect: CGRect, image: UnsplashImage) {
        imageDetailView?.show(initFrame: rect, image: image)
    }
    
    func onRequestDownload(image: UnsplashImage) {
        doDownload(image)
    }
    
    // MARK: ImageDetailViewDelegate
    func onHidden() {
        if let vc = self.currentViewController as? ImagesViewController {
            vc.showTappedCell()
        }
    }
    
    func onRequestOpenUrl(urlString: String) {
        UIApplication.shared.open(URL(string: urlString)!)
    }

    func onRequestImageDownload(image: UnsplashImage) {
        doDownload(image)
    }
    
    @objc
    private func onClickSettings() {
        let controller = SettingsViewController()
        self.present(controller, animated: true, completion: nil)
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: cell callback

    private func doDownload(_ unsplashImage: UnsplashImage) {
        print("downloading: \(unsplashImage.downloadUrl ?? "")")

        view.showToast("Downloading in background...")

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL
                    = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(unsplashImage.fileName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Events.trackBeginDownloadEvent()

        Alamofire.download(unsplashImage.downloadUrl!, to: destination).response { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            if response.error == nil, let imagePath = response.destinationURL?.path {
                print("image downloaded!")
                Events.trackDownloadEvent(true)
                UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: imagePath)!, self, #selector(self.onSavedOrError), nil)
            } else {
                Events.trackDownloadEvent(false, response.error?.localizedDescription)
                print("error while download image: %@", response.error ?? "")
            }
        }
    }

    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        if (error == nil) {
            view.showToast("Saved to your album :D")
        } else {
            view.showToast("Failed to download :(")
        }
    }
}

extension MainViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: (viewControllers[index].repoTitle!))
        return item
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
