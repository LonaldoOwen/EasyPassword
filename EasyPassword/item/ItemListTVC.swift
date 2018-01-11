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
/// 5、search bar使用？？？（）
/// 6、缺少删除cell的功能、多选、移动到其他文件夹（）
///
///
///




import UIKit

class ItemListTVC: UITableViewController {
    
    var itemType: String = ""  // 用于传值
    var items: [Item]?          // 用于传值

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // 注册通知--用于接收详情页面传来item model（未用到）
        //NotificationCenter.default.addObserver(self, selector: #selector(handlePassBackItemNotification), name: NSNotification.Name(rawValue: "PassBackItemFromDetail"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("#ItemListTVC--viewWillAppear")
        // 接收传值，显示title
        self.title = itemType
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
        return (items?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)

        // Configure the cell...
        let item: Login = items?[indexPath.row] as! Login
        cell.textLabel?.text = item.itemname
        cell.detailTextLabel?.text = item.username

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
            // 删除对应plist中数据
            //PlistHelper.delete(itemModel: item, ofPersistentType: "MyIPHONE", itemType: titleName)
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
            let createItemVC: CreateItemVC = (segue.destination as! UINavigationController).topViewController as! CreateItemVC
            createItemVC.itemType = self.title
            // 调用closure，更新UI
            createItemVC.reloadItemListVC = { item in
                self.items?.insert(item, at: 0)
                self.tableView.reloadData()
            }
        } else if segue.identifier == "ShowDetail" {
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
    

}
