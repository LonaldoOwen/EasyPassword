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
/// 6、显示密码功能：
///       点击显示密码，再次点击隐藏密码
///       输入的字符使用“*”替代 (设置isSecureTextEntry属性为true即可）
/// 7、遵从GeneratePasswordDelegate，实现代理方法，显示生成的密码
/// 8、位数、数字、符号联动变化（不联动，位数定了就不会变，）
/// 9、note：UITextView的placeholder、遮挡处理、键盘监听处理；点击note弹起键盘，略微遮挡？？？
/// 10、从详情页面跳转过来时，要把数据带上并显示；保存数据时要保存到原Model，不要创建新的
/// 11、使用了closure用于反向传值
///
///



import UIKit

class CreateItemVC: UIViewController, GeneratePasswordDelegate {
    
    
    // MARK: - Properties
    
    var item: Item!
    var itemType: String!
    var login: Login!
    var textFields: [UITextField]!
    var passwordIsShow: Bool = false
    var activeField: UITextField!
    var activeTextView: UITextView!
    //var realPassword: String!
    var generateView: GenerateView = {
        let view = Bundle.main.loadNibNamed("GenerateView", owner: self, options: nil)?.first as! GenerateView
        return view
    }()
    
    // 定义closure用于刷新ItemListVC
    var reloadItemListVC: ((Item) -> ())!
    // 定义closure用于刷新ItemDetailVC
    var passBackNewItemDetail: ((Item) -> ())!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var generateContent: UIView!
    @IBOutlet weak var showPassword: UILabel!
    @IBOutlet weak var generatePassword: UIButton!
    @IBOutlet weak var website: UITextField!
    @IBOutlet weak var note: UITextView!
    
    
    
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
        
        // 设置“显示密码”
        if #available(iOS 11.0, *) {
            self.showPassword.attributedText = NSAttributedString.init(string: "显示密码", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(named: "DodgerBlue")!])
        } else {
            // Fallback on earlier versions
            self.showPassword.attributedText = NSAttributedString.init(string: "显示密码", attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue])
        }
        self.showPassword.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnShowPassword)))
        
        // 配置textView
        note.delegate = self
        note.text = "add some note here!"
        note.textColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("#CreateItemVC--itemType: \(itemType)")
        // 显示传入的item数据
        if let item = item {
            let login: Login = item as! Login
            itemName.text = login.itemname
            userName.text = login.username
            password.text = login.password
            website.text = login.website
            note.text = login.note
        }
        // textFields中text无空，且当前textField的text不为空，enable saveButton
        if !textFieldsContainEmpty() {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
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
        if let item = item {
            // 更新item，先删除旧item，再插入新item
            print(item)
            PlistHelper.delete(itemModel: item, ofPersistentType: "MyIPHONE", itemType: itemType)
            login = Login(itemname: itemName.text!, username: userName.text!, password: password.text!, website: website.text!, note: note.text!)
            PlistHelper.insert(itemModel: login, ofPersistentType: "MyIPHONE", itemType: itemType)
            // 收起VC
            self.dismiss(animated: true, completion: {
                // 回传值new item
                self.passBackNewItemDetail(self.login)
            })
        } else {
            // 创建新item
            // 注意除了note字段，其他不许为空
            login = Login(itemname: itemName.text!, username: userName.text!, password: password.text!, website: website.text!, note: note.text!)
            PlistHelper.insert(itemModel: login, ofPersistentType: "MyIPHONE", itemType: itemType)
            
            // 更新item list页面（选择方式？？？）
            //reloadItemListVC(login)
            // 收起VC
            self.dismiss(animated: true, completion: {
                // 更新item list页面（选择方式？？？）
                self.reloadItemListVC(self.login)
            })
        }
        
    }
    
    @IBAction func handleGeneratePasswordAction(_ sender: Any) {
        // 移除重新生成密码button，添加新生成密码view
        let generateBtn = sender as! UIButton
        let contentView = generateBtn.superview
        generateBtn.removeFromSuperview()
        contentView?.addSubview(generateView)
        generateView.translatesAutoresizingMaskIntoConstraints = false
        generateView.leadingAnchor.constraint(equalTo: (contentView?.leadingAnchor)!, constant: 20).isActive = true
        generateView.trailingAnchor.constraint(equalTo: (contentView?.trailingAnchor)!, constant: -20).isActive = true
        generateView.topAnchor.constraint(equalTo: (contentView?.topAnchor)!, constant: 10).isActive = true
        generateView.bottomAnchor.constraint(equalTo: (contentView?.bottomAnchor)!, constant: -10).isActive = true
        generateView.delegate = self
    }
    
    
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
            
            /// 问题：当textField和textView同时存在时，此处crash
            /// 原因：当点击textView时，下面activeField=nil
            /// 解决：添加一步optional binding，明确不为nil的时候才执行
