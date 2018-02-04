//
//  ItemListTVC.swift
//  EasyPassword
//
//  Created by owen on 05/12/2017.
//  Copyright © 2017 libowen. All rights reserved.
//
///  ItemListTVC
/// 功能：item list
/// 1、title显示用户名、detail显示密码
/// 2、长按显示edit(?)，可以复制用户名、密码
/// 3、点返回，回到文件列表，需要刷新table view（在viewWillAppear中操作即可）
/// 4、添加完新的item后，刷新当前table view
/// 5、search bar使用？？？（V1.0.0暂时砍掉，后面再加）
/// 6、缺少删除cell的功能、多选、移动到其他文件夹（多选、移动第二版做）
/// 7、从all进入，查询所有table，显示在一起，按Update_time倒序排列
/// 8、
///




import UIKit

class ItemListTVC: UITableViewController {
    
    //var itemType: FolderModel.ItemType!
    var persistentType: FolderModel.PersistentType!
    var folderType: FolderModel.FolderType!
    var items: [Item]!
    var db: SQLiteDatabase!
    
    @IBOutlet weak var addItem: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // 注册通知--用于接收详情页面传来item model（未用到）
        //NotificationCenter.default.addObserver(self, selector: #selector(handlePassBackItemNotification), name: NSNotification.Name(rawValue: "PassBackItemFromDetail"), object: nil)
        
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
        print("#ItemListTVC--viewWillAppear")
        print("persistentType: \(persistentType)")
        print("folderType: \(folderType)")
        // 接收传值，显示title
        self.title = folderType.typeString
        // 如果使用db，根据itemType查询db，显示tableView
        queryData()
        // 配置工具栏item状态
        configureToolBarItems()
        // 刷新UI
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // 配置工具栏item状态
        configureToolBarItems()
    }
    
    
    @IBAction func handleAddAction(_ sender: UIBarButtonItem) {
        // 根据folderType类型选择合适的VC跳转
        if folderType == FolderModel.FolderType.login {
            // present create login VC
            showCreateItemVC(withItemType: FolderModel.ItemType.login)
        } else if folderType == FolderModel.FolderType.note {
            // present create note VC
            showCreateNoteVC(withItemType: FolderModel.ItemType.note)
        } else if  folderType == FolderModel.FolderType.all {
            // present select type action sheet
            print("#Show action sheet.")
            // 弹出action sheet
            showActionSheet()
        }
    }
    
    // 收起创建item VC
    @IBAction func close(_ segue: UIStoryboardSegue) {
        // 使用Storyboard的Exit时，用到
    }
    
