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
/// 3、点击copy怎么将cell的内容复制到Pasteboard上？？？（获取cell，将内容设置给Pasteboard实例）
/// 4、点击edit button显示编辑页面
/// 5、显示备注信息时，需要显示完全，因此，需要自定义一个cell
/// 6、点击编辑，不要显示tableView编辑效果，转场到创建密码页面
/// 7、使用系统cell-subtitle，cell的图像怎么设置大一点？？？
///
///




import UIKit

class ItemDetailTVC: UITableViewController {
    
    static let cellIdentifier = "ItemDetailCell"
    static let noteCellIdentifier = "NoteCell"
    static let createItemVCIdentifier = "CreateItemVC"
    
    // Properties
    var db: SQLiteDatabase!
    var item: Item!
    //var itemType: String!
    var itemId: String!
    var persistentType: FolderModel.PersistentType!
    var itemType: FolderModel.ItemType!
    var updateCellOfListVC: ((Item) -> ())!     // 定义closure用于更新ItemListVC的cell，反向传值

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        /// 对于UITableViewController来说，注释掉这一句，显示Edit button，同时自带编辑功能；
        /// 如果复写了setEditing(_:)方法，则编辑功能消失，需要自己实现
        ///
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Detail"
        
        // register NoteCell
        self.tableView.register(UINib.init(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: ItemDetailTVC.noteCellIdentifier)
        
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
        print("#ItemDetailTVC--viewWillAppear")
        print("item: \(item)")
        print("itemId: \(itemId)")
        print("persistentType: \(persistentType)")
        print("itemType: \(itemType)")
        
        // 进入详情页面，隐藏ToolBar
        self.navigationController?.isToolbarHidden = true
        // query data
        queryData()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("#ItemDetailTVC--viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("#ItemDetailTVC--viewWillDisappear")
        // 离开详情页面，显示ToolBar
        self.navigationController?.isToolbarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 发送通知--传递new item model
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PassBackItemFromDetail"), object: self, userInfo: ["item": self.item])
        // closure 传值
        //self.updateCellOfListVC(self.item)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("#setEditing")
        
        if itemType == FolderModel.ItemType.login {
            // 跳转到CreateItemVC
            // 调起创建秘密页面、动画为fade in out
            // 直接present CreateItemVC，不显示导航栏
            //        let createItemVC: CreateItemVC = self.storyboard?.instantiateViewController(withIdentifier: ItemDetailTVC.createItemVCIdentifier) as! CreateItemVC
            //        createItemVC.modalTransitionStyle = .crossDissolve
            //        createItemVC.modalPresentationStyle = .overFullScreen
            //        self.present(createItemVC, animated: true, completion: nil)
            
            // CreateItemVC嵌入到navigationController，present时，VC是nav，才会带导航栏
            let createItemVCNav = self.storyboard?.instantiateViewController(withIdentifier: "CreateItemVCNav")
            // 传值
            let createItemVC: CreateItemVC = ((createItemVCNav as! UINavigationController).topViewController as? CreateItemVC)!
            createItemVC.item = item
            createItemVC.persistentType = persistentType
            createItemVC.itemType = itemType
            createItemVC.passBackNewItemDetail = { login in
                // 获取返回值，更新table
                self.item = login
                self.tableView.reloadData()
            }
            //
            createItemVCNav?.modalTransitionStyle = .crossDissolve
            createItemVCNav?.modalPresentationStyle = .fullScreen
            self.present(createItemVCNav!, animated: true, completion: nil)
        } else if itemType == FolderModel.ItemType.note {
            // 跳转到CreateNoteVC
            let nav: UINavigationController = storyboard?.instantiateViewController(withIdentifier: "CreateNoteVCNav") as! UINavigationController
            let createNoteVC: CreateNoteVC = nav.topViewController as! CreateNoteVC
            createNoteVC.note = item as! Note
            createNoteVC.persistentType = persistentType
            createNoteVC.itemType = itemType
            createNoteVC.passBackNewItemDetail = { note in
                self.item = note
                self.tableView.reloadData()
            }
            //self.show(nav, sender: nil)
            nav.modalTransitionStyle = .crossDissolve
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - UIResponder
    
    // 1.0
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    // 1.2
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
        //return 4
        if itemType == FolderModel.ItemType.login {
            return 4
        } else if itemType == FolderModel.ItemType.note {
            return 2
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if itemType == FolderModel.ItemType.login {
            switch section {
            case 0: return 1
            case 1: return 2
            case 2: return 1
            case 3: return 1
            default:
                return 0
            }
        } else if itemType == FolderModel.ItemType.note {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemDetailTVC.cellIdentifier, for: indexPath)
        
        /// 处理Type--Login
        if let item = item {
            if item is Login {
                // 处理Login
                let login = item as! Login
                if indexPath.section == 0 {
                    cell.textLabel?.text = login.itemName
                    cell.detailTextLabel?.attributedText = NSAttributedString(string: "登录信息", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray]) //attributedText("登录信息")
                    cell.imageView?.image = UIImage(named: "note create40")
                    cell.imageView?.contentMode = .scaleToFill
                } else if indexPath.section == 1{
                    if indexPath.row == 0 {
                        cell.textLabel?.attributedText = attributedText("用户名")
                        cell.detailTextLabel?.text = login.userName
                    } else if indexPath.row == 1 {
                        cell.textLabel?.attributedText = attributedText("密码")
                        cell.detailTextLabel?.text = login.password
                    }
                } else if indexPath.section == 2 {
                    cell.textLabel?.attributedText = attributedText("网站")
                    cell.detailTextLabel?.text = login.website.count > 0 ? login.website : "http://example.com"
                } else if indexPath.section == 3 {
                    //            cell.textLabel?.attributedText = attributedText("备注")
                    //            cell.detailTextLabel?.text = (login.note == "") ? "在这添加备注": login.note
                    // 使用自定义cell来展示备注信息
                    let noteCell: NoteCell = tableView.dequeueReusableCell(withIdentifier: ItemDetailTVC.noteCellIdentifier) as! NoteCell
                    noteCell.customTextLabel.attributedText = attributedText("备注")
                    noteCell.customDetailTextLabel.text = (login.note == "") ? "在这添加备注": login.note
                    //noteCell.customDetailTextLabel.tintColor = UIColor.lightGray
                    return noteCell
                }
            } else if item is Note {
                // 处理Note
                let note = item as! Note
                if indexPath.section == 0 {
                    cell.textLabel?.text = note.itemName
                    cell.detailTextLabel?.text = note.userName
                    cell.imageView?.image = UIImage(named: "note create40")
                } else if indexPath.section == 1 {
                    // 使用自定义cell来展示备注信息
                    let noteCell: NoteCell = tableView.dequeueReusableCell(withIdentifier: ItemDetailTVC.noteCellIdentifier) as! NoteCell
                    noteCell.customTextLabel.attributedText = attributedText("备注")
                    noteCell.customDetailTextLabel.text = (note.note == "") ? "在这添加备注": note.note
                    //noteCell.customDetailTextLabel.tintColor = UIColor.lightGray
                    return noteCell
                }
            }
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 问题：设置为0，不起作用？？？
        //return 0.0
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80.0
        }
        return UITableViewAutomaticDimension
    }
 

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("#ItemDetailTVC--didSelectRowAt")
        
        if let cell = tableView.cellForRow(at: indexPath), self.isFirstResponder {
            // 1.1 show edit menu
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
    
    @objc func handleCopyAction(_ sender: Any) {
        print("Copy")
        var copyString = ""
        // 找到点击的cell
        // 注意：iOS11之后，table view的UI层级发生了变化
        //let subviews = self.tableView.subviews
        let subviews: [Any]!
        if #available(iOS 11.0, *) {
            subviews = self.tableView.subviews
        } else {
            subviews = self.tableView.subviews[0].subviews
        }
        for view in subviews {
            if let cell = view as? UITableViewCell, cell.isSelected == true {
                if cell is NoteCell {
                    copyString = ((cell as? NoteCell)?.customDetailTextLabel.text)!
                } else {
                    if cell.detailTextLabel?.text == "登录信息" {
                        copyString = (cell.textLabel?.text)!
                    } else {
                        copyString = (cell.detailTextLabel?.text)!
                    }
                }
            }
        }
        
        // 创建pasteboard，将cell内容写入
        let gpBoard = UIPasteboard.general
        gpBoard.string = copyString
    }
    
    @objc func handleBigWordAction(_ sender: Any) {
        print("Big word")
    }
    
    // 创建attributed string
    func attributedText(_ string: String) -> NSAttributedString {
        let attributes: [NSAttributedStringKey: Any]!
        if #available(iOS 11.0, *) {
            attributes = [NSAttributedStringKey.foregroundColor: UIColor.init(named: "DodgerBlue")!]
        } else {
            // Fallback on earlier versions
            attributes = [NSAttributedStringKey.foregroundColor: UIColor.blue]
        }
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        return attributedString
    }

    
    // 将处理cell显示的代码抽象成方法？？？
    func showCell(_ cell: UITableViewCell, indexPath: IndexPath, item: Item) {
        if item is Login {
            //
            
        } else if item is Note {
            //
            
        }
    }
    
    
    // query data
    func queryData() {
        if let pT = persistentType {
            if pT == FolderModel.PersistentType.iphone {
                // 处理存储类型是--iphone
                if let iT = itemType {
                    if iT == FolderModel.ItemType.login {
                        // Query--Login
                        self.queryLoginData()
                    } else if iT == FolderModel.ItemType.note {
                        // Query--Note
                        self.queryNoteData()
                    }
                }
            } else {
                // 处理存储类型是--others
            }
        }
    }
    
    // Query--Login
    func queryLoginData() {
        
        /// 注意：变量如果是optional，在SQL里要unwraped，否则SQL执行有问题
        let loginSQL = "SELECT * FROM Login WHERE Persistent_type = '\(persistentType.rawValue)' AND Item_type = '\(persistentType.rawValue)' AND Item_id = '\(self.itemId!)';"
        if let loginResults = db.querySql(sql: loginSQL) {
            if let loginResult = loginResults.first {
                let id: String = String(Int(loginResult["Item_id"] as! Int32))
                let iN: String = loginResult["Item_name"] as! String
                let uN: String = loginResult["User_name"] as! String
                let pW: String = loginResult["Password"] as! String
                let wS: String = loginResult["Website"] as! String
                let note: String = loginResult["Note"] as! String
                let pT: FolderModel.PersistentType = FolderModel.PersistentType(rawValue: Int(loginResult["Persistent_type"] as! Int32))!
                let iT: FolderModel.ItemType = FolderModel.ItemType(rawValue: Int(loginResult["Item_type"] as! Int32))!
                
                let login: Login = Login(itemId: id, itemName: iN, userName: uN, password: pW, website: wS, note: note, persistentType: pT, itemType: iT, folderType: FolderModel.FolderType.login)
                self.item = login
            }
        } else {
            print("#Table Login has no items!")
        }
    }
    
    // Query--Note
    func queryNoteData() {
        
        let noteSQL = "SELECT * FROM Note WHERE Item_id = '\(self.itemId!)';"
        if let noteResults = db.querySql(sql: noteSQL) {
            if let noteResult = noteResults.first {
                let id: String = String(Int(noteResult["Item_id"] as! Int32))
                let iN: String = noteResult["Item_name"] as! String
                let uN: String = noteResult["User_name"] as! String
                let note: String = noteResult["Note"] as! String
                let pT: FolderModel.PersistentType = FolderModel.PersistentType(rawValue: Int(noteResult["Persistent_type"] as! Int32))!
                let iT: FolderModel.ItemType = FolderModel.ItemType(rawValue: Int(noteResult["Item_type"] as! Int32))!

                let noteModel: Note = Note(itemId: id, itemName: iN, userName: uN, note: note, persistentType: pT, itemType: iT, folderType: FolderModel.FolderType.note)
                self.item = noteModel
            }
        } else {
            print("#Table Login has no items!")
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



