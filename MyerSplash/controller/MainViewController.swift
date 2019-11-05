import Foundation
import UIKit
import SnapKit
import Alamofire

class MainViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate,
        NavigationViewDelegate, SettingsDelegate, ImageDetailViewDelegate {
    static func calculateCellHeight(_ width: CGFloat) -> CGFloat {
        return width / 1.5
    }

    static let CELL_ANIMATE_OFFSET_X: CGFloat = 70.0
    static let CELL_ANIMATE_DELAY_UNIT_SEC = 0.3
    static let CELL_ANIMATE_DURATION_SEC = 0.6

    static let HIGHLIGHTS_DELAY_SEC = 0.2

    private var images: [UnsplashImage] = [UnsplashImage]()
    private var mainView: MainView!

    private var loadingFooterView: LoadingFooterView!

    private var paging = 1
    private var loading = false
    private var canLoadMore = false

    private var calculatedCellHeight: CGFloat = -1.0
    private var initialMaxVisibleCellCount = -1

    private var cellDisplayAnimatedCount = 0

    private var tappedCell: UITableViewCell? = nil

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true

        mainView.navigationView.delegate = self

        let tableView = mainView.tableView!
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.allowsSelection = false
        tableView.register(MainImageTableCell.self, forCellReuseIdentifier: MainImageTableCell.ID)

        loadingFooterView = LoadingFooterView(frame: CGRect(x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: 100))
        tableView.tableFooterView = loadingFooterView

        mainView.onRefresh = {
            self.refreshData()
        }
        mainView.imageDetailView.delegate = self

        refreshData()
    }

    func onHidden() {
        tappedCell?.isHidden = false
    }

    func onRequestOpenUrl(urlString: String) {
        UIApplication.shared.open(URL(string: urlString)!)
    }

    func onRequestImageDownload(image: UnsplashImage) {
        doDownload(image)
    }

    private func refreshData() {
        paging = 1
        loadData(true)
    }

    private func loadData(_ refreshing: Bool) {
        if (loading) {
            return
        }

        loading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + MainViewController.HIGHLIGHTS_DELAY_SEC) {
            CloudService.getHighlights(page: self.paging) { response in
                self.processResponse(response: response, refreshing)
                self.loading = false
                self.canLoadMore = !response.isEmpty
                self.mainView.stopRefresh()
            }
        }
    }

    private func processResponse(response: [UnsplashImage], _ refreshing: Bool) {
        if (images.count >= 2 && response.count > 0) {
            let firstResponseImage = response.first!
            let firstExistImage = images[1]

            let todayHighlightUpdated = !firstExistImage.isUnsplash
                    && firstExistImage.id != UnsplashImage.createTodayImageId()

            let noNewData = firstExistImage.id == firstResponseImage.id

            // Today highlight is not updated and the first images are match, skip reload data.
            if (noNewData && !todayHighlightUpdated) {
                mainView.showToast("No new data")
                return
            }
        }

        if (refreshing) {
            images.removeAll(keepingCapacity: false)
            cellDisplayAnimatedCount = 0
        }

        images += response
        mainView.tableView.reloadData()
    }

    private func loadMore() {
        if (!canLoadMore) {
            return
        }
        paging = paging + 1
        loadData(false)
    }

    override func loadView() {
        mainView = MainView(frame: CGRect.zero)
        view = mainView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var topSafeArea: CGFloat
        var bottomSafeArea: CGFloat

        if #available(iOS 11.0, *) {
            topSafeArea = view.safeAreaInsets.top
            bottomSafeArea = view.safeAreaInsets.bottom
        } else {
            topSafeArea = topLayoutGuide.length
            bottomSafeArea = bottomLayoutGuide.length
        }

        // safe area values are now available to use
    }

    // MARK: UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: MainImageTableCell.ID, for: indexPath) as? MainImageTableCell else {
            fatalError()
        }
        cell.onClickDownload = { unsplashImage in
            self.doDownload(unsplashImage)
        }
        cell.onClickMainImage = { (rect: CGRect, image: UnsplashImage) -> Void in
            print("rect is %@", rect)
            cell.isHidden = true
            self.tappedCell = cell
            self.mainView.imageDetailView.show(initFrame: rect, image: image)
        }
        cell.bind(image: images[indexPath.row])
        return cell
    }

    // For iOS 11, this method must be conform to provide estimated height.
    // After calling table view's reloadData(), all the items' contents size will be re-calculated,
    // and the table view use estimated height as content size at first,
    // which leads to the incorrect content size of table view.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        calculateAndCacheCellHeight()
        return calculatedCellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        calculateAndCacheCellHeight()
        return calculatedCellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let count = calculateInitialMaxVisibleCellCount()
        if (count < 0) {
            return
        }

        if (cellDisplayAnimatedCount >= count) {
            return
        }

        let index = indexPath.row
        if (index >= count) {
            return
        }

        let startX = cell.center.x
        cell.alpha = 0.0
        cell.center.x += MainViewController.CELL_ANIMATE_OFFSET_X

        let delaySec = Double(index + 1) * MainViewController.CELL_ANIMATE_DELAY_UNIT_SEC

        UIView.animate(withDuration: MainViewController.CELL_ANIMATE_DURATION_SEC,
                delay: delaySec,
                options: UIView.AnimationOptions.curveEaseOut,
                animations: {
                    cell.alpha = 1.0
                    cell.center.x = startX
                },
                completion: nil)

        cellDisplayAnimatedCount += 1
    }

    private func calculateInitialMaxVisibleCellCount() -> Int {
        if (initialMaxVisibleCellCount == -1) {
            calculateAndCacheCellHeight()

            guard let tableView = mainView.tableView,
                  let navigationView = mainView.navigationView else {
                return initialMaxVisibleCellCount
            }

            let visibleHeight = tableView.frame.height - navigationView.frame.height
            initialMaxVisibleCellCount = Int(ceil(Double(visibleHeight) / Double(calculatedCellHeight)))
        }

        return initialMaxVisibleCellCount
    }

    private func calculateAndCacheCellHeight() {
        if (calculatedCellHeight == -1.0) {
            calculatedCellHeight = MainViewController.calculateCellHeight(UIScreen.main.bounds.width)
        }
    }

    // MARK: scroll

    private var lastScrollOffset: CGPoint = CGPoint(x: 0, y: 0)

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // We don't want the over-scrolling takes any showing & hiding effect.
        if (scrollView.contentOffset.y <= 0) {
            return
        }

        if (scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height) {
            loadMore()
        }

        let dy = scrollView.contentOffset.y - lastScrollOffset.y
        if (dy > 10) {
            mainView.hideNavigationElements()
        } else if (dy < -10) {
            mainView.showNavigationElements()
        }

        lastScrollOffset = scrollView.contentOffset
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (scrollView.contentOffset.y <= 0) {
            mainView.showNavigationElements()
        }
    }

    // MARK: cell callback

    private func doDownload(_ unsplashImage: UnsplashImage) {
        print("downloading: \(unsplashImage.downloadUrl ?? "")")

        mainView.showToast("Downloading in background...")

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
                print("error while download image: %@", response.error)
            }
        }
    }

    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        if (error == nil) {
            mainView.showToast("Saved to your album :D")
        } else {
            mainView.showToast("Failed to download :(")
        }
    }

    // MARK: Setting delegate
    func refresh() {
        self.mainView.tableView.reloadData()
    }

    // MARK: MainView callback

    func onClickSettings() {
        let vc = SettingsViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    func onClickTitle() {
        mainView.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}