//    @objc func handlePassBackItemNotification(_ notification: Notification) {
//        print("#handlePassBackItemNotification: \(notification)")
//
//    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let items = items {
            return items.count
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)

        // Configure the cell...
        if let items = items {
            let item = items[indexPath.row]
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
                cell.detailTextLabel?.text = list.note != "" ? list.note : " "
            }
            // 根据item的itemType实际类型，统一设置图像
            if item.itemType == FolderModel.ItemType.login {
                cell.imageView?.image = UIImage(named: "login36")
            } else if item.itemType == FolderModel.ItemType.note {
                cell.imageView?.image = UIImage(named: "note36")
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 删除cell
        if editingStyle == UITableViewCellEditingStyle.delete {
            let item = self.items![indexPath.row]
            // 删除model对应数据
            self.items?.remove(at: indexPath.row)
            // 删除cell
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            // sqlite存储--删除Table中相应row
            /// 考虑如何合并为一句，考虑将Item增加property（itemId, itemType...）
            try? db.delete(sql: "DELETE FROM \(item.itemType.typeString) WHERE Persistent_type = '\(item.persistentType.rawValue)' AND Item_type = '\(item.itemType.rawValue)' AND Item_id = '\(item.itemId)';")
            self.setEditing(false, animated: true)
        }
        
        // 配置工具栏item状态
        configureToolBarItems()
    }
    
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell: UITableViewCell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        // 将item type传到创建页面
        if segue.identifier == "ShowDetail" {
            // 显示详情页
            let itemDetailVC: ItemDetailTVC = segue.destination as! ItemDetailTVC
            let item = items![(indexPath?.row)!]
            if item is Login {
                let login: Login = item as! Login
                //itemDetailVC.item = item
                itemDetailVC.itemId = login.itemId
                itemDetailVC.persistentType = login.persistentType
                itemDetailVC.itemType = login.itemType
            } else if item is Note {
                let note: Note = item as! Note
                //itemDetailVC.item = item
                itemDetailVC.itemId = note.itemId
                itemDetailVC.persistentType = note.persistentType
                itemDetailVC.itemType = note.itemType
            } else if item is List {
                let list: List = item as! List
                //itemDetailVC.item = list
                itemDetailVC.itemId = list.itemId
                itemDetailVC.persistentType = list.persistentType
                itemDetailVC.itemType = list.itemType
            }
            
        }
        
    }
    
    
    // MARK: - Helper
    
    // show CreateItemVC
    func showCreateItemVC(withItemType itemType: FolderModel.ItemType) {
        // present create login VC
        let nav: UINavigationController = storyboard?.instantiateViewController(withIdentifier: "CreateItemVCNav") as! UINavigationController
        let createItemVC: CreateItemVC = nav.topViewController as! CreateItemVC
        createItemVC.persistentType = persistentType
        createItemVC.itemType = itemType//FolderModel.ItemType(rawValue: folderType.rawValue) // 通过folderType转换为itemType
        self.show(nav, sender: nil)
    }
    
    // show CreateNoteVC
    func showCreateNoteVC(withItemType itemType: FolderModel.ItemType) {
        // present create note VC
        let nav: UINavigationController = storyboard?.instantiateViewController(withIdentifier: "CreateNoteVCNav") as! UINavigationController
        let createNoteVC: CreateNoteVC = nav.topViewController as! CreateNoteVC
        createNoteVC.persistentType = persistentType
        createNoteVC.itemType = itemType//FolderModel.ItemType(rawValue: folderType.rawValue)
        self.show(nav, sender: nil)
    }
    
    // show action sheet
    func showActionSheet() {
        // 显示可以创建的类型
        let sheet = UIAlertController.init(title: "新建类型", message: "选择要创建的类型", preferredStyle: UIAlertControllerStyle.actionSheet)
        sheet.addAction(UIAlertAction.init(title: "登录信息", style: UIAlertActionStyle.default, handler: { (action) in
            // 处理Login操作
            print("Login action")
            self.showCreateItemVC(withItemType: FolderModel.ItemType.login)
        }))
        sheet.addAction(UIAlertAction.init(title: "备注信息", style: UIAlertActionStyle.default, handler: { (action) in
            // 处理Note操作
            print("Note action")
            self.showCreateNoteVC(withItemType: FolderModel.ItemType.note)
        }))
        sheet.addAction(UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil))
        
        // present modelly
        self.present(sheet, animated: true, completion: {
            print("")
        })
    }
    
    // 控制ToolBar中btn显示
    func configureToolBarItems() {
        if self.isEditing {
            addItem.isEnabled = false
        } else {
            addItem.isEnabled = true
        }
        
        // 配置navigationItem状态
        if items == nil || items.count == 0 {
            self.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
    }
    
    func queryData() {
        print("#ItemListTVC--Query db")
        /// 处理iCloud存储
        
        /// 处理IPHONE存储
        if folderType == FolderModel.FolderType.login {
            // Type--Login
            print("#Query Login type!")
            queryLogin()
        } else if folderType == FolderModel.FolderType.note {
            // 其他类型
            print("#Query Note types!")
            queryNote()
        } else if folderType == FolderModel.FolderType.all {
            print("#ALL")
            if db.masterContainTable(FolderModel.FolderType.login.typeString)! && db.masterContainTable(FolderModel.FolderType.note.typeString)! {
                // Union查询所有table（前提：Login、Note table同时存在，如果有一个不存在，会查不到数据）
                queryAll()
            } else {
                if db.masterContainTable(FolderModel.FolderType.login.typeString)! {
                    queryLogin()
                }
                if db.masterContainTable(FolderModel.FolderType.note.typeString)! {
                    queryNote()
                }
            }
        }
    }
    
    // 查询Table--Login
    func queryLogin() {
        print("#ItemListTVC--queryLogin")
        
        let loginSQL = "SELECT Item_id, Item_name, User_name, Password, Website, Note, Persistent_type, Item_type, Create_time, Update_time FROM Login WHERE Is_discard = 0 ORDER BY Update_time DESC;"   // 增加根据更新时间倒序排序
        if let loginResults = db.querySql(sql: loginSQL) {
            var tempItems = [Item]()
            for row in loginResults {
                let id: String = String(Int(row["Item_id"] as! Int32))
                let persistentType: FolderModel.PersistentType = FolderModel.PersistentType(rawValue: Int(row["Persistent_type"] as! Int32))! 
                let itemType: FolderModel.ItemType = FolderModel.ItemType(rawValue: Int(row["Item_type"] as! Int32))!
                let createTime: String = row["Create_time"] as! String
                let updateTime: String = row["Update_time"] as! String
                
                let login: Login = Login.init(itemId: id, itemName: row["Item_name"] as! String, userName: row["User_name"] as! String, password: row["Password"] as! String, website: row["Website"] as! String, note: row["Note"] as! String, persistentType: persistentType, itemType: itemType, folderType: FolderModel.FolderType.login, createTime: createTime, updateTime: updateTime)
                tempItems.append(login)
            }
            items = tempItems
        } else {
            print("#Table Login has no items!")
        }
    }
    
    // 查询Table--Note
    func queryNote() {
        print("#ItemListTVC--queryNote")
        
        let noteSQL = "SELECT Item_id, Item_name, User_name, Note, Persistent_type, Item_type, Create_time, Update_time FROM Note WHERE Is_discard = 0 ORDER BY Update_time DESC;"   // 增加根据更新时间倒序排序
        if let noteResults = db.querySql(sql: noteSQL) {
            var tempItems = [Item]()
            for row in noteResults {
                let id: String = String(Int(row["Item_id"] as! Int32))
                let itemName: String = row["Item_name"] as! String
                let userName: String = row["User_name"] as! String
                let note: String = row["Note"] as! String
                let persistentType: FolderModel.PersistentType = FolderModel.PersistentType(rawValue: Int(row["Persistent_type"] as! Int32))!
                let itemType: FolderModel.ItemType = FolderModel.ItemType(rawValue: Int(row["Item_type"] as! Int32))!
                let createTime: String = row["Create_time"] as! String
                let updateTime: String = row["Update_time"] as! String
                
                let noteModel: Note = Note.init(itemId: id, itemName: itemName, userName: userName, note: note, persistentType: persistentType, itemType: itemType, folderType: FolderModel.FolderType.note, createTime: createTime, updateTime: updateTime)
                tempItems.append(noteModel)
            }
            items = tempItems
        } else {
            print("#Table Note has no items!")
        }
    }

    /// 说明：如果每个页面都自己查询db，则使用此方法即可，不用分三个方法单独查，统一使用List model用于cell显示数据
    /// 
    // 查询Table--Login、Note
    func queryAll() {
        print("#ItemListTVC--queryAll")
        
        // Union查询所有table（前提：Login、Note table同时存在，如果有一个不存在，会查不到数据）
        let unionAllSQL = """
            SELECT Item_id, Item_name, User_name, Note, Persistent_type, Item_type, Update_time FROM Login
            UNION
            SELECT Item_id, Item_name, User_name, Note, Persistent_type, Item_type, Update_time FROM Note
            ORDER BY Update_time DESC;
        """
        
        if let allResults = db.querySql(sql: unionAllSQL) {
            var tempItems = [Item]()
            for row in allResults {
                let id: String = String(Int(row["Item_id"] as! Int32))
                let itemName: String = row["Item_name"] as! String
                let userName: String = row["User_name"] as! String
                let note: String = row["Note"] as! String
                let persistentType: FolderModel.PersistentType = FolderModel.PersistentType(rawValue: Int(row["Persistent_type"] as! Int32))!
                let itemType: FolderModel.ItemType = FolderModel.ItemType(rawValue: Int(row["Item_type"] as! Int32))!
                
                let listModel: List = List.init(itemId: id, itemName: itemName, userName: userName, note: note, persistentType: persistentType, itemType: itemType, folderType: FolderModel.FolderType.all)
                tempItems.append(listModel)
            }
            items = tempItems
        } else {
            print("#Table all has no items!")
        }
        
        
    
    }
}









