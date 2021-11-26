//
//  AppDelegate.swift
//  SchoolApp
//
//  Created by user on 12/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
import QuickLook

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var orientationLock = UIInterfaceOrientationMask.portrait
    var Notification_Badge = 0
    var window: UIWindow?
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        application.applicationIconBadgeNumber = Notification_Badge
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        if User.isUserLoggedIn{
            self.pushToDashboardViewController()
        }
        UIAccessibility.requestGuidedAccessSession(enabled: false) { (testBool) in
            print(testBool)
        }
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: "currentDeviceToken")
        UserDefaults.standard.synchronize()
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        debugPrint("Received: \(userInfo)")
//        Notification_Badge += 1
//        application.applicationIconBadgeNumber = Notification_Badge
//        completionHandler(.newData)
//    }
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
//    {
//        print(userInfo)
//    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("*****************REDIRECT IN APPLICATION***********")
        let application = UIApplication.shared
        Notification_Badge += 1
        application.applicationIconBadgeNumber = Notification_Badge
         let userInfo = response.notification.request.content.userInfo
         if let infoDic = userInfo["aps"] as? [String:AnyObject]  {
         print(infoDic)
            if let reponseData = infoDic["alert"] as? [String:Any]{
                if User.isUserLoggedIn {
                let user = User.getUserFromUserDefault()
                if let userID = reponseData["userid"] as? String, let slugStr = reponseData["slug"] as? String {
                    if userID == user!.userId{
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                        let vc1 = sb.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController
                        let nav =  UINavigationController.init(rootViewController: vc!)
                        nav.isNavigationBarHidden = true
                        let application = UIApplication.shared
                        application.applicationIconBadgeNumber = Notification_Badge
                        nav.pushViewController(vc1!, animated: false)
                        vc1?.callNotificationRedirection(slug: slugStr)
                        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
                            keyWindow.rootViewController = nav
                            keyWindow.makeKeyAndVisible()
                        }
                    }else{
                        self.pushToDashboardViewController()
                    }
                }
            }
        }
    }
}
    func pushToDashboardViewController(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        let vc1 = sb.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController
        let nav =  UINavigationController.init(rootViewController: vc!)
        nav.isNavigationBarHidden = true
        nav.pushViewController(vc1!, animated: false)
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window{
            keyWindow.rootViewController = nav
            keyWindow.makeKeyAndVisible()
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
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
         self.openAppUpdateAlert()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    func openAppUpdateAlert(){
        
        var appUpdateParameters:[String:Any] = [:]
        appUpdateParameters["app_platform"] = "ios"
        appUpdateParameters["app_version"] = "\(Bundle.main.versionNumber)"
        
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kCheckAppVersion, parameter:appUpdateParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let status = success["status"],"\(status)" != "1"{
                self.showApplicationUpdateAlert()
            }
        }, fail: { (responseFail) in
            //self.showApplicationUpdateAlert()
        })
        
    }
    func showApplicationUpdateAlert(){
        DispatchQueue.main.async {
            let updateAlert = UIAlertController.init(title: "Your App is Out of Date", message: "\nDownload the latest version of \(Bundle.main.displayName ?? "SAS Surat") to try new features and get a better experience.", preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "Update", style: .default, handler: { (_ ) in
                if let objURL = URL.init(string: kAppStoreURLSurat){
                    UIApplication.shared.open(objURL, options: [:]) { (finished) in
                        
                    }
                }
            })
            updateAlert.addAction(alertAction)
            updateAlert.view.tintColor = kSchoolThemeColor
            self.window?.rootViewController?.present(updateAlert, animated: true, completion: nil)
        }
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SchoolApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


extension Bundle {
    
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
