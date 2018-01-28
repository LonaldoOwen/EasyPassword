//
//  MasterPasswordVC.swift
//  EasyPassword
//
//  Created by owen on 27/01/2018.
//  Copyright © 2018 libowen. All rights reserved.
//
/// MasterPasswordVC
/// 功能：锁屏输入主密码页面
/// 1、锁屏、验证主密码
/// 2、设置、修改主密码
///
///
///
///



import UIKit

class MasterPasswordVC: UIViewController {
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContent: UIView!
    @IBOutlet weak var masterContent: UIView!
    @IBOutlet weak var enterBtn: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    

    var db: SQLiteDatabase!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 创建UI--创建、修改主密码
        createPasswordUI()
        // 实例化db
        db = try? SQLiteDatabase.createDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //
        print("#MasterPasswordVC--viewWillAppear")
        //NotificationCenter.default.addObserver(self, selector: #selector(handleObserverUIApplicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //
        print("#MasterPasswordVC--viewWillDisappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    
    @IBAction func handleEnterAction(_ sender: UIButton) {
        //
        print("#MasterPasswordVC--handleEnterAction")
        if identifyPassword() {
            // 如果验证密码成功，则收起passwordWindow，显示主window
            if let window = UIApplication.shared.keyWindow, window.windowLevel > 0 {
                print("window: \(window)")
                // 隐藏window
                window.isHidden = true
                // 不能切换keyWindow？？？
//                window?.rootViewController = nil
//                window = nil
//                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        } else {
            // 验证密码失败，播放动画
        }
        
    }
    
    // 响应UIApplicationDidBecomeActive通知事件
    //@objc func handleObserverUIApplicationDidBecomeActive(_ notification: Notification) { }
    
    
    // MARK: - Helper
    
    // 创建UI--创建、修改主密码
    func createPasswordUI() {
        //
        
    }
    
    // 验证密码正确与否
    func identifyPassword() -> Bool {
        // 从db取出password
        
        // 和当前passwordField值比较，相同返回true，不同返回false
        return false
    }
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
