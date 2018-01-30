//
//  AppDelegate.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/28.
//  Copyright © 2017年 libowen. All rights reserved.
//
///




import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var passwordWindow: UIWindow?
    var db:SQLiteDatabase!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("#1 didFinishLaunchingWithOptions")
        // 打开db
        db = try? SQLiteDatabase.createDB()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        print("#3 applicationWillResignActive")
        // 首次launch后，显示master password页面
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("#4 applicationDidEnterBackground")
        // 进入后台后，显示master password页面
        // 好处在于，在多任务页面也会锁住页面；
        //showNewWindow()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        print("#5 applicationWillEnterForeground")
        // 再次进入前台时，显示master password页面
        //showNewWindow()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("#2 applicationDidBecomeActive")
        // app状态为BecomeActive时，显示MasterPasswordVC页面
        //AppDelegate.showMasterPasswordVC()
        showNewWindow()
        print("#")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        print("#6 applicationWillTerminate")
        //
    }

    // show VC
    /*
    func showMasterPasswordVC() {
        let storyBoard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let mpVC: MasterPasswordVC = storyBoard.instantiateViewController(withIdentifier: "MasterPasswordVC") as! MasterPasswordVC
        mpVC.modalTransitionStyle = .crossDissolve
        mpVC.modalPresentationStyle = .fullScreen
        self.window?.rootViewController?.present(mpVC, animated: true, completion: nil)
    }
    */
    // show new window
    func showNewWindow() {
        print("showNewWindow")
        let storyBoard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        /// 注意：
        /// 1、此处实例化一次passwordWindow就好，因为没找到销毁window的方法
        /// 2、如何销毁window？？？，iOS是怎么管理window的？？？
        if UIApplication.shared.windows.count == 1 {
            passwordWindow = UIWindow(frame: UIScreen.main.bounds)
            passwordWindow?.backgroundColor = UIColor.orange
            passwordWindow?.windowLevel = UIWindowLevelAlert
            passwordWindow?.makeKeyAndVisible()
            
            // 如果是第一次进入，显示创建主密码页面，有主密码了，则显示主密码输入页面
            let numberOfTablesInMaster = db.numberOfRowsInTable("sqlite_master")
            if numberOfTablesInMaster > 0 {
                print("#什么鬼")
                // 显示主密码页面
                let mpVC: MasterPasswordVC = storyBoard.instantiateViewController(withIdentifier: "MasterPasswordVC") as! MasterPasswordVC
                passwordWindow?.rootViewController = mpVC
            } else {
                print("显示创建密码页面")
                // 显示创建密码页面
                let cmpVC: CreateMasterPasswordVC = storyBoard.instantiateViewController(withIdentifier: "CreateMasterPasswordVC") as! CreateMasterPasswordVC
                passwordWindow?.rootViewController = cmpVC
            }
            
        } else {
            passwordWindow?.makeKeyAndVisible()
            let numberOfTablesInMaster = db.numberOfRowsInTable("sqlite_master")
            if numberOfTablesInMaster > 0 {
                print("#非第一次什么鬼")
                // 显示主密码页面
                let mpVC: MasterPasswordVC = storyBoard.instantiateViewController(withIdentifier: "MasterPasswordVC") as! MasterPasswordVC
                passwordWindow?.rootViewController = mpVC
            }
        }
        
    }
}



