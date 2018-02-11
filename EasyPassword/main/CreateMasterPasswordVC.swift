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
/// 4、确认button需要主密码和确认密码都不为空时，再显示为可用
/// 5、密码位数少于6位，或过于简单，给出alert提示（第二版做）
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


class CreateMasterPasswordVC: EPViewController {
    
    
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
        
        // 
        _scrollView = scrollView
        // 配置所有UITextField
        textFields = [masterPasswordField, confirmPasswordField, indicatorField]
        for textField in textFields {
            textField.delegate = self
            // 监听所有textField
            textField.addTarget(self, action: #selector(handleTextFieldTextChanged), for: .editingChanged)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //
        configureConfirmBtnStatus()
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
        
        if twoPasswordAreEqual() {
            print("密码确认成功")
            // 1、密码位数少于6位，或过于简单，给出alert提示；
            // 2、密码符合规范，写入db
            
            
            // 密码确认成功
            // 1、如果是第一次，创建PasswordHistory table，写入；
            // 2、非第一次，更新主密码
            let numberOfTablesInMaster = db.numberOfRowsInTable("sqlite_master")
            if numberOfTablesInMaster > 0 {
                /// 2、非第一次，更新主密码
                // 修改密码
                modifyMasterPassword(atTime: dateStr)
            } else {
                /// 1、如果是第一次，创建PasswordHistory table，写入；
                createMasterPassword(atTime: dateStr)
            }
            
        } else {
            print("两次密码输入不一致，请重新输入！")
            // show alert，并清空输入框
            let alertVC = UIAlertController.init(title: "确认失败", message: "两次密码输入不一致，请重新输入！", preferredStyle: UIAlertControllerStyle.alert)
            alertVC.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alertVC, animated: true, completion: nil)
        }
        
        
    }
    
    
    // MARK: - Helper
    
    // 处理textField输入变化
    @objc func handleTextFieldTextChanged(_ textField: UITextField) {
        print("#handleTextFieldTextChanged")
        configureConfirmBtnStatus()
        
    }
    
    // 配置confirmBtn状态
    func configureConfirmBtnStatus() {
        if !textFieldsContainEmpty() {
            confirmBtn.isEnabled = true
            confirmBtn.backgroundColor = UIColor(red: 255.0/255, green: 206.0/255, blue: 0.0, alpha: 1.0)
        } else {
            confirmBtn.backgroundColor = UIColor.lightGray
            confirmBtn.isEnabled = false
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
    
    // 创建主密码
    func createMasterPassword(atTime dateStr: String) {
        /// 1、如果是第一次，创建PasswordHistory table，写入；
        // 创建db--PasswordHistory
        try? db.createTable(table: PasswordHistory.self)    // 创建PasswordHistory table
        
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
    }
    
    // 修改主密码
    func modifyMasterPassword(atTime dateStr: String) {
        if let passwordHistoryTable = db.masterContainTable("PasswordHistory") {
            if passwordHistoryTable {
                // 两次密码判断通过，Update 主密码
                let updateMPSQL = "UPDATE PasswordHistory SET Password = '\(masterPasswordField.text!)' WHERE Item_id = '9999' AND Item_type = '0';"
//                        do {
//                            try db.update(sql: updateMPSQL)
//                        } catch {
//                            print("")
//                        }
                if try! db.update(sql: updateMPSQL) {
                    print("更新主密码成功!")
                } else {
                    print("更新主密码出错!")
                }
            }
        }
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
    
    // 判断输入的主密码安全性
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}












