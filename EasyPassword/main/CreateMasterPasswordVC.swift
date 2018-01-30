//
//  CreateMasterPasswordVC.swift
//  EasyPassword
//
//  Created by libowen on 2018/1/30.
//  Copyright © 2018年 libowen. All rights reserved.
//
/// CreateMasterPasswordVC
/// 功能：创建主密码页面
/// 1、创建主密码，写入db--PasswordHistory table
/// 2、修改主密码，更新db--PasswordHistory table，主密码
/// 3、增加调整键盘逻辑，如果遮住输入框，scrollview滚动
/// 4、确认button需要主密码和确认密码都不为空时，再显示为可用（）
///
///
///





import UIKit

extension PasswordHistory: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE PasswordHistory(
        Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        Item_id CHAR(255),
        Password CHAR(255),
        Persistent_type CHAR(255),
        Item_type CHAR(255),
        Create_time DATETIME,
        Note CHAR(255)
        );
        """
    }
    
    
}


class CreateMasterPasswordVC: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var masterPasswordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var indicatorField: UITextField!
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    
    
    var db: SQLiteDatabase!
    var activeField: UITextField!
    var textFields: [UITextField]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 配置db
        db = try? SQLiteDatabase.createDB()
        //masterPasswordField.autocorrectionType = UITextAutocorrectionType.no
        //masterPasswordField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        // 注册keyboard通知(处理键盘遮挡)
        registerForKeyboardNotifications()
        // 配置所有UITextField
        textFields = [masterPasswordField, confirmPasswordField, indicatorField]
        for textField in textFields {
            textField.delegate = self
            // 监听所有textField
            textField.addTarget(self, action: #selector(handleTextFieldTextChanged), for: .editingChanged)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Actions
    
    // 处理确认button点击事件
    @IBAction func handleConfirmPasswordBtn(_ sender: Any) {
        print("#CreateMasterPasswordVC--handleConfirmPasswordBtn")
        // 时间、日期格式
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = Date()
        let dateStr = formatter.string(from: now)
        
        let numberOfTablesInMaster = db.numberOfRowsInTable("sqlite_master")
        if numberOfTablesInMaster > 0 {
            // 如果db没包含PasswordHistory table，创建一个
            if let passwordHistoryTable = db.masterContainTable("PasswordHistory") {
                if passwordHistoryTable {
                    // 两次密码判断通过，Update 主密码
                    print("")
                    
                }
            }
        } else {
            // 创建PasswordHistory table
            try? db.createTable(table: PasswordHistory.self)
            if twoPasswordAreEqual() {
                /// 说明：
                /// Item_id = 9999, Item_type = 0, 表示主密码
                // 两次密码判断通过，写入PasswordHistory
                let insertMPSQL = "INSERT INTO PasswordHistory (Item_id, Password, Persistent_type, Item_type, Create_time, Note) VALUES ('9999', '\(masterPasswordField.text!)', '\(FolderModel.PersistentType.iphone.rawValue)', '0', '\(dateStr)', '\(indicatorField.text!)');"
                try? db.insert(sql: insertMPSQL)
                // 如果插入成功，隐藏passwordWindow
                if passwordHistoryTableContainMaster() {
                    // 如果验证密码成功，则收起passwordWindow，显示主window
                    if let window = UIApplication.shared.keyWindow, window.windowLevel > 0 {
                        print("window: \(window)")
                        // 隐藏window
                        window.isHidden = true
                    }
                } else {
                    // 插入失败，
                    print("主密码写入失败！")
                }
            } else {
                // show alert，并清空输入框
                print("两次密码输入不一致，请重新输入！")
                
            }
            
            
        }
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
        
        // textFields中text无空，且当前textField的text不为空，enable saveButton
//        if !textFieldsContainEmpty() && !(textField.text?.isEmpty)! {
//            saveBtn.isEnabled = true
//        } else {
//            saveBtn.isEnabled = false
//        }
        
    }
    
    // 比较俩个密码是否相等
    func twoPasswordAreEqual() -> Bool {

        guard let masterPassword = masterPasswordField.text else { return false }
        guard let confirmPassword = confirmPasswordField.text else { return false }
        if confirmPassword == masterPassword {
            return true
        }
        
        return false
    }
    
    //
    func passwordHistoryTableContainMaster() -> Bool {
        if let queryResults = db.querySql(sql: "SELECT * FROM PasswordHistory WHERE Item_id = '9999' AND Item_type = '0';") {
            if queryResults.count > 0 {
                return true
            }
        }
        
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



// MARK: - UITextFieldDelegate

extension CreateMasterPasswordVC: UITextFieldDelegate {
    
    // 点击return收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("#textFieldShouldBeginEditing")
        //        if textField == self.password!  {
        //            // 如果想禁止某个textField输入，返回false
        //        }
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








