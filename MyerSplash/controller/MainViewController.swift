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
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            appStatusBarStyle
        }
    }
    
    private let viewControllers: [ImagesViewController] = [ImagesViewController(NewImageRepo()),
                                                           ImagesViewController(HighlightsImageRepo()),
                                                           ImagesViewController(RandomImageRepo()),
                                                           ImagesViewController(DeveloperImageRepo())]
    
    private var imageDetailView: ImageDetailView!
    
    private var moreRippleController: MDCRippleTouchController!
    private var downloadsRippleController: MDCRippleTouchController!
    
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
        
        // MARK: statusBarPlaceholder
        let statusBarPlaceholder = UIView()
        
        let blurView = UIView.makeBlurBackgroundView()
        statusBarPlaceholder.addSubview(blurView)
        
        self.view.addSubview(statusBarPlaceholder)
        
        statusBarPlaceholder.snp.makeConstraints { (maker) in
            maker.width.equalToSuperview()
            maker.height.equalTo(UIView.topInset + getTopBarHeight())
        }
        
        let bar = createTopTabBar()
        addBar(bar, dataSource: self, at: .custom(view: statusBarPlaceholder, layout: { v in
            v.frame = CGRect(x: 0, y: UIView.topInset, width: UIScreen.main.bounds.width, height: getTopBarHeight())
        }))
        
        // MARK: MORE
        let moreButton = UIButton()
        let moreImage = UIImage(named: R.icons.ic_more)!.withRenderingMode(.alwaysTemplate)
        moreButton.setImage(moreImage, for: .normal)
        moreButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
        moreButton.addTarget(self, action: #selector(onClickMore), for: .touchUpInside)
        self.view.addSubview(moreButton)
        
        moreRippleController = MDCRippleTouchController.load(intoView: moreButton,
                                                             withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3), maxRadius: 25)
        
        moreButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(bar.layout.view.subviews.first(where: { (view) -> Bool in
                view is UIStackView
            })!.snp.top)
            maker.right.equalTo(self.view.snp.right).offset(-10)
            maker.bottom.equalTo(bar.snp.bottom).offset(-15)
            maker.width.equalTo(50)
        }
        
        // MARK: DOWNLOADS
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let downloadsButton = UIButton()
            let downloadImage = UIImage(named: R.icons.ic_download)!.withRenderingMode(.alwaysTemplate)
            downloadsButton.setImage(downloadImage, for: .normal)
            downloadsButton.tintColor = UIColor.getDefaultLabelUIColor().withAlphaComponent(0.5)
            downloadsButton.addTarget(self, action: #selector(onClickDownloads), for: .touchUpInside)
            self.view.addSubview(downloadsButton)
            
            downloadsRippleController = MDCRippleTouchController.load(intoView: downloadsButton,
                                                                      withColor: UIColor.getDefaultLabelUIColor().withAlphaComponent(0.3), maxRadius: 25)
            
            downloadsButton.snp.makeConstraints { (maker) in
                maker.top.equalTo(moreButton.snp.top)
                maker.right.equalTo(moreButton.snp.left).offset(-10)
                maker.bottom.equalTo(moreButton.snp.bottom)
                maker.width.equalTo(50)
            }
        }
        
        // MARK: FAB
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
            maker.width.equalTo(50)
            maker.height.equalTo(50)
        }
        
        // MARK: ImageDetailView
        imageDetailView = ImageDetailView()
        imageDetailView.delegate = self
        self.view.addSubview(imageDetailView)
        
        imageDetailView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        DownloadManager.instance.markDownloadingToFailed()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewControllers.forEach { (controller) in
            controller.viewWillTransition(to: size, with: coordinator)
        }
        imageDetailView.invalidate()
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
        imageDetailView?.show(initFrame: rect, image: image)
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
