//
//  MainTableViewController.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/28.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// 功能：主视图，
/// 1、根据存储类型分别显示保存账户密码的文件夹
/// 2、创建新文件夹:(使用Alert：创建Alert、添加textField、actions；插入数据、插入cell、写入plist)
/// 3、编辑:
///    选中cell删除（多选）
///    修改文件夹名称（）
/// 4、默认显示备忘文件夹；当添加新的文件夹后，同时增加一个“所有persistent”文件夹，用于显示当前存储类型中所有的item（）
/// 5、缺少修改文件夹名称、删除文夹功能（）
/// 6、添加sqlite db
///
/// 问题：
/// 1、Toolbar选择的是translucent，但是显示的时候却是opaque？？？
/// 2、使用默认section header，section 0的title不显示？？？，设置section height后显示？？？
///

import UIKit

extension Login: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE Login(
            Item_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            Item_name CHAR(255),
            User_name CHAR(255),
            Password CHAR(255),
            Website CHAR(255),
            Note CHAR(255),
            Item_type INT,
            Persistent_type INT,
            Create_time DATATIME,
            Update_time DATATIME,
            Is_discard BOOLEAN
        );
        """
    }
    
}

class MainTableViewController: UITableViewController {
    
    @IBOutlet weak var addFolderItem: UIBarButtonItem!
    
    
    //var iphoneArray = [[String: Any]]()
    //var iphoneFolders = [FolderModel]()
    var iphoneFolders: [FolderModel]!
    var folderPlist = [[[String: Any]]]()
    
    
    var db: SQLiteDatabase!
    var logins: [Login]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        //self.editButtonItem.title = "编辑"
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        /// 使用property list 存储
        /*
        // 创建或读取plist数据（默认创建一个Folder.plist用于存储Main页面的数据）
        let fileManager = FileManager.default
        // 不存在，创建一个新的Folder.plist
        if !fileManager.fileExists(atPath: PlistHelper.getPlistPath(ofName: "Folder.plist")) {
            PlistHelper.makeDefaulFolderPlis()
        }
        */
        /// 使用sqlite存储
        // 创建db实例
        let dbUrl = SQLiteDatabase.getDBPath()
        let dbPath = dbUrl.path
        do {
             db = try SQLiteDatabase.open(path: dbPath)
            print("Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database. :\(message)")
        } catch {
            print("Others errors")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("#MainTableViewController--viewWillAppear")
        /*
        // 页面每次显示时，读取最新数据
        // 如果Folder.plist在沙盒中存在，则读取它的数据
        let plist = PlistHelper.readPlist(ofName: "Folder.plist") as! [[[String: Any]]]
        folderPlist = plist // copy plist
        // plist装换为model
        iphoneFolders = folderPlist[1].map {
            FolderModel(
                persistentType: $0["persistentType"] as! String,
                itemType: $0["itemType"] as! String,
                items: ($0["items"] as! [[String: Any]]).map {
                    Login(
                        itemname: $0["itemname"] as! String,
                        username: $0["username"] as! String,
                        password: $0["password"] as! String,
                        website: $0["website"] as! String,
                        note: $0["note"] as! String
                    )
                }
            )
        }
        */
        
        // 页面每次显示时，query db
        queryData()
        
        
        // 在此处刷新table view
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Action
    
    // 处理创建/删除文件夹action
    @IBAction func handleCreateNewFolderAction(_ sender: Any) {
        
        if isEditing {
            // 删除文件夹及对应数据
            deleteSelectedFolders()
        } else {
            // 创建新文件夹
            /// 根据sender的类型决定哪种操作
            // 创建新文件夹
            // show action sheet(可选不同类型)
            // show Alert
            // 同时创建对应plist
            //showAlertToCreateNewFolder()
            
            // 临时：点击新建文件夹，创建Login Table
            try? db.createTable(table: Login.self)
            
            // 插入login item
//            let insertSQL = "INSERT INTO Login (Item_name, User_name, Password, Website, Note, Item_type, Persistent_type, Create_time, Update_time, Is_discard) VALUES ('Login', 'ZhangSan', 'abc12345', 'abc.com', 'temp login item', '1', '1', '2018-01-11 00:00:00', '', '0');"
//            try? db.insert(sql: insertSQL)
            
            queryData()
            
            self.tableView.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        //
        //self.tableView.setEditing(editing, animated: true)
        print("#setEditing: \(editing)")
        if self.tableView.isEditing {
            self.editButtonItem.title = "完成"
        } else {
            self.editButtonItem.title = "编辑"
        }
        //
        configureItemInToobar()
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //return folderPlist.count
        
        //return iphoneFolders.count > 0 ? iphoneFolders.count : 0
        if let iphoneFolders = iphoneFolders {
            return iphoneFolders.count
        }
        return 0
    
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return folderPlist[section].count
        
        //return iphoneFolders.count > 0 ? iphoneFolders[section].items.count : 0
        if let iphoneFolders = iphoneFolders {
            return iphoneFolders.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        
        
        /*
         // 使用property list
        if indexPath.section == 1 {
            let folder = iphoneFolders[indexPath.row]
            cell.textLabel?.text = folder.itemType
            cell.detailTextLabel?.text = String(folder.items.count)
        } else {
            cell.textLabel?.text = folderPlist[0][0]["itemType"] as? String
            cell.detailTextLabel?.text = String((folderPlist[0][0]["items"] as! [[String: Any]]).count)
        }
        */
        // 使用sqlite db
        let iphoneFolder = iphoneFolders[indexPath.section]
        cell.textLabel?.text = iphoneFolder.itemType
        cell.detailTextLabel?.text = String(logins.count)
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DefaulSectionHeader")
        if sectionHeader == nil {
            sectionHeader = UITableViewHeaderFooterView(reuseIdentifier: "DefaulSectionHeader")
        }
        //sectionHeader?.textLabel?.text = folderPlist[section].first?["persistentType"] as? String
        sectionHeader?.textLabel?.text = iphoneFolders[section].persistentType
        
        return sectionHeader
    }
    
    /// 未实现此方法前，tableView section0的header不显示？？？
    ///
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        print("#canEditRowAt")
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("#commit editingStyle:")
    }
    
    
    
    // MARK: - Table View delegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        print("#editingStyleForRowAt")
        return UITableViewCellEditingStyle.none
    }
    
    // table view 的某个cell的background是否indent（缩进排版）
    // true: 缩进
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        print("#shouldIndentWhileEditingRowAt")
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("#didSelectRowAt")
        //
        configureItemInToobar()
        // 非编辑状态时跳转到新VC
        if !self.tableView.isEditing {
            let itemListTVC: ItemListTVC = storyboard?.instantiateViewController(withIdentifier: "ItemListTVC") as! ItemListTVC
            let cell = tableView.cellForRow(at: indexPath)
            // 传值
            itemListTVC.itemType = (cell?.textLabel?.text)!
            itemListTVC.items = iphoneFolders[indexPath.row].items
            self.show(itemListTVC, sender: nil)
            // 释放cell的selected状态
            tableView.deselectRow(at: indexPath, animated: false)
        }

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("#didDeselectRowAt")
        configureItemInToobar()
    }
    
    
    
    // MARK: - Helper
    
    // 判断toolbar中item的名称和状态
    func configureItemInToobar() {
        if isEditing {
            // 删除
            addFolderItem.title = "删除"
            /// tableView的indexPathsForSelectedRows保存了选中的cell的indexPath
            /// 通过它来判断
            if let selectedRows = tableView.indexPathsForSelectedRows {
                addFolderItem.isEnabled = selectedRows.count > 0
            } else {
                addFolderItem.isEnabled = false
            }
            
        } else {
            // 创建文件夹
            addFolderItem.title = "创建文件夹"
            addFolderItem.isEnabled = true
        }
    }
    
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
            
            // 保存新建的文件夹；添加到My IPHONE中
            print("save folder name: \(String(describing: alert.textFields?.first?.text))")
            
            // 获取textField的输入内容
            let folderName = alert.textFields?.first?.text
            // 插入到iphoneFolders
            //let item = FolderModel.item(name: folderName!, count: "0")
            let folder = FolderModel(persistentType: "My IPHONE", itemType: folderName!, items: [])
            self.iphoneFolders.append(folder)
            // 插入到iphoneArray
            /// 为什么此时未插入到self.folderPlist？？？？
            /// 原因：
            /// 解决：
            let tempDict = ["persistentType": "My IPHONE", "itemType": folderName!, "items": []] as [String : Any]
            var iphoneArray = self.folderPlist[1]
            iphoneArray.append(tempDict)
            // 插入到plist
            self.folderPlist[1] = iphoneArray
            // 插入cell
            self.tableView.insertRows(at: [IndexPath.init(row: (self.iphoneFolders.count) - 1, section: 1)], with: .automatic)
            // 写入Folder.plist
            let filePath = PlistHelper.getPlistPath(ofName: "Folder.plist")
            PlistHelper.write(plist: self.folderPlist, toPath: filePath)
            // 验证是否成功写入沙盒
            let plist = PlistHelper.readPlist(ofName: "Folder.plist") as! [[[String : Any]]]
            print("验证Folder.plist in sandbox: \(plist)")
        })
        // present modelly
        self.present(alert, animated: true, completion: nil)
    }
    
    // 删除选择的文件夹及对应数据
    func deleteSelectedFolders() {
        print("Delete selected folders")
        //
        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            /// 注意：这种根据IndexPath删除多个数组element的，要从后往前进行，否则会出现越界
            ///
            for (index, _) in indexPathsForSelectedRows.enumerated().reversed() {
                print("")
                // 删除model
                iphoneFolders.remove(at: index)
                // 删除plist
                folderPlist[1].remove(at: index)
                PlistHelper.deleteFolder(at: index)
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: indexPathsForSelectedRows, with: UITableViewRowAnimation.automatic)
            tableView.endUpdates()
        }
    }
    
    // queryData
    func queryData() {
        var folders = [FolderModel]()
        let queryAllSQL = "SELECT * FROM Login"
        if let logins = db.queryAll(sql: queryAllSQL) {
            self.logins = logins
            let iphoneFolder = FolderModel.init(persistentType: "Local", itemType: "Login", items: logins)
            // Fatal error: Index out of range
            //iphoneFolders[0] = iphoneFolder
            folders.append(iphoneFolder)
            iphoneFolders = folders
        } else {
            print("# DB have no Tables!")
        }
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
