import Foundation
import UIKit
import SnapKit
import MaterialComponents.MaterialTabs

class MainView: UIView {
    enum AnimatingStatus {
        case STILL, SHOWING, HIDING
    }
    
    class IndicatorTemplate: NSObject, MDCTabBarIndicatorTemplate {
        func indicatorAttributes(
          for context: MDCTabBarIndicatorContext
        ) -> MDCTabBarIndicatorAttributes {
          let attributes = MDCTabBarIndicatorAttributes()
          // Outset frame, round corners, and stroke.
            let indicatorFrame = context.contentFrame.insetBy(dx: 1, dy: 6).offsetBy(dx: 0, dy: 18)
          let path = UIBezierPath(roundedRect: indicatorFrame, cornerRadius: 0)
          attributes.path = path
          return attributes
        }
    }

    private var animatingStatus: AnimatingStatus = AnimatingStatus.STILL
    private var startY: CGFloat = -1

    var imageDetailView: ImageDetailView!
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var tabBar: MDCTabBar!

    var onRefresh: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIView.getDefaultBackgroundUIColor()
                
        tabBar = MDCTabBar(frame: CGRect.zero)
        tabBar.items = [
        UITabBarItem(title: "NEW", image: nil, tag: 0),
        UITabBarItem(title: "HIGHLIGHTS", image: nil, tag: 0),
        UITabBarItem(title: "RANDOM", image: nil, tag: 0),
        UITabBarItem(title: "DEVELOPER", image: nil, tag: 0),
        ]
        tabBar.backgroundColor = UIView.getDefaultBackgroundUIColor()
        tabBar.setTitleColor(UIView.getDefaultLabelUIColor().withAlphaComponent(0.5), for: .normal)
        tabBar.setTitleColor(UIView.getDefaultLabelUIColor(), for: .selected)
        tabBar.itemAppearance = .titles
        tabBar.rippleColor = UIView.getDefaultBackgroundUIColor()
        tabBar.selectionIndicatorTemplate = IndicatorTemplate()
        tabBar.selectedItemTitleFont = UIFont.preferredFont(forTextStyle: .headline).with(traits: .traitBold).withSize(14)
        tabBar.unselectedItemTitleFont = UIFont.preferredFont(forTextStyle: .headline).with(traits: .traitBold).withSize(14)
        tabBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        tabBar.sizeToFit()
        tabBar.tintColor = UIView.getDefaultLabelUIColor()
        //addSubview(tabBar)
        
//        tabBar.snp.makeConstraints { (maker) in
//            maker.top.equalTo(self.snp.top).offset(UIView.topInset)
//            maker.left.equalTo(self.snp.left)
//            maker.right.equalTo(self.snp.right)
//            maker.height.equalTo(60)
//        }
        
        refreshControl = UIRefreshControl(frame: CGRect.zero)
        refreshControl.addTarget(self, action: #selector(onRefreshData), for: .valueChanged)

        tableView = UITableView(frame: CGRect.zero)

        imageDetailView = ImageDetailView(frame: CGRect(x: 0,
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height))

        tableView.setDefaultBackgroundColor()
        
        tableView.refreshControl = refreshControl

        addSubview(tableView)
        addSubview(imageDetailView)

        tableView.snp.makeConstraints { (maker) in
            maker.height.equalTo(self)
            maker.width.equalTo(self)
            maker.top.equalTo(self)
        }
        
        let searchImage = UIImage(named: "round_search_black_24pt")!.withRenderingMode(.alwaysTemplate)
        let fab = MDCFloatingButton()
        fab.setImage(searchImage, for: .normal)
        fab.setImageTintColor(UIColor.black, for: .normal)
        fab.setBackgroundColor(UIColor.white)
        addSubview(fab)
        fab.snp.makeConstraints { (maker) in
            maker.right.equalTo(self.snp.right).offset(-16)
            maker.bottom.equalTo(self.snp.bottom).offset(-16)
            maker.width.equalTo(52)
            maker.height.equalTo(52)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func hideNavigationElements() {
        if (animatingStatus == AnimatingStatus.HIDING) {
            return
        }

        animatingStatus = AnimatingStatus.HIDING

        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseInOut,
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

        animatingStatus = AnimatingStatus.SHOWING

        UIView.animate(
                withDuration: Values.DEFAULT_ANIMATION_DURATION_SEC,
                delay: 0,
                options: UIView.AnimationOptions.curveEaseInOut,
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
        if (onRefresh == nil) {
            return
        }

        onRefresh?()

        if (refreshControl.isRefreshing) {
            refreshControl.endRefreshing()
        }
    }
}

