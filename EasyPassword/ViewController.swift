//
//  ViewController.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/28.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// 功能：
/// 1、code snippet--UIMenuController用法实例（待归档）
/// 2、借此研究下responder chain，弄清楚默认first responder是谁，怎么传递的，怎么获得first responder
///
///

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var testView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /// 显示edit menu方法一：使用Tap gestrue
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestrue))
        //testView.addGestureRecognizer(tapGesture)
        
        // 验证rgb颜色使用
        let testRGBView = UIView.init(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        self.view.addSubview(testRGBView)
        //testRGBView.backgroundColor = UIColor.red
        //testRGBView.backgroundColor = UIColor.init(red: 100, green: 149, blue: 237, alpha: 1.0)
//        if #available(iOS 10.0, *) {
//            testRGBView.backgroundColor = UIColor.init(displayP3Red: 100, green: 149, blue: 237, alpha: 1.0)
//        } else {
//            // Fallback on earlier versions
//        }
        if #available(iOS 11.0, *) {
            testRGBView.backgroundColor = UIColor(named: "CornflowerBlue")
        } else {
            // Fallback on earlier versions
            testRGBView.backgroundColor = UIColor.blue
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // 当前object可以成为first responder
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    
    // edit menu 可以显示的item
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(copy(_:)) {
            return true
        } else if action == #selector(paste(_:)) {
            return true
        } else if action == #selector(handleCopyAction) {
            return true
        } else if action == #selector(handleShowBigAction) {
            return true
        }
        return false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("begin")
    }
    
    /// 显示edit menu 方法二：touch event
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
        let theThouch = (touches as NSSet).anyObject() as! UITouch
        if theThouch.tapCount == 2 && self.becomeFirstResponder() {
            
            // bring up edit menu
            let theMenu = UIMenuController.shared
            theMenu.menuItems = [
                UIMenuItem.init(title: "COPY", action: #selector(handleCopyAction)),
                UIMenuItem.init(title: "Show Big", action: #selector(handleShowBigAction))
            ]
            //theMenu.update()
            theMenu.setTargetRect(testView.frame, in: self.view)
            theMenu.setMenuVisible(true, animated: true)
            print("")
        }
        // 否则在先canBecomeFirstResponder中返回true，default=false
        // or tap count not equal 2
    }
    
    
    // action
    @objc func handleTapGestrue(_ recognizer: UIGestureRecognizer) {
        print("Tap")
        
        let tempView = recognizer.view
        if self.isFirstResponder {
            // bring up edit menu
            let theMenu = UIMenuController.shared
            theMenu.setTargetRect((tempView?.frame)!, in: self.view)
            theMenu.setMenuVisible(true, animated: true)
            print("")
        }
        // 否则在先canBecomeFirstResponder中返回true，default=false
    }
    
    @objc func handleCopyAction() {
        print("COPY")
    }
    
    @objc func handleShowBigAction() {
        print("Show Big")
    }

}

