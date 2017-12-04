//
//  MainTableViewController.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/28.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// 功能：主视图，
/// 1、显示保存账户密码的文件夹
/// 2、创建新文件夹:(使用Alert)
/// 创建Alert、添加textField、actions；插入数据、插入cell、写入plist
///
/// 3、编辑:
///
///
///
/// 问题：
/// 1、Toolbar选择的是translucent，但是显示的时候却是opaque？？？
/// 2、使用默认section header，section 0的title不显示？？？，设置section height后显示？？？
///

import UIKit

class MainTableViewController: UITableViewController {
    
    var foldersArray = [[String: Any]]()
    var folders = [FolderModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // 创建或读取plist数据（默认创建一个Folder.plist用于存储Main页面的数据）
        let fileManager = FileManager.default
        // 不存在，创建一个新的Folder.plist
        if !fileManager.fileExists(atPath: PlistHelper.getPlistPath(ofName: "Folder.plist")) {
            PlistHelper.makeDefaulFolderPlis()
        }
        // 如果Folder.plist在沙盒中存在，则读取它的数据
        let folderPlist = PlistHelper.readPlist(ofName: "Folder.plist") as! [[String : Any]]
        foldersArray = folderPlist
        // plist装换为model
        folders = folderPlist.map {
            FolderModel(
                type: $0["type"] as! String,
                items: ($0["items"] as! [[String: Any]]).map {
                    FolderModel.item(
                        name: $0["name"] as! String,
                        count: $0["count"] as! String
                    )
                }
            )
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Action
    
    // 处理编辑acion
    @IBAction func handleEditAction(_ sender: UIBarButtonItem) {
        print("#handleEditAction")
    }
    
    // 处理创建新文件夹action
    @IBAction func handleCreateNewFolderAction(_ sender: UIBarButtonItem) {
        // show action sheet(可选不同类型)
        
        // show Alert
        // 创建新文件夹
        // 同时创建对应plist
        showAlertToCreateNewFolder()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        //
        print("#setEditing: \(editing)")
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return folders.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return folders[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        let item = folders[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.count
        return cell
    }
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 验证section0为什么不显示
        if section == 0 {
            print("Section: 0")
        }
        
        var sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DefaulSectionHeader")
        if sectionHeader == nil {
            sectionHeader = UITableViewHeaderFooterView(reuseIdentifier: "DefaulSectionHeader")
        }
        //sectionHeader?.textLabel?.text = "Header"
        let folder = folders[section]
        sectionHeader?.textLabel?.text = folder.type
        return sectionHeader
    }
    
    /// 未实现此方法前，tableView section0的header不显示？？？
    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        print("#canEditRowAt")
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("#commit editingStyle:")
    }
    
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        print("#editingStyleForRowAt")
        return UITableViewCellEditingStyle.delete
    }
    
    
    // MARK: - Helper
    
    func showActionSheet() {
        
    }
    
    // 显示Alert 用于创建新文件夹
    func showAlertToCreateNewFolder() {
        let alert = UIAlertController.init(title: "新建文件夹", message: "请为此文件夹输入名称", preferredStyle: .alert)
        // 添加textField
        alert.addTextField { (textField) in
            textField.placeholder = "名称"
        }
        // 添加action
        alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "存储", style: UIAlertActionStyle.destructive) { (saveAction) in
            // 保存新建的文件夹
            print("save folder name: \(String(describing: alert.textFields?.first?.text))")
            
            // 获取textField的输入内容
            let folderName = alert.textFields?.first?.text
            // 插入到folders
            let item = FolderModel.item(name: folderName!, count: "0")
            self.folders.first?.items.append(item)
            // 插入到foldersArray
            //self.foldersArray = PlistHelper.readPlist(ofName: "Folder.plist") as! [[String: Any]]
            //(self.foldersArray[0]["items"] as! [[String: Any]]).append(["name": folderName, "count": "0"])
            var items = (self.foldersArray[0]["items"] as! [[String: Any]])
            items.append(["name": folderName as Any, "count": "0"])
            self.foldersArray[0].updateValue(items, forKey: "items")
            
            // 插入cell
            self.tableView.insertRows(at: [IndexPath.init(row: (self.folders.first?.items.count)! - 1, section: 0)], with: .automatic)
            // 写入Folder.plist
            let filePath = PlistHelper.getPlistPath(ofName: "Folder.plist")
            PlistHelper.write(plist: self.foldersArray, toPath: filePath)
            // 验证是否成功写入沙盒
            let folderPlist = PlistHelper.readPlist(ofName: "Folder.plist") as! [[String : Any]]
            print("验证Folder.plist in sandbox: \(folderPlist)")
        })
        // present modelly
        self.present(alert, animated: true, completion: nil)
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
