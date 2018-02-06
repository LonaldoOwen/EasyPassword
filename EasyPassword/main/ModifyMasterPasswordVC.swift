//
//  ModifyMasterPasswordVC.swift
//  EasyPassword
//
//  Created by libowen on 2018/2/5.
//  Copyright © 2018年 libowen. All rights reserved.
//
/// ModifyMasterPasswordVC
/// 功能：修改主密码
///
///
///
///
///




import UIKit

class ModifyMasterPasswordVC: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var oldPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var indicatorField: UITextField!
    @IBOutlet weak var modifyBtn: UIButton!
    
    
    var db: SQLiteDatabase!
    var activeField: UITextField!
    var textFields: [UITextField]!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 配置db
        db = try? SQLiteDatabase.createDB()
        
        // 注册keyboard通知(处理键盘遮挡)
        registerForKeyboardNotifications()
        // 配置所有UITextField
        textFields = [oldPasswordField, newPasswordField, confirmPasswordField, indicatorField]
        for textField in textFields {
            textField.delegate = self
            // 监听所有textField
            textField.addTarget(self, action: #selector(handleTextFieldTextChanged), for: .editingChanged)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureConfirmBtnStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Actions
    
    // Modify MasterPassword
    @IBAction func handleModifyBtnAction(_ sender: UIButton) {
        // 1、如果旧密码验证通过，新密码符合规则，修改密码
        // 2、旧密码未通过验证，弹出action sheet
        if isEqualToTheOldPassword() {
            if twoInputAreEqual() {
                // 更新主密码
                modifyMasterPassword()
            } else {
                self.showAlert(title: "", message: "两次输入的密码不一致，请重新输入！", actionTitle: "取消")
            }
        } else {
            self.showAlert(title: "", message: "旧密码验证错误，请重新输入！", actionTitle: "取消")
        }
    }
    
    @IBAction func handleCancelBtnAction(_ sender: UIButton) {
        // 1、先收起键盘
        if let textField = activeField {
            textField.resignFirstResponder()
        }
        
        // 2、收起页面
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Helper
    
    // Call this method somewhere in your view controller setup code.
    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateItemVC.keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    @objc
    func keyboardWasShown(_ aNotification: Notification) {
        
        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Show keyboard: \(keyboardBounds)")
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardBounds.size.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            // 如果textField被键盘遮住，scrollview滚动，显示该textField
            var aRect = self.view.frame
            aRect.size.height -= keyboardBounds.size.height
            if let textField = activeField {
                let point = textField.convert(textField.frame.origin, to: self.view)
                if !aRect.contains(point) {
                    let rect = textField.convert(textField.frame, to: self.view)
                    self.scrollView.scrollRectToVisible(rect, animated: true)
                }
            }
            
            
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    @objc func keyboardWillBeHidden(_ aNotification: Notification) {
        // 恢复scrollview为默认状态
        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Hidden keyboard: \(keyboardBounds)")
        }
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // 处理textField输入变化
    @objc func handleTextFieldTextChanged(_ textField: UITextField) {
        print("#handleTextFieldTextChanged")
        configureConfirmBtnStatus()
        
    }
    
    // 配置confirmBtn状态
    func configureConfirmBtnStatus() {
        if !textFieldsContainEmpty() {
            modifyBtn.isEnabled = true
            modifyBtn.backgroundColor = UIColor(red: 255.0/255, green: 206.0/255, blue: 0.0, alpha: 1.0)
        } else {
            modifyBtn.backgroundColor = UIColor.lightGray
            modifyBtn.isEnabled = false
        }
    }
    
    // 判断textFields中是否包含未输入的textField（true有，false没有）
    fileprivate func textFieldsContainEmpty() -> Bool {
        for textField in textFields {
            if textField == indicatorField {
                break
            }
            if (textField.text?.isEmpty)! {
                return true
            }
        }
        return false
    }
    
    // 和旧密码比较
    func isEqualToTheOldPassword() -> Bool {
        if let masterPassword = db.getMasterPassword() {
            if oldPasswordField.text == masterPassword {
                return true
            }
        }
        return false
    }
    
    // 新密码和确认密码比较
    func twoInputAreEqual() -> Bool {
        if confirmPasswordField.text == newPasswordField.text {
            return true
        }
        
        return false
    }
    
    // 修改主密码
    func modifyMasterPassword() {
        // 时间、日期格式
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = Date()
        let dateStr = formatter.string(from: now)
        
        //
        if let passwordHistoryTable = db.masterContainTable("PasswordHistory") {
            if passwordHistoryTable {
                // 两次密码判断通过，Update 主密码
                let updateMPSQL = "UPDATE PasswordHistory SET Password = '\(newPasswordField.text!)', Create_time = '\(dateStr)' WHERE Item_id = '9999' AND Item_type = '0';"
                if try! db.update(sql: updateMPSQL) {
                    print("更新主密码成功!")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("更新主密码出错!")
                    self.showAlert(title: "", message: "更新主密码出错!", actionTitle: "取消")
                }
            }
        }
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



// MARK: - UITextFieldDelegate

extension ModifyMasterPasswordVC: UITextFieldDelegate {
    
    // 点击return收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("#textFieldShouldBeginEditing")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("#CreateItemVC--textFieldDidBeginEditing")
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("#CreateItemVC--textFieldDidEndEditing")
        activeField = nil
    }
}







