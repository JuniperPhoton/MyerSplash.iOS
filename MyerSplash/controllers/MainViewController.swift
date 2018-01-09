import Foundation
import UIKit
import SnapKit
import Alamofire

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NavigationViewCallback {
    private var images: [UnsplashImage] = [UnsplashImage]()
    private var mainView: MainView!

    private var loadingFooterView: LoadingFooterView!

    private var paging = 1
    private var loading = false
    private var canLoadMore = false

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.navigationView.callback = self

        let tableView = mainView.tableView!
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.allowsSelection = false
        tableView.register(MainImageTableCell.self, forCellReuseIdentifier: MainImageTableCell.ID)

        loadingFooterView = LoadingFooterView(frame: CGRect(x: 0, y: 0,
                width: UIScreen.main.bounds.width, height: 100))
        let headerView = UIView(frame: CGRect(x: 0, y: 0,
                width: UIScreen.main.bounds.width, height: 80))
        tableView.tableFooterView = loadingFooterView
        tableView.tableHeaderView = headerView

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
                self.images.append(UnsplashImage.createToday())
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
        let title = error == nil ? "Saved" : "Error"
        let message = error == nil ? "Image has been saved" : "error occurs: \(error.debugDescription)"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { a in
            ac.dismiss(animated: true)
        }))
        present(ac, animated: true)
    }

    // MARK: MainView callback

    func onClickSettings() {
        let vc = SettingsViewController(nibName: nil, bundle: nil)
        present(vc, animated: true, completion: nil)
    }

    func onClickTitle() {
        mainView.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}