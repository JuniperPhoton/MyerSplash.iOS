import Foundation
import UIKit
import SnapKit

class MainView: UIView {
    private var fab: FloatingActionButton!

    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var navigationView: MainNavigationView!

    var onRefresh: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.black

        refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self, action: #selector(onRefreshData), for: .valueChanged)

        navigationView = MainNavigationView(frame: CGRect.zero)

        tableView = UITableView(frame: CGRect.zero)

        fab = FloatingActionButton(frame: CGRect.zero)

        tableView.backgroundColor = UIColor.black
        tableView.refreshControl = refreshControl

        addSubview(tableView)
        addSubview(fab)
        addSubview(navigationView)

        navigationView.snp.makeConstraints { (maker) in
            maker.height.equalTo(Dimensions.NAVIGATION_VIEW_HEIGHT)
            maker.right.equalTo(self)
            maker.left.equalTo(self)
            maker.top.equalTo(self)
        }
        tableView.snp.makeConstraints { (maker) in
            maker.top.equalTo(navigationView.snp.bottom)
            maker.bottom.equalTo(self.snp.bottom)
            maker.width.equalTo(self.snp.width)
        }
        fab.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(Dimensions.FAB_SIZE)
            maker.right.equalTo(self.snp.right).offset(-8)
            maker.bottom.equalTo(self.snp.bottom).offset(-8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private var animating = false
    private var startY: CGFloat = -1

    func hideFab() {
        if (animating) {
            return
        }
        if (startY == -1) {
            startY = self.fab.center.y
        }
        animating = true
        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIViewAnimationOptions.curveEaseInOut,
                animations: {
                    self.fab.center = CGPoint(x: self.fab.center.x, y: self.startY + 100)
                },
                completion: { c in
                    self.animating = false
                })
    }

    func showFab() {
        if (animating) {
            return
        }
        if (startY == -1) {
            startY = self.fab.center.y
        }
        animating = true
        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIViewAnimationOptions.curveEaseInOut,
                animations: {
                    self.fab.center = CGPoint(x: self.fab.center.x, y: self.startY)
                },
                completion: { c in
                    self.animating = false
                })
    }

    @objc
    private func onRefreshData() {
        onRefresh?()
    }

    func stopRefresh() {
        refreshControl.endRefreshing()
    }
}
