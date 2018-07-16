//
//  AppDelegate.swift
//  footballSnake
//
//  Created by hurry.qin on 2018/7/2.
//  Copyright © 2018年 hong.qin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootVc: MainViewController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        rootVc = MainViewController()
        window?.rootViewController = rootVc
        window?.makeKeyAndVisible()
        initJpush(launchOptions)
        return true
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        //注册推送,用于iOS8以上系统
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        JPUSHService.handleRemoteNotification(userInfo)
        handleNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        JPUSHService.handleRemoteNotification(userInfo)
        handleNotification(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    
    func initJpush(_ launchOptions: [AnyHashable: Any]?) {
        JPUSHService.register(forRemoteNotificationTypes: UIUserNotificationType.alert.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue, categories: nil)
        JPUSHService.setup(withOption: launchOptions, appKey: "92dab042b6f7bcdd46477899", channel: nil, apsForProduction: true)
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        JPUSHService.setBadge(0)
        rootVc?.requestAndShow()    // 后台进入前台 请求
    }
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func handleNotification(_ userInfo: [AnyHashable: Any]) {
        // 解析通知中的 url 参数
        if let urlString = userInfo["url"] as? String, urlString.count > 5 {
            rootVc?.showWebView(urlString)
        }
    }
}

