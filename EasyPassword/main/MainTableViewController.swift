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
///    修改文件夹名称（不做此功能，类型是默认提供的，不支持自定义）
/// 4、默认显示备忘文件夹；当添加新的文件夹后，同时增加一个“所有persistent”文件夹，用于显示当前存储类型中所有的item（plist）
/// 5、缺少修改文件夹名称、删除文夹功能（使用db存储后，不需要此功能）
/// 6、添加sqlite db
/// 7、第一次进入，未创建table时，不显示？？？，显示一张默认图（）
///
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
            Persistent_type INT,
            Item_type INT,
            Create_time DATETIME,
            Update_time DATETIME,
            Is_discard BOOLEAN
        );
        """
    }
    
}

extension Note: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE Note(
        Item_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        Item_name CHAR(255),
        User_name CHAR(255),
        Note TEXT,
        Persistent_type INT,
        Item_type INT,
        Create_time DATETIME,
        Update_time DATETIME,
        Is_discard BOOLEAN
        );
        """
    }
    
    
}

class MainTableViewController: UITableViewController {
    
    @IBOutlet weak var addFolderItem: UIBarButtonItem!
    @IBOutlet weak var settingBtn: UIBarButtonItem!
    

    // sqlite db存储
    var icloudFolders: [FolderModel]!   // iCloud
    var iphoneFolders: [FolderModel]!   // 本地
    var folders: [Any]!                 //
    
    
    
    var db: SQLiteDatabase!
    //var logins: [Login]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        /// 使用sqlite存储
        // 创建db实例
        let dbUrl = SQLiteDatabase.getDBPath("EasyPassword.sqlite")
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
        // 注册UIApplicationDidBecomeActive通知
        //NotificationCenter.default.addObserver(self, selector: #selector(handleObserverUIApplicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
        
        // sqlite db存储
        // 页面每次显示时，query db，只查询需要的字段即可，区别plist
        queryData()
        // 在此处刷新table view
        self.tableView.reloadData()
        // 配置item状态
        configureItemOfNavigationBar()
        configureItemInToolbar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Action
    
    // 收起创建item VC
    @IBAction func closeModifyVC(_ segue: UIStoryboardSegue) {
        // 使用Storyboard的Exit时，用到
    }
    
    // 处理创建/删除文件夹action
    @IBAction func handleCreateNewFolderAction(_ sender: Any) {
        
        if isEditing {
            // 删除文件夹及对应数据
            deleteSelectedFolders()
        } else {
            // sqlite db 存储
            // 显示action sheet
            showActionSheet()
        }
        
    }
    
