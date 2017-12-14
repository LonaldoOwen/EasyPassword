//
//  ViewController.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/28.
//  Copyright © 2017年 libowen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var testView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestrue))
        testView.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("begin")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ended")
//        let theThouch = touches.first
//        if theThouch?.tapCount == 1 && self.becomeFirstResponder() {
//            let theMenu = UIMenuController.shared
//            theMenu.setTargetRect(testView.frame, in: self.view)
//            theMenu.setMenuVisible(true, animated: true)
//            print("")
//        }
    }
    
    @objc func handleTapGestrue(_ recognizer: UIGestureRecognizer) {
        print("Tap")
        testView.becomeFirstResponder()
        let theMenu = UIMenuController.shared
        theMenu.setTargetRect(testView.frame, in: testView)
        theMenu.setMenuVisible(true, animated: true)
        print("")
    }

}

