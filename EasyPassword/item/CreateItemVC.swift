//
//  CreateItemVC.swift
//  EasyPassword
//
//  Created by libowen on 2017/12/8.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// CreateItemVC
/// 功能：创建item
/// 1、使用UIViewController，自定义创建页面(Storyboard auto layout)
/// 2、点击cancel收起VC不存储
/// 3、点击save，保存编辑内容，写入plist，收起VC；收起VC后更新item list
/// 4、处理键盘遮挡页面（参考apple官方用法）
/// 5、所有textField不能为空，只要有空的，save button置灰（监听textField）
///
///


import UIKit

class CreateItemVC: UIViewController {
    
    
    // MARK: - Properties
    
    var activeField: UITextField!
    var login: Login!
    var itemType:String!
    // 定义closure用于刷新ItemListVC
    var reloadItemListVC: ((Item) -> ())!
    var textFields: [UITextField]!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var showPassword: UIButton!
    @IBOutlet weak var generatePassword: UIButton!
    @IBOutlet weak var website: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 注册keyboard通知
        registerForKeyboardNotifications()
        
        textFields = [itemName, userName, password, website]
        for textField in textFields {
            textField.delegate = self
            // 监听所有textField
            textField.addTarget(self, action: #selector(handleTextFieldTextChanged), for: .editingChanged)
        }
        saveBtn.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("#CreateItemVC--itemType: \(itemType)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func handleCancelAction(_ sender: UIBarButtonItem) {
        // 先收起键盘
        if let textField = activeField {
            textField.resignFirstResponder()
        }
        // 收起VC
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSaveAction(_ sender: Any) {
        // item 写入plist
        // 注意除了note字段，其他不许为空
        login = Login(itemname: itemName.text!, username: userName.text!, password: password.text!, website: website.text!, note: "")
        PlistHelper.insert(itemModel: login, ofPersistentType: "MyIPHONE", itemType: itemType)
        // 更新item list页面（选择方式？？？）
        //reloadItemListVC(login)
        // 收起VC
        self.dismiss(animated: true, completion: {
            // 更新item list页面（选择方式？？？）
            self.reloadItemListVC(self.login)
        })
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
//        let info = aNotification.userInfo
//        let keyboardBounds = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let keyboardSize = keyboardBounds.size
        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Show keyboard: \(keyboardBounds)")
            
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardBounds.size.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = self.view.frame
            aRect.size.height -= keyboardBounds.size.height
            if !aRect.contains(activeField.frame.origin) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    @objc func keyboardWillBeHidden(_ aNotification: Notification) {
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
        if !textFieldsContainEmpty() && !(textField.text?.isEmpty)! {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
    }
    
    // 判断textFields中是否包含未输入的textField（true有，false没有）
    private func textFieldsContainEmpty() -> Bool {
        for textField in textFields {
            if (textField.text?.isEmpty)! {
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

extension CreateItemVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("#CreateItemVC--textFieldDidBeginEditing")
        activeField = textField
        // 每次输入完毕时判断是否所有textField都不为空，此时save button可用
//        if textFieldsContainEmpty() {
//            saveBtn.isEnabled = false
//        } else {
//            saveBtn.isEnabled = true
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("#CreateItemVC--textFieldDidEndEditing")
        activeField = nil
        // 每次输入完毕时判断是否所有textField都不为空，此时save button可用
//        if textFieldsContainEmpty() {
//            saveBtn.isEnabled = false
//        } else {
//            saveBtn.isEnabled = true
//        }
        
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        print("#CreateItemVC--shouldChangeCharactersIn")
//        // 每次输入完毕时判断是否所有textField都不为空，此时save button可用
//        let currentText = textField.text
//        let nextText = (currentText! as NSString).replacingCharacters(in: range, with: string)
//        for text_feild in textFields {
//            if text_feild != textField
//
//            if !(textField.text?.isEmpty)! && !(currentText?.isEmpty)! && nextText.count > 0{
//                saveBtn.isEnabled = true
//            } else {
//                saveBtn.isEnabled = false
//            }
//        }
////        if saveButtonIsEnable() {
////            saveBtn.isEnabled = true
////        } else {
////            saveBtn.isEnabled = false
////        }
//        return true
//    }
    
    
    // 点击return收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}







