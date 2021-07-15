import UIKit
import MyerSplashShared
import BackgroundTasks
import NotificationCenter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static let SEARCH_SHORTCUT = "search"
    static let DOWNLOADS_SHORTCUT = "downloads"
    
    private static let TAG = "AppDelegate"
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Log.info(tag: AppDelegate.TAG, "application didFinishLaunchingWithOptions")
        
        #if targetEnvironment(macCatalyst)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if let titlebar = windowScene?.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        
        if AppSettings.isStatusBarEnabled() {
            StatusBarAgent.shared.setup(activated: true)
            StatusBarAgent.shared.toggleDock(show: AppSettings.isShowDockEnabled())
        }
        #endif
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let controller = MainViewController(nibName: nil, bundle: nil)
        window!.rootViewController = controller
        window!.makeKeyAndVisible()
        
        Events.initialize()
        
        setupShortcuts(application)
                
        UNUserNotificationCenter.current().delegate = self

        DownloadManager.shared.markDownloadingToFailed()
        MacBundlePlugin.sharedInstance?.onAppDidLaunch()
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        #if targetEnvironment(macCatalyst)
        completionHandler(UNNotificationPresentationOptions.list)
        #else
        completionHandler(.alert)
        #endif
    }
    
    // TODO: currently not used
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
        WidgetManager.shared.triggerUpdate()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Log.info(tag: AppDelegate.TAG, "applicationWillTerminate")
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        presentShortcutViewController(type: shortcutItem.type)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Log.info(tag: AppDelegate.TAG, "userNotificationCenter")
        presentShortcutViewController(type: AppDelegate.DOWNLOADS_SHORTCUT)
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
    
    private func presentShortcutViewController(type: String) {
        guard let vc = UIApplication.shared.windows[0].rootViewController as? MainViewController else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            switch type {
            case AppDelegate.SEARCH_SHORTCUT:
                vc.onClickSearch()
            case AppDelegate.DOWNLOADS_SHORTCUT:
                vc.onClickDownloads()
            default: break
            }
        }
    }
}

