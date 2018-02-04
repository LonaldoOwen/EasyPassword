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
/// 问题：
/// 1、4寸屏，输入框被键盘遮挡，需要将整体上移30pt，注意其他尺寸效果
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
    var enterCount: Int = 0
    var note: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //
        passwordField.delegate = self
        // 监听textField
        passwordField.addTarget(self, action: #selector(handleTextFieldTextChanged), for: .editingChanged)
        
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
            // 验证密码失败，播放动画(shake)
            print("Verity Failed!")
    
            // 未达到效果
            //shakeWithPosition()
            // shake
            shakeWithTransformTranslationX()
            passwordField.text = ""
            passwordField.placeholder = "请再试一次"
            
            if enterCount > 3 {
                let alertVC = UIAlertController.init(title: "密码提示", message: "\(note!)", preferredStyle: UIAlertControllerStyle.alert)
                alertVC.addAction(UIAlertAction.init(title: "知道了", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
                enterCount = 0
            }
            
            enterCount += 1
        }
        
    }
    
    // 响应UIApplicationDidBecomeActive通知事件
    //@objc func handleObserverUIApplicationDidBecomeActive(_ notification: Notification) { }
    
    // 处理textField输入变化
    @objc func handleTextFieldTextChanged(_ textField: UITextField) {
        print("#handleTextFieldTextChanged")
        // 当前textField的text不为空，enable saveButton
        if (passwordField.text?.isEmpty)! {
            enterBtn.setImage(UIImage(named:"arrow_gray"), for: .normal)
        } else {
            enterBtn.setImage(UIImage(named:"arrow_white"), for: .normal)
        }
    }
    
    
    
    // MARK: - Helper
    
    // 创建UI--创建、修改主密码
    func createPasswordUI() {
        //
        
    }
    
    // 验证密码正确与否
    func identifyPassword() -> Bool {
        // 从db取出password
        let mpSQL = "SELECT * FROM PasswordHistory WHERE Item_id = '9999' AND Item_type = 0;"
        let queryResults = db.querySql(sql: mpSQL)
        if let password = queryResults?.first!["Password"] as? String {
            if passwordField.text == password {
                print("Master Password Passed!")
                return true
            } else {
                print("Master Password Failed!")
            }
        }
        if let note = queryResults?.first!["Note"] as? String {
            self.note = note
        }
        
        // 和当前passwordField值比较，相同返回true，不同返回false
        return false
    }
    
    // shake animation - CABasicAnimation, "position"
    // 未实现
    func shakeWithPosition() {
        let layer = masterContent.layer
        let fromPosition: CGPoint = masterContent.center
        let leftPosition: CGPoint = CGPoint(x: fromPosition.x - 30, y: fromPosition.y)
        let rightPosition: CGPoint = CGPoint(x: fromPosition.x + 30, y: fromPosition.y)
        
        let animationLeft: CABasicAnimation = CABasicAnimation.init(keyPath: "position")
        //animationLeft.fromValue = NSValue.init(cgPoint: fromPosition)
        animationLeft.byValue = NSValue.init(cgPoint: leftPosition)
        animationLeft.toValue = NSValue.init(cgPoint: rightPosition)
        animationLeft.duration = 2.0
        animationLeft.repeatCount = 3
        layer.add(animationLeft, forKey: animationLeft.keyPath)
        
        //            let animationRight: CABasicAnimation = CABasicAnimation.init(keyPath: "position")
        //            animationRight.fromValue = NSValue.init(cgPoint: fromPosition)
        //            animationRight.toValue = NSValue.init(cgPoint: rightPosition)
        //            animationRight.duration = 2.0
        //            //layer.add(animationRight, forKey: animationRight.keyPath)
        //
        //            // group
        //            let groupAnimation = CAAnimationGroup()
        //            groupAnimation.animations = [animationLeft, animationRight]
        //            groupAnimation.duration = 5.0
        //            layer.add(groupAnimation, forKey: "Shake")
        
    }
    
    // shake animation - CABasicAnimation, "transform.translation.x"
    func shakeWithTransformTranslationX() {
        
        let shake: CABasicAnimation = CABasicAnimation.init(keyPath: "transform.translation.x")
        shake.fromValue = -10.0
        shake.toValue = 10.0
        shake.duration = 0.05
        shake.autoreverses = true
        shake.repeatCount = 3
        
        let layer = masterContent.layer
        layer.add(shake, forKey: "ShakeAnimation")
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


extension MasterPasswordVC: UITextFieldDelegate {
    //
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("#MasterPasswordVC--textFieldDidBeginEditing")
    }
}




