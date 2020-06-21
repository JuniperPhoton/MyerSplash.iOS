import Foundation
import Tabman
import Pageboy
import UIKit
import SnapKit
import Alamofire
import MaterialComponents.MaterialButtons
import RxSwift

func getTopBarHeight()-> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        #if targetEnvironment(macCatalyst)
        return 110
        #endif
        return 90
    } else {
        return 60
    }
}

class MainViewController: TabmanViewController, ImageDetailViewDelegate, ImagesViewControllerDelegate {
    private static let BAR_BUTTON_SIZE = 50.cgFloat
    private static let BAR_BUTTON_RIGHT_MARGIN = 12.cgFloat

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            appStatusBarStyle
        }
    }
    
    private let viewControllers: [ImagesViewController] = [ImagesViewController(NewImageRepo()),
                                                           ImagesViewController(HighlightsImageRepo()),
                                                           ImagesViewController(RandomImageRepo()),
                                                           ImagesViewController(DeveloperImageRepo())]
    
    private lazy var imageDetailView: ImageDetailView = {
        let v = ImageDetailView()
        v.delegate = self
        return v
    }()
    
    private var moreRippleController: MDCRippleTouchController!
    private var downloadsRippleController: MDCRippleTouchController!
    
    private lazy var bar: TMBar.ButtonBar = {
        return createTopTabBar()
    }()
    
    private lazy var statusBarPlaceholder: UIView = {
        let v = UIView()
        let blurView = UIView.makeBlurBackgroundView()
        v.addSubview(blurView)
        return v
    }()
    
    private lazy var moreButton: UIButton = {
        let moreButton = UIButton()
        let moreImage = UIImage(named: R.icons.ic_more)!.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(moreImage, for: .normal)
        moreButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        moreButton.addTarget(self, action: #selector(onClickMore), for: .touchUpInside)
        self.view.addSubview(moreButton)
        
        moreRippleController = MDCRippleTouchController.load(intoView: moreButton,
                                                              withColor: R.colors.rippleColor, maxRadius: 25)
        return moreButton
    }()
    
    private lazy var downloadsButton: UIButton = {
        let downloadsButton = UIButton()
        
        let downloadImage = UIImage(named: R.icons.ic_download)!.withRenderingMode(.alwaysTemplate)
        downloadsButton.setImage(downloadImage, for: .normal)
        downloadsButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        downloadsButton.addTarget(self, action: #selector(onClickDownloads), for: .touchUpInside)
        self.view.addSubview(downloadsButton)

        downloadsRippleController = MDCRippleTouchController.load(intoView: downloadsButton,
                                                                  withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3), maxRadius: 25)
        downloadsButton.isHidden = UIApplication.shared.windows[0].bounds.width <= Dimensions.MIN_MODE_WIDTH
        return downloadsButton
    }()
    
    private lazy var fab: MDCFloatingButton = {
        let fab = MDCFloatingButton()
        let searchImage = UIImage(named: R.icons.ic_search)?.withRenderingMode(.alwaysTemplate)
        fab.setImage(searchImage, for: .normal)
        fab.tintColor = UIColor.black
        fab.backgroundColor = UIColor.white
        fab.addTarget(self, action: #selector(onClickSearch), for: .touchUpInside)
        self.view.addSubview(fab)
        
        fab.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.view).offset(-16)
            maker.bottom.equalTo(self.view).offset(UIView.hasTopNotch ? -24 : -16)
            maker.size.equalTo(MainViewController.BAR_BUTTON_SIZE)
        }
        return fab
    }()

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
        
        viewControllers.forEach { (controller) in
            #if targetEnvironment(macCatalyst)
            (controller as ImagesViewController).collectionTopOffset = getTopBarHeight() - 20
            #else
            (controller as ImagesViewController).collectionTopOffset = getTopBarHeight()
            #endif
        }
        
        self.view.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        
        self.dataSource = self
        
        viewControllers.forEach { (controller) in
            controller.delegate = self
        }
        
        self.view.addSubViews(statusBarPlaceholder, imageDetailView)
        
        DownloadManager.instance.markDownloadingToFailed()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let topVc = UIApplication.shared.getTopViewController()
        if topVc != self {
            topVc?.viewWillTransition(to: size, with: coordinator)
        }

        self.viewControllers.forEach { (controller) in
            controller.viewWillTransition(to: size, with: coordinator)
        }
        imageDetailView.invalidate(newBounds: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        
        invalidateTabBar(size)
    }
    
    private func invalidateTabBar(_ size: CGSize) {
        downloadsButton.isHidden = size.width <= Dimensions.MIN_MODE_WIDTH

        removeBar(bar)
        
        addBar(bar, dataSource: self, at: .custom(view: statusBarPlaceholder, layout: { v in
            v.frame = CGRect(x: 0, y: UIView.topInset, width: size.width - self.getTabBarMaringRight(), height: getTopBarHeight())
        }))
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let barLayout = bar.layout.view.subviews.first(where: { (view) -> Bool in
            view is UIStackView
        }) else {
            return
        }
        
        statusBarPlaceholder.pin.height(UIView.topInset + getTopBarHeight()).width(of: self.view)
        moreButton.pin.right(MainViewController.BAR_BUTTON_RIGHT_MARGIN).vCenter(to: barLayout.edge.vCenter).size(MainViewController.BAR_BUTTON_SIZE)
        downloadsButton.pin.before(of: moreButton).vCenter(to: moreButton.edge.vCenter).size(MainViewController.BAR_BUTTON_SIZE)
        imageDetailView.pin.all()
    }
    
    private func getTabBarMaringRight() -> CGFloat {
        var margin: CGFloat = 0
        if !moreButton.isHidden {
            margin += MainViewController.BAR_BUTTON_SIZE
            margin += MainViewController.BAR_BUTTON_RIGHT_MARGIN
        }
        
        if !downloadsButton.isHidden {
            margin += MainViewController.BAR_BUTTON_SIZE
        }
        
        return margin
    }
    
    func onRequestEdit(item: DownloadItem) {
        presentEdit(item: item)
    }
    
    @objc
    func onClickSearch() {
        Events.trackClickSearch()
        
        let vc = SearchViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: ImagesViewControllerDelegate
    func onClickImage(rect: CGRect, image: UnsplashImage) -> Bool {
        imageDetailView.show(initFrame: rect, image: image)
        return true
    }
    
    func onRequestDownload(image: UnsplashImage) {
        DownloadManager.instance.prepareToDownload(vc: self, image: image)
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
        DownloadManager.instance.prepareToDownload(vc: self, image: image)
    }
    
    @objc
    private func onClickMore() {
        Events.trackClickMore()
        let controller = MoreViewController(selectedIndex: UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0)
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc
    private func onClickDownloads() {
        Events.trackClickMore()
        let controller = MoreViewController(selectedIndex: 0)
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
}

extension MainViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: (viewControllers[index].repoTitle!))
        return item
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        if let imageVc = vc as? ImagesViewController,
            let title = imageVc.repoTitle {
            Events.trackTabSelected(name: title)
        }
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
