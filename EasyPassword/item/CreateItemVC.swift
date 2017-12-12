//
//  CreateItemVC.swift
//  EasyPassword
//
//  Created by libowen on 2017/12/8.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// CreateItemVC
/// 功能：创建item
/// 1、使用UIViewController，自定义创建页面
/// 2、点击cancel收起VC不存储
/// 3、点击save，保存编辑内容，写入plist，收起VC；收起VC后更新item list
///
///
///
///


import UIKit

class CreateItemVC: UIViewController {
    
    
    // MARK: - Properties
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func handleCancelAction(_ sender: UIBarButtonItem) {
        // 收起VC
    }
    
    @IBAction func handleSaveAction(_ sender: Any) {
        // item 写入plist
        // 更新item list页面（选择方式？？？）
        // 收起VC
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
