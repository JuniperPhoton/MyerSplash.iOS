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
        self.automaticallyAdjustsChildInsets = true
        
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.getDefaultBackgroundUIColor()

        self.dataSource = self

        viewControllers.forEach { (controller) in
            controller.delegate = self
        }

        let bar = createTopTabBar()
        bar.fadesContentEdges = true
        addBar(bar, dataSource: self, at: .top)
        
        let an = self.barInsets
        print("ancor is ", an)
        
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
        let vc = SearchViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: ImagesViewControllerDelegate
    func onClickImage(rect: CGRect, image: UnsplashImage)-> Bool {
        imageDetailView?.show(initFrame: rect, image: image)
        return true
    }

    func onRequestDownload(image: UnsplashImage) {
        DownloadManager.prepareToDownload(vc: self, image: image) { [weak self] (imagePath) in
            guard let self = self else {
                return
            }
            UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: imagePath)!, self, #selector(self.onSavedOrError), nil)
        }
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
        DownloadManager.prepareToDownload(vc: self, image: image) { [weak self] (imagePath) in
            guard let self = self else {
                return
            }
            UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: imagePath)!, self, #selector(self.onSavedOrError), nil)
        }
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
    
    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        DownloadManager.showSavedToastOnVC(self, success: error == nil)
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
