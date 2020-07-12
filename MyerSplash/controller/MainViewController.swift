import Foundation
import Tabman
import Pageboy
import UIKit
import Alamofire
import MaterialComponents.MaterialButtons
import RxSwift
import SwiftUI
import MyerSplashDesign

class MainViewController: TabmanViewController {
    public static let BAR_BUTTON_SIZE = 50.cgFloat
    public static let BAR_BUTTON_RIGHT_MARGIN = 12.cgFloat
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            appStatusBarStyle
        }
    }
    
    private var viewControllers: [ImagesViewController] = [ImagesViewController(NewImageRepo()),
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
    private var searchRippleController: MDCRippleTouchController?

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
        
        moreRippleController = MDCRippleTouchController.load(view: moreButton)
        return moreButton
    }()
    
    private lazy var downloadsButton: UIButton = {
        let downloadsButton = UIButton()
        
        let downloadImage = UIImage(named: R.icons.ic_download)!.withRenderingMode(.alwaysTemplate)
        downloadsButton.setImage(downloadImage, for: .normal)
        downloadsButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        downloadsButton.addTarget(self, action: #selector(onClickDownloads), for: .touchUpInside)
        
        downloadsRippleController = MDCRippleTouchController.load(view: downloadsButton)
        downloadsButton.isHidden = UIApplication.shared.windows[0].bounds.width <= Dimensions.MIN_MODE_WIDTH
        return downloadsButton
    }()
    
    private lazy var searchButton: UIButton = {
        let searchButton = UIButton()
        
        let searchImage = UIImage(named: R.icons.ic_search)!.withRenderingMode(.alwaysTemplate)
        searchButton.setImage(searchImage, for: .normal)
        searchButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        searchButton.addTarget(self, action: #selector(onClickSearch), for: .touchUpInside)
        
        searchRippleController = MDCRippleTouchController.load(view: searchButton)
        searchButton.isHidden = UIApplication.shared.windows[0].bounds.width <= Dimensions.MIN_MODE_WIDTH
        return searchButton
    }()
    
    private lazy var fab: MDCFloatingButton = {
        let fab = MDCFloatingButton()
        let searchImage = UIImage(named: R.icons.ic_search)?.withRenderingMode(.alwaysTemplate)
        fab.setImage(searchImage, for: .normal)
        fab.tintColor = UIColor.black
        fab.backgroundColor = UIColor.white
        fab.addTarget(self, action: #selector(onClickSearch), for: .touchUpInside)
        fab.isHidden = UIApplication.shared.windows[0].bounds.width > Dimensions.MIN_MODE_WIDTH
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
        self.automaticallyAdjustsChildInsets = false
        
        super.viewDidLoad()
        
        setupViewControllers()
        
        self.view.backgroundColor = UIColor.getDefaultBackgroundUIColor()
        
        self.dataSource = self
        
        self.view.addSubViews(statusBarPlaceholder, moreButton, downloadsButton, searchButton, fab, imageDetailView)
        
        invalidateTabBar(UIApplication.shared.windows[0].bounds.size)
        
        DownloadManager.instance.markDownloadingToFailed()
    }
    
    private func setupViewControllers() {
        viewControllers.forEach { (controller) in
            #if targetEnvironment(macCatalyst)
            (controller as ImagesViewController).collectionTopOffset = getContentTopInsets()
            #else
            (controller as ImagesViewController).collectionTopOffset = getTopBarHeight()
            #endif
            controller.delegate = self
        }
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
        downloadsButton.isHidden = UIDevice.current.userInterfaceIdiom == .phone || size.width <= Dimensions.MIN_MODE_WIDTH
        searchButton.isHidden = downloadsButton.isHidden
        fab.isHidden = !searchButton.isHidden
        
        removeBar(bar)
        
        addBar(bar, dataSource: self, at: .custom(view: statusBarPlaceholder, layout: { v in
            v.frame = CGRect(x: 0, y: CGFloat(UIView.topInset), width: size.width - self.getTabBarMaringRight(), height: getTopBarHeight())
        }))
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let barLayout = bar.layout.view.subviews.first(where: { (view) -> Bool in
            view is UIStackView
        }) else {
            return
        }
        
        let statusBarHeight = getTopBarHeight() + UIView.topInset
        
        statusBarPlaceholder.pin.height(statusBarHeight).width(of: self.view)
        moreButton.pin.right(MainViewController.BAR_BUTTON_RIGHT_MARGIN).vCenter(to: barLayout.edge.vCenter).size(MainViewController.BAR_BUTTON_SIZE)
        downloadsButton.pin.before(of: moreButton).vCenter(to: moreButton.edge.vCenter).size(MainViewController.BAR_BUTTON_SIZE)
        searchButton.pin.before(of: downloadsButton).vCenter(to: downloadsButton.edge.vCenter).size(MainViewController.BAR_BUTTON_SIZE)

        fab.pin.right(16).bottom(UIView.hasTopNotch ? 24.cgFloat : 16.cgFloat).size(MainViewController.BAR_BUTTON_SIZE)
        
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
        
        if !searchButton.isHidden {
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
        
        if #available(iOS 13.0, *) {
            #if !targetEnvironment(macCatalyst)
            let vc = SearchViewController()
            self.present(vc, animated: true, completion: nil)
            #else
            let view = SearchView(dismissAction: { [weak self] in
                    guard let self = self else { return }
                    self.dismiss(animated: true, completion: nil)
                }, onClickKeyword: { [weak self] k in
                    guard let self = self else { return }
                    print("click \(k)")
                    self.dismiss(animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                        guard let self = self else { return }
                        self.addTab(keyword: k)
                    }
            })
            let vc = UIHostingController(rootView: view)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
            #endif
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func addTab(keyword: Keyword) {
        let index: Int? = self.viewControllers.firstIndex { (vc) -> Bool in
            return vc.repoTitle?.caseInsensitiveCompare(keyword.displayTitle) == ComparisonResult.orderedSame
        }
        
        if let i = index {
            self.scrollToPage(.at(index: i), animated: true)
            return
        }
        
        let repo = SearchImageRepo(query: keyword.query)
        repo.title = keyword.displayTitle.uppercased()
        self.viewControllers.append(ImagesViewController(repo))
        setupViewControllers()
        insertPage(at: viewControllers.count - 1, then: .scrollToUpdate)
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

extension MainViewController: ImageDetailViewDelegate {
    // MARK: ImageDetailViewDelegate
    func onHidden(frameAnimationSkipped: Bool) {
        if let vc = self.currentViewController as? ImagesViewController {
            vc.showTappedCell(withAlphaAnimation: frameAnimationSkipped)
        }
    }
    
    func onRequestOpenUrl(urlString: String) {
        UIApplication.shared.open(URL(string: urlString)!)
    }
    
    func onRequestImageDownload(image: UnsplashImage) {
        DownloadManager.instance.prepareToDownload(vc: self, image: image)
    }
}

extension MainViewController: ImagesViewControllerDelegate {
    // MARK: ImagesViewControllerDelegate
    func onClickImage(rect: CGRect, image: UnsplashImage) -> Bool {
        imageDetailView.show(initFrame: rect, image: image)
        return true
    }
    
    func onRequestDownload(image: UnsplashImage) {
        DownloadManager.instance.prepareToDownload(vc: self, image: image)
    }
}