    // 处理UIApplicationDidBecomeActive事件
//    @objc func handleObserverUIApplicationDidBecomeActive(_ notification: Notification) {
//        //
//        print("#handleObserverUIApplicationDidBecomeActive: \(notification)")
//        //let app: UIApplication = notification.object as! UIApplication
//        self.showMasterPasswordVC()
//    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        
        print("#setEditing: \(editing)")
        //self.tableView.setEditing(editing, animated: true)
        // 配置items状态
        configureItemOfNavigationBar()
        configureItemInToolbar()
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // using sqlite db
        if let folders = folders {
            return folders.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // using sqlite db
        if let folders = folders {
            return (folders[section] as! [Any]).count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("#cellForRowAt")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        /// 使用sqlite db
        // iphone
        if let iphoneFolders = iphoneFolders {
            let iphoneFolder = iphoneFolders[indexPath.row]
            //cell.textLabel?.text = iphoneFolder.folderType.typeString
            if iphoneFolder.folderType == FolderModel.FolderType.all {
                cell.textLabel?.text = "IPHONE上的所有类型"
            } else if iphoneFolder.folderType == FolderModel.FolderType.login {
                cell.textLabel?.text = "登录信息"
            } else if iphoneFolder.folderType == FolderModel.FolderType.note {
                cell.textLabel?.text = "备忘信息"
            }
            cell.detailTextLabel?.text = String(iphoneFolder.count)
            cell.imageView?.image = UIImage.init(named: iphoneFolder.folderType.imageName)
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DefaulSectionHeader")
        
        if sectionHeader == nil {
            sectionHeader = UITableViewHeaderFooterView(reuseIdentifier: "DefaulSectionHeader")
        }
        if let folders = folders {
            sectionHeader?.textLabel?.text = (folders[section] as! [FolderModel]).first?.persistentType.typeString
        }
        
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

        configureItemInToolbar()
        // 非编辑状态时跳转到新VC
        if !self.tableView.isEditing {
            let itemListTVC: ItemListTVC = storyboard?.instantiateViewController(withIdentifier: "ItemListTVC") as! ItemListTVC
            //let cell = tableView.cellForRow(at: indexPath)
            
            let iphoneFolder: FolderModel = iphoneFolders[indexPath.row]
            // 使用sqlite db存储，传递itemType、persistentType（？）
            itemListTVC.folderType = iphoneFolder.folderType
            itemListTVC.persistentType = iphoneFolder.persistentType
            
            // 显示itemListTVC
            self.show(itemListTVC, sender: nil)
            // 释放cell的selected状态
            tableView.deselectRow(at: indexPath, animated: false)
        }

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("#didDeselectRowAt")
        
        configureItemInToolbar()
    }
    
    
    
    // MARK: - Helper
    
    // 配置导航栏中item名称及状态
    func configureItemOfNavigationBar() {
        // 配置edite button文案
        if self.isEditing {
            self.editButtonItem.title = "完成"
        } else {
            self.editButtonItem.title = "编辑"
        }
        // 控制navigatItem是否显示
        if folders == nil || folders.count == 0 {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
    }
    
    // 配置toolbar中item的名称和状态
    func configureItemInToolbar() {
        if isEditing {
            // 删除
            addFolderItem.title = "删除"
            /// tableView的indexPathsForSelectedRows保存了选中的cell的indexPath
            /// 通过它来判断
            if let selectedRows = tableView.indexPathsForSelectedRows {
                addFolderItem.isEnabled = selectedRows.count > 0
                if selectedRows.count > 1 {
                    addFolderItem.title = "删除所有类型"
                }
            } else {
                addFolderItem.isEnabled = false
            }
            
            // 设置
            settingBtn.isEnabled = false
            
        } else {
            // 创建文件夹
            addFolderItem.title = "新建类型"
            addFolderItem.isEnabled = true
            // 设置
            settingBtn.isEnabled = true
        }
        
    }
    
    // 显示action sheet
    func showActionSheet() {
        // 显示可以创建的类型
        let sheet = UIAlertController.init(title: "新建类型", message: "选择要创建的类型", preferredStyle: UIAlertControllerStyle.actionSheet)
        sheet.addAction(UIAlertAction.init(title: "登录信息", style: UIAlertActionStyle.default, handler: { (action) in
            print("Login action")
            // 处理Login操作
            // 1、第一次创建，创建一个新Login table
            // 2、非第一次，不创建table，而是跳到list页面，调起CreateVC页面

            // 跳转到CreateItemVC
            self.showCreateItemVC(withItemType: FolderModel.ItemType.login, persistentType: FolderModel.PersistentType.iphone)
        }))
        sheet.addAction(UIAlertAction.init(title: "备忘信息", style: UIAlertActionStyle.default, handler: { (action) in
            print("Note action")
            // 处理Note操作
            // 1、第一次创建，创建一个新Note table
            // 2、非第一次，不创建table，而是跳到list页面，调起CreateVC页面

            // 跳转到CreateNoteVC
            self.showCreateNoteVC(withItemType: FolderModel.ItemType.note, persistentType: FolderModel.PersistentType.iphone)
        }))
        sheet.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        
        // present modelly
        self.present(sheet, animated: true, completion: {
            print("")
        })
    }
    
    // show CreateItemVC
    func showCreateItemVC(withItemType itemType: FolderModel.ItemType, persistentType: FolderModel.PersistentType) {
        // present create login VC
        let nav: UINavigationController = storyboard?.instantiateViewController(withIdentifier: "CreateItemVCNav") as! UINavigationController
        let createItemVC: CreateItemVC = nav.topViewController as! CreateItemVC
        createItemVC.persistentType = persistentType
        createItemVC.itemType = itemType//FolderModel.ItemType(rawValue: folderType.rawValue) // 通过folderType转换为itemType
        self.show(nav, sender: nil)
    }
    
    // show CreateNoteVC
    func showCreateNoteVC(withItemType itemType: FolderModel.ItemType, persistentType: FolderModel.PersistentType) {
        // present create note VC
        let nav: UINavigationController = storyboard?.instantiateViewController(withIdentifier: "CreateNoteVCNav") as! UINavigationController
        let createNoteVC: CreateNoteVC = nav.topViewController as! CreateNoteVC
        createNoteVC.persistentType = persistentType
        createNoteVC.itemType = itemType//FolderModel.ItemType(rawValue: folderType.rawValue)
        self.show(nav, sender: nil)
    }
    
    
    // 删除选择的文件夹及对应数据
    func deleteSelectedFolders() {
        print("Delete selected folders")
        
        var deleteRows = [IndexPath]()
        var indexSet = IndexSet()
        if let indexPathsForSelectedRows = tableView.indexPathsForSelectedRows {
            /// 注意：这种根据IndexPath删除多个数组element的，要从后往前进行，否则会出现越界
            deleteRows = indexPathsForSelectedRows
            for (index, _) in indexPathsForSelectedRows.enumerated().reversed() {
                /// sqlite db存储
                let indexPath = indexPathsForSelectedRows[index]
                /// 问题：as!后，获得的是immutable copy
                ///
                //(folders[indexPath.section] as! [FolderModel]).remove(at: indexPath.row)
                var folder = folders[indexPath.section] as! [FolderModel]
                let tableType = folder[indexPath.row].folderType
                
                // 删除model
                folder.remove(at: indexPath.row)
                folders[indexPath.section] = folder
                // 当Section中，只剩下All这个cell时，将它一起删除
                if folder.count == 1 {
                    folder.remove(at: 0)
                    folders.remove(at: indexPath.section)
                    deleteRows.insert(IndexPath.init(row: 0, section: indexPath.section), at: 0)
                    indexSet = IndexSet.init(integer: indexPath.section)
                }
                
                // Delete Table
                try? db.deleteTable(sql: "DROP TABLE \(tableType.typeString)")
                if tableType == FolderModel.FolderType.login {
                    // 如果删除的是Login table，同时删除PasswordHistory（不能删，删了主密码也删了，就无法进入了）
                    //try? db.deleteTable(sql: "DROP TABLE PasswordHistory")
                    // 如果删除的是Login table，将Login类型的密码历史删除
                    try? db.delete(sql: "DELETE FROM PasswordHistory WHERE Item_type = '1';")
                }
            }
            // 删除cells或sections
            tableView.beginUpdates()
            tableView.deleteRows(at: deleteRows, with: UITableViewRowAnimation.automatic)
            /// 注意：如果想删除所有cell，未加入删除sections时，一直crash
            ///
            tableView.deleteSections(indexSet, with: UITableViewRowAnimation.automatic)
            tableView.endUpdates()
            self.setEditing(false, animated: true)
            
        }
    
    }
    
    // queryData
    func queryData() {
        print("queryData")
        
        /// 验证querySql中每步结果
        // 查询整个Table
        //let tempArray = db.querySql(sql: "SELECT * FROM Login")
        // 条件查询
        //let tempArray = db.querySql(sql: "SELECT Item_id, Item_name, User_name  FROM  Login WHERE Item_id = 2 OR User_name = 'aaa';")
        // 条件查询，并降序排列
        //let tempArray = db.querySql(sql: "SELECT Item_id, Item_name, User_name  FROM  Login WHERE Item_id = 2 OR User_name = 'aaa' ORDER BY Item_id  DESC;")
        
        var tempFolders = [Any]()
        /// 查询iCloud
        // 将结果保存在icloudFolders
        // 并添加到folders中
        // var tempIcloudFolders = ["IcloudModel"]()
        
        /// 查询iphone
        var tempIphoneFolders = [FolderModel]()
        // 先查询db中的Table--从sqlite_master表中查
        let masterTableRows = db.numberOfRowsInTable("sqlite_master")
        if masterTableRows > 1 {
            // 有自己创建的Table，获取table name
            // 查询所有table name
            var countAll: Int = 0
            if db.masterContainTable("Login")! {
                // Table--Login
                let login = buildLoginModel()
                tempIphoneFolders.append(login)
                countAll += Int(login.count)!
            }
            if db.masterContainTable("Note")! {
                // Table--Note
                print("Qeury Table Note")
                let note = buildNoteModel()
                tempIphoneFolders.append(note)
                countAll += Int(note.count)!
            }
            // 统计所有类型
            if db.masterContainTable("Login")! || db.masterContainTable("Note")! {
                let all = FolderModel.init(persistentType: .iphone, folderType: .all, count: String(countAll))
                tempIphoneFolders.insert(all, at: 0)
            }
            if tempIphoneFolders.count > 0 {
                self.iphoneFolders = tempIphoneFolders
                tempFolders.append(tempIphoneFolders)
            }
//            self.iphoneFolders = tempIphoneFolders
//            tempFolders.append(tempIphoneFolders)
        } else {
            print("# There is no tables in db.")
        }
        self.folders = tempFolders
    }
    
    // 构造login data model
    func buildLoginModel() -> FolderModel{
        // 查询所有Login的数据
        // 问题：numberOfRowsInTable()计算的是所有rows，实际需要的是非Is_discard的rows
        // 解决：查询Table中条件是Is_discard='0'的rows
        let loginTableRows = db.numberOfRowsInTable("Login") 
        let iphoneFolder = FolderModel.init(persistentType: .iphone, folderType: .login, count: String(loginTableRows))
        
        return iphoneFolder
    }
    
    // 构造Note data model
    func buildNoteModel() -> FolderModel {
        // 查询所有Note的数据
        let noteTableRows = db.numberOfRowsInTable("Note")
        let iphoneFolder = FolderModel.init(persistentType: .iphone, folderType: .note, count: String(noteTableRows))
        
        return iphoneFolder
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
