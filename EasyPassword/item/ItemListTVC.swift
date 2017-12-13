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
/// 5、search bar使用？？？
///
///
///
///




import UIKit

class ItemListTVC: UITableViewController {
    
    var titleName: String = ""  // 用于传值
    var items: [Item]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("#ItemListTVC--viewWillAppear")
        // 接收传值，显示title
        self.title = titleName
        print("items: \(String(describing: items))")
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
        }
        
    }
    

}
