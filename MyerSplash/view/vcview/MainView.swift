import Foundation
import UIKit
import SnapKit

class MainView: UIView {
    enum AnimatingStatus {
        case STILL, SHOWING, HIDING
    }

    private var animatingStatus: AnimatingStatus = AnimatingStatus.STILL
    private var startY:          CGFloat         = -1

    var imageDetailView: ImageDetailView!
    var tableView:       UITableView!
    var refreshControl:  UIRefreshControl!
    var navigationView:  MainNavigationView!

    var onRefresh: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.black

        refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self, action: #selector(onRefreshData), for: .valueChanged)

        navigationView = MainNavigationView(frame: CGRect.zero)

        tableView = UITableView(frame: CGRect.zero)

        imageDetailView = ImageDetailView(frame: CGRect(x: 0,
                                                        y: 0,
                                                        width: UIScreen.main.bounds.width,
                                                        height: UIScreen.main.bounds.height))

        tableView.backgroundColor = UIColor.black
        tableView.refreshControl = refreshControl

        let dummyHeader = UIView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: UIScreen.main.bounds.width,
                                               height: Dimensions.DUMMY_HEADER_HEIGHT))
        tableView.tableHeaderView = dummyHeader

        addSubview(tableView)
        addSubview(navigationView)
        addSubview(imageDetailView)

        refreshControl.snp.makeConstraints { maker in
            maker.width.equalTo(UIScreen.main.bounds.width)
            maker.height.equalTo(Dimensions.DUMMY_HEADER_HEIGHT)
        }

        navigationView.snp.makeConstraints { (maker) in
            maker.height.equalTo(Dimensions.NAVIGATION_VIEW_HEIGHT)
            maker.right.equalTo(self)
            maker.left.equalTo(self)
            maker.top.equalTo(self)
        }
        tableView.snp.makeConstraints { (maker) in
            maker.height.equalTo(self)
            maker.width.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func hideNavigationElements() {
        if (animatingStatus == AnimatingStatus.HIDING) {
            return
        }

        navigationView.snp.remakeConstraints { maker in
            maker.height.equalTo(Dimensions.NAVIGATION_VIEW_HEIGHT)
            maker.right.equalTo(self)
            maker.left.equalTo(self)
            maker.bottom.equalTo(self.snp.top)
        }

        animatingStatus = AnimatingStatus.HIDING

        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIViewAnimationOptions.curveEaseInOut,
                animations: {
                    self.layoutIfNeeded()
                },
                completion: { c in
                    self.animatingStatus = AnimatingStatus.STILL
                })
    }

    func showNavigationElements() {
        if (animatingStatus == AnimatingStatus.SHOWING) {
            return
        }

        navigationView.snp.remakeConstraints { maker in
            maker.height.equalTo(Dimensions.NAVIGATION_VIEW_HEIGHT)
            maker.right.equalTo(self)
            maker.left.equalTo(self)
            maker.top.equalTo(self)
        }

        animatingStatus = AnimatingStatus.SHOWING

        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIViewAnimationOptions.curveEaseInOut,
                animations: {
                    self.layoutIfNeeded()
                },
                completion: { c in
                    self.animatingStatus = AnimatingStatus.STILL
                })
    }

    func stopRefresh() {
        refreshControl.endRefreshing()
    }

    @objc
    private func onRefreshData() {
        onRefresh?()
    }
}
