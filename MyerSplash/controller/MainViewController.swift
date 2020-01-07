import Foundation
import Tabman
import Pageboy
import UIKit
import SnapKit
import Alamofire
import MaterialComponents.MaterialButtons

class MainViewController: TabmanViewController, ImageDetailViewDelegate, ImagesViewControllerDelegate {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            appStatusBarStyle
        }
    }

    private let viewControllers = [ImagesViewController(NewImageRepo()),
                                   ImagesViewController(HighlightsImageRepo()),
                                   ImagesViewController(RandomImageRepo()),
                                   ImagesViewController(DeveloperImageRepo())]

    private var imageDetailView: ImageDetailView!
    
    private var moreRippleController: MDCRippleTouchController!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.getDefaultBackgroundUIColor()

        self.dataSource = self

        viewControllers.forEach { (controller) in
            controller.delegate = self
        }

        let bar = createTopTabBar()
        addBar(bar, dataSource: self, at: .top)
        
        // MARK: statusBarPlaceholder
        let statusBarPlaceholder = UIView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIView.topInset))
        statusBarPlaceholder.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        self.view.addSubview(statusBarPlaceholder)

        // MARK: MORE
        let moreButton = UIButton()
        let moreImage = UIImage.init(named: "ic_more_horiz_white")!.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(moreImage, for: .normal)
        moreButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        moreButton.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        moreButton.addTarget(self, action: #selector(onClickSettings), for: .touchUpInside)
        self.view.addSubview(moreButton)

        moreRippleController = MDCRippleTouchController.load(intoView: moreButton,
                withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3), maxRadius: 25)

        moreButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(statusBarPlaceholder.snp.bottom)
            maker.right.equalTo(self.view.snp.right).offset(-10)
            maker.bottom.equalTo(bar.snp.bottom).offset(-15)
            maker.width.equalTo(50)
        }

        // MARK: FAB
        let fab = MDCFloatingButton()
        let searchImage = UIImage.init(named: "round_search")?.withRenderingMode(.alwaysTemplate)
        fab.setImage(searchImage, for: .normal)
        fab.tintColor = UIColor.black
        fab.backgroundColor = UIColor.white
        fab.addTarget(self, action: #selector(onClickSearch), for: .touchUpInside)
        self.view.addSubview(fab)

        fab.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.view).offset(-16)
            maker.bottom.equalTo(self.view).offset(UIView.hasTopNotch ? -24 : -16)
            maker.width.equalTo(50)
            maker.height.equalTo(50)
        }

        // MARK: ImageDetailView
        imageDetailView = ImageDetailView(frame: CGRect(x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height))
        imageDetailView.delegate = self
        self.view.addSubview(imageDetailView)
    }

    @objc
    func onClickSearch() {
        // todo
        self.view.showToast("Not impl yet :D")
    }

    // MARK: ImagesViewControllerDelegate
    func onClickImage(rect: CGRect, image: UnsplashImage) {
        imageDetailView?.show(initFrame: rect, image: image)
    }

    func onRequestDownload(image: UnsplashImage) {
        var reachability: Reachability!

        do {
            reachability = try Reachability()
        } catch {
            print("Unable to create Reachability")
            return
        }

        if reachability.connection != .unavailable {
            print("isReachable")
        } else {
            print("is NOT Reachable")
            self.view.showToast("Network unavailable :(")
            return
        }

        if reachability.connection != .wifi {
            print("NOT using wifi")
            if AppSettings.isMeteredEnabled() {
                let alertController = MDCAlertController(title: "Alert", message: "You are using meterred network, continue to download?")
                let ok = MDCAlertAction(title: "OK") { (action) in
                    self.doDownload(image)
                }
                let cancel = MDCAlertAction(title: "CANCEL") { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                alertController.addAction(ok)
                alertController.addAction(cancel)

                present(alertController, animated: true, completion: nil)
                return
            }
        }

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
        onRequestDownload(image: image)
    }

    @objc
    private func onClickSettings() {
        let controller = MoreViewController()
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
        viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        .first
    }
}
