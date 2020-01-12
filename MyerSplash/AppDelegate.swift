import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let SEARCH_SHORTCUT = "search"
    static let DOWNLOADS_SHORTCUT = "downloads"
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let controller = MainViewController(nibName: nil, bundle: nil)
        window!.rootViewController = controller
        window!.makeKeyAndVisible()
        
        MSAppCenter.start(AppKeys.getAppCenterKey(), withServices:[
            MSAnalytics.self,
            MSCrashes.self
        ])
        
        setupShortcuts(application)
        
        return true
    }
    
    private func setupShortcuts(_ application: UIApplication) {
        let searchItem = UIApplicationShortcutItem(type: AppDelegate.SEARCH_SHORTCUT,
                                                   localizedTitle: R.strings.shortcut_search,
                                                   localizedSubtitle: nil,
                                                   icon: UIApplicationShortcutIcon(templateImageName: R.icons.ic_search), userInfo: nil)
        let downloadsItem = UIApplicationShortcutItem(type: AppDelegate.DOWNLOADS_SHORTCUT,
                                                      localizedTitle: R.strings.shortcut_downloads,
                                                      localizedSubtitle: nil,
                                                      icon: UIApplicationShortcutIcon(templateImageName: R.icons.ic_download), userInfo: nil)
        
        application.shortcutItems = [searchItem, downloadsItem]
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let vc = UIApplication.shared.keyWindow?.rootViewController as? MainViewController else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch shortcutItem.type {
            case AppDelegate.SEARCH_SHORTCUT:
                let targetVc = SearchViewController()
                vc.present(targetVc, animated: true, completion: nil)
            case AppDelegate.DOWNLOADS_SHORTCUT:
                let targetVc = MoreViewController()
                vc.present(targetVc, animated: true, completion: nil)
            default: break
            }
        }
    }
}

