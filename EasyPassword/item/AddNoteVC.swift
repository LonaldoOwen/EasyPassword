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
/// 2、当文本过长时，达到键盘位置，向上滚动scrollview（）
///
///

import UIKit

class AddNoteVC: UIViewController {
    
    
    @IBOutlet weak var textView: UITextView!
    var note: String!
    var passBackNote: ((String) -> ())!   // 用于反向传值

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
