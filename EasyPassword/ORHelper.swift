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
    //增加显示MasterPasswordVC功能
    func showMasterPasswordVC() {
        let storyBoard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let mpVC: MasterPasswordVC = storyBoard.instantiateViewController(withIdentifier: "MasterPasswordVC") as! MasterPasswordVC
        mpVC.modalTransitionStyle = .crossDissolve
        mpVC.modalPresentationStyle = .fullScreen
        self.present(mpVC, animated: true, completion: nil)
    }
}



