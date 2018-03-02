//
//  AddNoteVC.swift
//  EasyPassword
//
//  Created by owen on 24/01/2018.
//  Copyright © 2018 libowen. All rights reserved.
//
/// AddNoteVC
/// 功能：
/// 1、编辑note文本
/// 2、当文本过长时，达到键盘位置，向上滚动scrollview,怎么解决？？？（暂时用textField方法解决）
///
///

import UIKit

class AddNoteVC: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    var note: String!
    var passBackNote: ((String) -> ())!   // 用于反向传值
    var activeTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //
        textView.delegate = self
        
        // 注册keyboard通知(处理键盘遮挡)
        registerForKeyboardNotifications()
        //_scrollView = scrollView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let note = note {
            textView.text = note
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 返回时，将text传给CreateNoteVC
        passBackNote(textView.text)
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Helper
    
    // Call this method somewhere in your view controller setup code.
    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: .UIKeyboardWillHide, object: nil)
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    @objc
    func keyboardWasShown(_ aNotification: Notification) {
        /// 处理键盘遮挡输入框，滚动scrollView

        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Show keyboard: \(keyboardBounds)")

            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardBounds.size.height, right: 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets

            // If active text field is hidden by keyboard, scroll it so it's visible
            // Your app might not need or want this behavior.
            var aRect = self.view.frame
            aRect.size.height -= keyboardBounds.size.height

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
        /// 键盘收起，还原scrollView
        if let keyboardBounds = (aNotification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            print("Hidden keyboard: \(keyboardBounds)")
        }
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
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


// MARK: - UITextViewDelegate

extension AddNoteVC: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        print("#textViewShouldBeginEditing")
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        print("#textViewDidBeginEditing")
        activeTextView = textView
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("#textViewDidEndEditing")
        activeTextView = nil
        //textView.resignFirstResponder()
    }


}




