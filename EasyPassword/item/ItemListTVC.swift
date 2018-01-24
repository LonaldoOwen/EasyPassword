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
/// 6、缺少删除cell的功能、多选、移动到其他文件夹（）
/// 7、从all进入，查询所有table，显示在一起，按Update_time倒序排列（）
///
///




import UIKit

class ItemListTVC: UITableViewController {
    
    var itemType: String = ""       // 用于传值
    var persistentType: String = "" // 用于传值
    var items: [Item]?
    var db: SQLiteDatabase!

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
        // 接收传值，显示title
        self.title = itemType
        // 如果使用db，根据itemType查询db，显示tableView
        queryData()
        // 刷新UI
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func handleAddAction(_ sender: UIBarButtonItem) {
        // 调起创建新itemVC
        //PlistHelper.insert(["username": "name", "password": "pass", "website": ".com", "note": "note..."], ofPersistentType: "MyIPHONE", itemType: titleName)
        //
        
        //
        if itemType == "Login" {
            // present create login VC
        } else if itemType == "Note" {
            // present create note VC
        } else if itemType == "All" {
            // present select type action sheet
        }
    }
    
    // 收起创建item VC
    @IBAction func close(_ segue: UIStoryboardSegue) {
        
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
            let item: Login = items[indexPath.row] as! Login
            cell.textLabel?.text = item.itemName
            cell.detailTextLabel?.text = item.userName
            cell.imageView?.image = UIImage.init(named: "note36")
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
            // plist存储--删除对应plist中数据
            //PlistHelper.delete(itemModel: item, ofPersistentType: "MyIPHONE", itemType: itemType)
            // sqlite存储--删除Table中相应row
            // 这个考虑一下，是不是不真正删除，只修改Is_discard为1？？？
            if itemType == "Login" {
                // 处理Type--Login
                let deleteSQL = "DELETE FROM Login WHERE Item_id = '\((item as! Login).itemId)';"
                try? db.delete(sql: deleteSQL)
                // 删除完cell后，取消编辑状态
                self.setEditing(false, animated: true)
            }
            // Other type goes there
        }
    }
    
    
    // MARK: - Table view delegate
//    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        
        // 将item type传到创建页面
        if segue.identifier == "PresentCreate" {
            // 创建新item
            let createItemVC: CreateItemVC = (segue.destination as! UINavigationController).topViewController as! CreateItemVC
            createItemVC.itemType = self.title
            // 调用closure，更新UI
            createItemVC.reloadItemListVC = { item in
//                self.items?.insert(item, at: 0)
//                self.tableView.reloadData()
                print("#Update list")
            }
        } else if segue.identifier == "ShowDetail" {
            // 显示详情页
            //let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)
            let itemDetailVC: ItemDetailTVC = segue.destination as! ItemDetailTVC
            itemDetailVC.item = items![(indexPath?.row)!]
            itemDetailVC.itemType = itemType
            // 设置closure，更新cell
            itemDetailVC.updateCellOfListVC = { item in
                self.items![(indexPath?.row)!] = item
                self.tableView.reloadRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
            }
        }
        
    }
    
    
    // MARK: - Helper
    
    func queryData() {
        print("#ItemListTVC--Query db")
        /// 处理iCloud存储
        
        /// 处理IPHONE存储
        if itemType == "Login" {
            // Type--Login
            print("#Query Login type!")
            queryLogin()
        } else {
            // 其他类型
            print("#Query other types!")
        }
    }
    
    // 查询Table--Login
    func queryLogin() {
        //let loginSQL = "SELECT Item_id, Item_name, User_name, Password, Website, Note FROM Login WHERE Is_discard = 0;"
        let loginSQL = "SELECT Item_id, Item_name, User_name, Password, Website, Note FROM Login WHERE Is_discard = 0 ORDER BY Create_time DESC;"   // 增加根据更新时间倒序排序
        if let loginResults = db.querySql(sql: loginSQL) {
            var tempItems = [Item]()
            for row in loginResults {
                let id: String = String(Int(row["Item_id"] as! Int32))
                let login: Login = Login.init(itemId: id, itemName: row["Item_name"] as! String, userName: row["User_name"] as! String, password: row["Password"] as! String, website: row["Website"] as! String, note: row["Note"] as! String)
                tempItems.append(login)
            }
            items = tempItems
        } else {
            print("#Table Login has no items!")
        }
    }

}