//            if !aRect.contains(activeField.frame.origin) {
//                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
//            }
            if let textField = activeField {
                /// 注意这个origin的相对关系，是相对super，还是相对self.view？？？
//                if !aRect.contains(textField.frame.origin) {
//                    self.scrollView.scrollRectToVisible(textField.frame, animated: true)
//                }
                /// 问题：textField这块逻辑有与否，实际并不影响tableView的滚动，？？？
                /// 原因：
                /// 解决：
                let point = textField.convert(textField.frame.origin, to: self.view)
                if !aRect.contains(point) {
                    let rect = textField.convert(textField.frame, to: self.view)
                    self.scrollView.scrollRectToVisible(rect, animated: true)
                }
            }
            
            /// 问题：当为textView时，滚动的距离有点大？？？
            ///
            ///
            if let textView = activeTextView {
                let point = textView.convert(textView.frame.origin, to: self.view)
                if !aRect.contains(point) {
                    let rect = textView.convert(textView.frame, to: self.view)
                    self.scrollView.scrollRectToVisible(rect, animated: true)
                }
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
        
        // textFields中text无空，且当前textField的text不为空，enable saveButton
        if !textFieldsContainEmpty() && !(textField.text?.isEmpty)! {
            saveBtn.isEnabled = true
        } else {
            saveBtn.isEnabled = false
        }
        // 显示密码，更新
        if passwordIsShow {
            showPassword.text = password.text
        }
    }
    
    // 判断textFields中是否包含未输入的textField（true有，false没有）
    fileprivate func textFieldsContainEmpty() -> Bool {
        for textField in textFields {
            if textField == website {
                break
            }
            if (textField.text?.isEmpty)! {
                return true
            }
        }
        return false
    }
 
    @objc func handleTapOnShowPassword(sender: UITapGestureRecognizer) {
        print("Tap showPassword")
        // 切换密码显示
        let label = sender.view as! UILabel
        if !passwordIsShow {
            label.text = password.text
        } else {
            if #available(iOS 11.0, *) {
                self.showPassword.attributedText = NSAttributedString.init(string: "显示密码", attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(named: "DodgerBlue")!])
            } else {
                // Fallback on earlier versions
                self.showPassword.attributedText = NSAttributedString.init(string: "显示密码", attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue])
            }
        }
        passwordIsShow = !passwordIsShow
    }
    
    
    // MARK: - GeneratePasswordDelegate
    func passwordDidGenerated(password: String) {
        print(password)
        self.password.text = password
        self.showPassword.text = self.password.text
    }
    
    
    // MARK: - Helper
    
    
    
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
    
    // 用这个方法判断合适enable saveButton不好
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
//        return true
//    }
    
    
}



// MARK: - UITextViewDelegate

extension CreateItemVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("#textViewShouldBeginEditing")
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("#textViewDidBeginEditing")
        activeTextView = textView
        if textView.text == "add some note here!" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("#textViewDidEndEditing")
        activeTextView = nil
        if textView.text.count < 1 {
            note.text = "add some note here!"
            note.textColor = UIColor.lightGray
        }
    }
}





