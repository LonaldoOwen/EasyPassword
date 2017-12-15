//
//  ItemDetailTVC.swift
//  EasyPassword
//
//  Created by libowen on 2017/12/14.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// ItemDetailTVC
/// 功能：显示item详情
/// 1、将item信息已列表形式显示；分4个section（登录目的地；用户名、密码；网站；备注）
/// 2、点击cell显示edit menu（copy、）--UIMenuController
/// 3、
///
///
///




import UIKit

class ItemDetailTVC: UITableViewController {
    
    static let cellIdentifier = "ItemDetailCell"
    
    // Properties
    var item: Item!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - UIResponder
    
    //
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    //
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(handleCopyAction) {
            return true
        } else if action == #selector(handleBigWordAction) {
            return true
        }
        
        return false
    }
    
    
    // MARK: - Table view data source

    //
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 1
        case 3: return 1
        default:
            return 0
        }
        //return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemDetailTVC.cellIdentifier, for: indexPath)
        let login = item as! Login
        
        if indexPath.section == 0 {
            cell.textLabel?.text = login.itemname
            cell.detailTextLabel?.text = "登录信息"
            cell.imageView?.image = UIImage(named: "wode1@3x")
        } else if indexPath.section == 1{
            if indexPath.row == 0 {
                cell.textLabel?.text = "用户名"
                cell.detailTextLabel?.text = login.username
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "密码"
                cell.detailTextLabel?.text = login.password
            }
        } else if indexPath.section == 2 {
            cell.textLabel?.text = "网站"
            cell.detailTextLabel?.text = login.website
        } else if indexPath.section == 3 {
            cell.textLabel?.text = "备注"
            cell.detailTextLabel?.text = login.note
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 问题：设置为0，不起作用？？？
        //return 0.0
        return 0.01
    }
 

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("#ItemDetailTVC--didSelectRowAt")
        
        if let cell = tableView.cellForRow(at: indexPath), self.isFirstResponder {
            // show edit menu
            let editMenu = UIMenuController.shared
            editMenu.menuItems = [
                UIMenuItem(title: "COPY", action: #selector(handleCopyAction)),
                UIMenuItem(title: "Big Word", action: #selector(handleBigWordAction))
            ]
            editMenu.setTargetRect(cell.frame, in: cell.superview!)
            editMenu.setMenuVisible(true, animated: true)
            print("")
        }
        // 否则在先canBecomeFirstResponder中返回true，default=false
    }
    
    
    // MARK: - Helper
    
    @objc func handleCopyAction() {
        print("Copy")
    }
    
    @objc func handleBigWordAction() {
        print("Big word")
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



