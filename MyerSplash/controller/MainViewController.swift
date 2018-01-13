import Foundation
import UIKit
import SnapKit
import Alamofire

class MainViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate,
        NavigationViewDelegate, SettingsDelegate {
    private var images: [UnsplashImage] = [UnsplashImage]()
    private var mainView: MainView!

    private var loadingFooterView: LoadingFooterView!

    private var paging = 1
    private var loading = false
    private var canLoadMore = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.navigationView.delegate = self

        let tableView = mainView.tableView!
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.allowsSelection = false
        tableView.register(MainImageTableCell.self, forCellReuseIdentifier: MainImageTableCell.ID)

        loadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0,
                width: UIScreen.main.bounds.width, height: 100))
        tableView.tableFooterView = loadingFooterView

        mainView.onRefresh = {
            self.refreshData()
        }

        refreshData()
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
        CloudService.getNewPhotos(page: paging) {
            response in
            if (refreshing) {
                self.images.removeAll(keepingCapacity: false)

                if (AppSettings.isTodayEnabled()) {
                    self.images.append(UnsplashImage.createToday())
                }
            }
            self.images += response
            self.mainView.tableView.reloadData()
            self.mainView.stopRefresh()
            self.loading = false
            self.canLoadMore = true
        }
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
        cell.onClickMainImage = { (image) -> Void in
            //todo: implement viewing image detail
        }
        cell.bind(image: images[indexPath.row])
        return cell
    }

    // For iOS 11, this method must be conform to provide estimated height.
    // After calling table view's reloadData(), all the items' contents size will be re-calculated,
    // and the table view use estimated height as content size at first,
    // which leads to the incorrect content size of table view.
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateCellHeight()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateCellHeight()
    }

    private func calculateCellHeight() -> CGFloat {
        return UIScreen.main.bounds.width / 1.5
    }

    // MARK: scroll

    private var lastScrollOffset: CGPoint = CGPoint(x: 0, y: 0)

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height) {
            loadMore()
        }

        let dy = scrollView.contentOffset.y - lastScrollOffset.y
        if (dy > 10) {
            mainView.hideFab()
        } else if (dy < -10) {
            mainView.showFab()
        }

        lastScrollOffset = scrollView.contentOffset
    }

    // MARK: cell callback

    private func doDownload(_ unsplashImage: UnsplashImage) {
        print("downloading: \(unsplashImage.downloadUrl)")

        showToast("Downloading in background...")

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(unsplashImage.fileName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        Alamofire.download(unsplashImage.downloadUrl!, to: destination).response { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            if response.error == nil, let imagePath = response.destinationURL?.path {
                print("image downloaded!")
                UIImageWriteToSavedPhotosAlbum(UIImage(contentsOfFile: imagePath)!, self, #selector(self.onSavedOrError), nil)
            } else {
                print(response.error)
            }
        }
    }

    @objc
    private func onSavedOrError(_ image: UIImage,
                                didFinishSavingWithError error: Error?,
                                contextInfo: UnsafeRawPointer) {
        if (error == nil) {
            showToast("Saved to your album :D")
        } else {
            showToast("Failed to download :(")
        }
    }

    // MARK: Setting delegate
    func refresh() {
        if (!AppSettings.isTodayEnabled()) {
            let today = images.first
            if (today != nil && UnsplashImage.isToday(today!)) {
                images.remove(at: 0)
            }
        } else {
            let today = images.first
            if (today != nil && !UnsplashImage.isToday(today!)) {
                images.insert(UnsplashImage.createToday(), at: 0)
            }
        }
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