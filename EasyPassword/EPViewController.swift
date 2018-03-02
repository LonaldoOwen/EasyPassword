//
//  EPViewController.swift
//  EasyPassword
//
//  Created by libowen on 2018/2/9.
//  Copyright © 2018年 libowen. All rights reserved.
//
/// EPViewController
/// 功能：自定义UIViewController(Subclassing)，处理键盘遮挡输入框
/// 1、UITextField
/// 2、UITextView
///
/// 问题：
/// 1、如何使用POP实现该功能？？？
///



import UIKit

class EPViewController: UIViewController {
    
    //
    var _scrollView: UIScrollView!
    var _activeField: UITextField!
    var _activeTextView: UITextView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 注册keyboard通知(处理键盘遮挡)
        registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Helper
    
    // 注册监听键盘通知
    // Call this method somewhere in your view controller setup code.
    func registerForKeyboardNotifications() {
        print("#EPViewController--registerForKeyboardNotifications")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    @objc func keyboardWasShown(_ aNotification: Notification) {
        print("#EPViewController--keyboardWasShown")
        
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
    @objc func keyboardWillBeHidden(_ aNotification: Notification) {
        print("#EPViewController--keyboardWillBeHidden")
        
        // 恢复scrollview为默认状态
        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Hidden keyboard: \(keyboardBounds)")
        }
        let contentInsets = UIEdgeInsets.zero
        _scrollView.contentInset = contentInsets
        _scrollView.scrollIndicatorInsets = contentInsets
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
extension EPViewController: UITextFieldDelegate {
    // 点击return收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("#EPViewController--textFieldShouldBeginEditing")
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("#EPViewController--textFieldDidBeginEditing")
        _activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("#EPViewController--textFieldDidEndEditing")
        _activeField = nil
    }
}



// MARK: - UITextViewDelegate
extension EPViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("#EPViewController--textViewShouldBeginEditing")
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("#EPViewController--textViewDidBeginEditing")
        _activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("#EPViewController--textViewDidEndEditing")
        _activeTextView = nil
    }
}


extension EPViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("#EPViewController-- scrollViewDidEndDecelerating")
        print(scrollView.contentOffset)
    }
}






