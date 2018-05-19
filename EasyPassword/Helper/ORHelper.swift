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

// POP
/*
//@objc protocol BasiceProtocol: AnyObject { }
protocol Rollable {
    
    var _scrollView: UIScrollView! {get set}
    var _activeField: UITextField! {get set}
    var _activeTextView: UITextView! {get set}
    
    func registerForKeyboardNotifications()
}

//
//extension Rollable where Self: UIViewController {
//    // 点击return收起键盘
//    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return textField.resignFirstResponder()
//    }
//
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        print("#--textFieldShouldBeginEditing")
//        return true
//    }
//
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        print("#--textFieldDidBeginEditing")
//        _activeField = textField
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        print("#--textFieldDidEndEditing")
//        _activeField = nil
//    }
//}
 
//extension UITextFieldDelegate where Self: UIViewController {
//
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
*/


// MARK: - OOP和POP结合

protocol Rollable {
    var _scrollView: UIScrollView! {get set}
    var _activeField: UITextField! {get set}
    var _activeTextView: UITextView! {get set}
    
    func registerForKeyboardNotifications()
}

class BasicVC: UIViewController, Rollable {
    var _scrollView: UIScrollView!
    var _activeField: UITextField!
    var _activeTextView: UITextView!
}

extension BasicVC: UITextFieldDelegate {
    // 点击return收起键盘
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("#TextField--textFieldShouldBeginEditing")
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("#TextField--textFieldDidBeginEditing")
        _activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        print("#TextField--textFieldDidEndEditing")
        _activeField = nil
    }
}

//
extension BasicVC: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("#TextView--textViewShouldBeginEditing")
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("#TextView--textViewDidBeginEditing")
        _activeTextView = textView
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("#TextView--textViewDidEndEditing")
        _activeTextView = nil
    }
}

 

//
extension Rollable where Self: UIViewController {
    
    // 注册监听键盘通知
    // Call this method somewhere in your view controller setup code.
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
        
        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 设置contentInset
            let height = keyboardBounds.size.height + 20.0
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            _scrollView.contentInset = contentInsets
            _scrollView.scrollIndicatorInsets = contentInsets
            
            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            // 如果textField被键盘遮住，scrollview滚动，显示该textField
            var aRect = self.view.frame
            aRect.size.height -= height
            
            if let textField = _activeField {
                let point = textField.convert(textField.frame.origin, to: self.view)
                if !aRect.contains(point) {
                    let rect = textField.convert(textField.frame, to: self.view)
                    _scrollView.scrollRectToVisible(rect, animated: true)
                }
            }
            
            /// 处理textView
            print("before: \(_scrollView.contentOffset)")
            if let textView = _activeTextView {
                let point = textView.convert(textView.frame.origin, to: self.view)
                if !aRect.contains(point) {
                    /// 问题：此代码不会滚动？？？
//                    let rect = textView.convert(textView.frame, to: self.view)
//                    _scrollView.scrollRectToVisible(rect, animated: true)
                    
                    /// 问题：
                    /// 1、向下滚动，说明offset添加反了
                    /// 2、横屏时，不向上滚动???(添加横竖屏判断，横屏时，滚动过多？？？)
                    //let scrollPoint = CGPoint(x: 0.0, y: textView.frame.origin.y - keyboardBounds.size.height)    // 1
                    //let scrollPoint = CGPoint(x: 0.0, y: textView.frame.origin.y + keyboardBounds.size.height)      // 2
                    let scrollPoint: CGPoint!
                    if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
                        // Portrait
                        scrollPoint = CGPoint(x: 0.0, y: textView.frame.origin.y + keyboardBounds.size.height)
                    } else {
                        // Landscape
                        scrollPoint = CGPoint(x: 0.0, y: textView.frame.origin.y + keyboardBounds.size.width)
                    }
                    _scrollView.setContentOffset(scrollPoint, animated: true)
                    print("after: \(_scrollView.contentOffset)")
                }
            }
        }
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(_ aNotification: Notification) {
        print("#Rollable--keyboardWillBeHidden")
        
        // 恢复scrollview为默认状态
        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Hidden keyboard: \(keyboardBounds)")
        }
        let contentInsets = UIEdgeInsets.zero
        _scrollView.contentInset = contentInsets
        _scrollView.scrollIndicatorInsets = contentInsets
    }
}
















