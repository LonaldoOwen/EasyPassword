//
//  BaseTableViewController.swift
//  EasyPassword
//
//  Created by libowen on 2018/3/13.
//  Copyright © 2018年 libowen. All rights reserved.
//
/// 功能：
///
///
///
///


import UIKit

class BaseTableViewController: UITableViewController {

    // MARK: - Configuration
    
    // 设置cell数据
    func configureCell(_ cell: UITableViewCell, forItem item: Item) {
        debugPrint("#BaseTableViewController: configureCell")
        
        if item is Login {
            print("")
            let login: Login = item as! Login
            cell.textLabel?.text = login.itemName
            cell.detailTextLabel?.text = login.userName
        } else if item is Note {
            let note: Note = item as! Note
            cell.textLabel?.text = note.itemName
            cell.detailTextLabel?.text = note.note != "" ? note.note : " "
        } else if item is List {
            let list: List = item as! List
            cell.textLabel?.text = list.itemName
            //cell.detailTextLabel?.text = list.note != "" ? list.note : " "
            if item.itemType == FolderModel.ItemType.login {
                cell.detailTextLabel?.text = list.userName
            } else if item.itemType == FolderModel.ItemType.note {
                cell.detailTextLabel?.text = list.note != "" ? list.note : " "
            }
        }
        // 根据item的itemType实际类型，统一设置图像
        if item.itemType == FolderModel.ItemType.login {
            cell.imageView?.image = UIImage(named: "login36")
        } else if item.itemType == FolderModel.ItemType.note {
            cell.imageView?.image = UIImage(named: "note36")
        }
    }
}
