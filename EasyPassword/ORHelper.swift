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










