import UIKit
import MyerSplashShared
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static let SEARCH_SHORTCUT = "search"
    static let DOWNLOADS_SHORTCUT = "downloads"
    
    private static let TAG = "AppDelegate"
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Log.info(tag: AppDelegate.TAG, "application didFinishLaunchingWithOptions")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let controller = MainViewController(nibName: nil, bundle: nil)
        window!.rootViewController = controller
        window!.makeKeyAndVisible()
        
        Events.initialize()
        
        setupShortcuts(application)
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene?.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        
        if AppSettings.isStatusBarEnabled() {
            StatusBarAgent.shared.setup(activated: true)
            StatusBarAgent.shared.toggleDock(show: AppSettings.isShowDockEnabled())
        }
        #endif
        
        UNUserNotificationCenter.current().delegate = self

        DownloadManager.shared.markDownloadingToFailed()

        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: AutoWallpaperBGTask.ID, using: nil) { task in
            AutoWallpaperBGTask.shared.handleBackgroundTask(task as! BGAppRefreshTask)
        }
        
        AutoWallpaperBGTask.shared.scheduleBackgroundTasks()
    }
    
    private func setupShortcuts(_ application: UIApplication) {
        let searchItem = UIApplicationShortcutItem(type: AppDelegate.SEARCH_SHORTCUT,
                                                   localizedTitle: R.strings.shortcut_search,
                                                   localizedSubtitle: nil,
                                                   icon: UIApplicationShortcutIcon(systemImageName: "magnifyingglass"), userInfo: nil)
        let downloadsItem = UIApplicationShortcutItem(type: AppDelegate.DOWNLOADS_SHORTCUT,
                                                      localizedTitle: R.strings.shortcut_downloads,
                                                      localizedSubtitle: nil,
                                                      icon: UIApplicationShortcutIcon(systemImageName: "arrow.down.circle"), userInfo: nil)
        
        application.shortcutItems = [searchItem, downloadsItem]
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        Log.info(tag: AppDelegate.TAG, "applicationWillResignActive")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Log.info(tag: AppDelegate.TAG, "applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Log.info(tag: AppDelegate.TAG, "applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Log.info(tag: AppDelegate.TAG, "applicationDidBecomeActive")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Log.info(tag: AppDelegate.TAG, "applicationWillTerminate")
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let vc = UIApplication.shared.windows[0].rootViewController as? MainViewController else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch shortcutItem.type {
            case AppDelegate.SEARCH_SHORTCUT:
                let targetVc = SearchViewController()
                vc.present(targetVc, animated: true, completion: nil)
                targetVc.delegate = vc
            case AppDelegate.DOWNLOADS_SHORTCUT:
                let targetVc = MoreViewController()
                vc.present(targetVc, animated: true, completion: nil)
                targetVc.delegate = vc
            default: break
            }
        }
    }
    
    #if targetEnvironment(macCatalyst)
    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .file)
        builder.remove(menu: .edit)
        builder.remove(menu: .help)
        builder.remove(menu: .format)
        super.buildMenu(with: builder)
    }
    #endif
}

