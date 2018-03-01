//
//  ORHelper.swift
//  EasyPassword
//
//  Created by owen on 28/01/2018.
//  Copyright © 2018 libowen. All rights reserved.
//
/// ORHelper
/// 功能：将一些全局及常用的小功能放在此处
/// 1、扩展UIViewController，增加显示MasterPasswordVC功能
///
///
///



import UIKit
import Foundation



class ORHelper {
    //
}




extension UIViewController {
    
    //增加显示MasterPasswordVC功能(废弃，因为使用了UIView)
//    func showMasterPasswordVC() {
//        let storyBoard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let mpVC: MasterPasswordVC = storyBoard.instantiateViewController(withIdentifier: "MasterPasswordVC") as! MasterPasswordVC
//        mpVC.modalTransitionStyle = .crossDissolve
//        mpVC.modalPresentationStyle = .fullScreen
//        self.present(mpVC, animated: true, completion: nil)
//    }
    
    // 显示提示信息（好几处都用到相同的功能）
    func showAlert(title: String, message: String, actionTitle: String) {
        let alertVC = UIAlertController.init(title: title, message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        alertVC.addAction(UIAlertAction.init(title: actionTitle, style: UIAlertActionStyle.default, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
}






// 扩展UIColor
extension UIColor {
    
    // DodgerBlue(系统button的蓝色)
    class var dodgerBlue: UIColor {
        return UIColor.init(red: 30.0/255, green: 144.0/255, blue: 255.0/255, alpha: 1.0)
    }
    
    // 创建密码黄色：255 206 0 1.0
    
}




/// 扩展UIViewController，增加处理键盘遮挡能力

protocol Rollable: UITextFieldDelegate {
    
    var _scrollView: UIScrollView! {get set}
    var _activeField: UITextField! {get set}
    var _activeTextView: UITextView! {get set}
    
    func registerForKeyboardNotifications()
}



//
//extension Rollable where Self: UITextFieldDelegate {
//
//}


//
extension Rollable where Self: UIViewController {
    // 点击return收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("#--textFieldShouldBeginEditing")
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("#--textFieldDidBeginEditing")
        _activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print("#--textFieldDidEndEditing")
        _activeField = nil
    }
}

//extension UIViewController: UITextFieldDelegate, Rollable {
//
//    // 点击return收起键盘
//    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return textField.resignFirstResponder()
//    }
//
//    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        print("#--textFieldShouldBeginEditing")
//        return true
//    }
//
//    public func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("#--textFieldDidBeginEditing")
//        _activeField = textField
//    }
//
//    public func textFieldDidEndEditing(_ textField: UITextField) {
//        print("#--textFieldDidEndEditing")
//        _activeField = nil
//    }
//}

//
//extension Rollable where Self: UIViewController {
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        print("#EPViewController--textViewShouldBeginEditing")
//        return true
//    }
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        print("#EPViewController--textViewDidBeginEditing")
//        _activeTextView = textView
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        print("#EPViewController--textViewDidEndEditing")
//        _activeTextView = nil
//    }
//}

//
extension Rollable where Self: UIViewController {
    
    func registerForKeyboardNotifications() {
        print("#EPViewController--registerForKeyboardNotifications")
        
        /// 问题：使用protocol扩展时，包含#selector时，编译错误
        /// 原因：#selector是Objective-C用法，不能在Swift Protocol 扩展中用
        /// 解决：使用closure替换
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: nil) { (notification) in
            self.keyboardWasShown(notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { (notification) in
            self.keyboardWillBeHidden(notification)
        }
        
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    func keyboardWasShown(_ aNotification: Notification) {
        print("#Rollable--keyboardWasShown")
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(_ aNotification: Notification) {
        print("#Rollable--keyboardWillBeHidden")
    }
}
















