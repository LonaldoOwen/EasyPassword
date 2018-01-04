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
///
///
///




import UIKit

class ItemDetailTVC: UITableViewController {
    
    static let cellIdentifier = "ItemDetailCell"
    static let noteCellIdentifier = "NoteCell"
    static let createItemVCIdentifier = "CreateItemVC"
    
    // Properties
    var item: Item!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        /// 对于UITableViewController来说，注释掉这一句，显示Edit button，同时自带编辑功能；
        /// 如果复写了setEditing(_:)方法，则编辑功能消失，需要自己实现
        ///
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // register NoteCell
        self.tableView.register(UINib.init(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: ItemDetailTVC.noteCellIdentifier)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 进入详情页面，隐藏ToolBar
        self.navigationController?.isToolbarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 离开详情页面，显示ToolBar
        self.navigationController?.isToolbarHidden = false
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        print("#setEditing")
        // 调起创建秘密页面、动画为fade in out
        // 直接present CreateItemVC，不显示导航栏
//        let createItemVC: CreateItemVC = self.storyboard?.instantiateViewController(withIdentifier: ItemDetailTVC.createItemVCIdentifier) as! CreateItemVC
//        createItemVC.modalTransitionStyle = .crossDissolve
//        createItemVC.modalPresentationStyle = .overFullScreen
//        self.present(createItemVC, animated: true, completion: nil)
        
        // CreateItemVC嵌入到navigationController，present时，VC是nav，才会带导航栏
        let createItemVCNav = self.storyboard?.instantiateViewController(withIdentifier: "CreateItemVCNav")
        createItemVCNav?.modalTransitionStyle = .crossDissolve
        createItemVCNav?.modalPresentationStyle = .overFullScreen
        self.present(createItemVCNav!, animated: true, completion: nil)
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
        return 4
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
            cell.detailTextLabel?.attributedText = NSAttributedString(string: "登录信息", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray]) //attributedText("登录信息")
            cell.imageView?.image = UIImage(named: "国内游")
        } else if indexPath.section == 1{
            if indexPath.row == 0 {
                cell.textLabel?.attributedText = attributedText("用户名")
                cell.detailTextLabel?.text = login.username
            } else if indexPath.row == 1 {
                cell.textLabel?.attributedText = attributedText("密码")
                cell.detailTextLabel?.text = login.password
            }
        } else if indexPath.section == 2 {
            cell.textLabel?.attributedText = attributedText("网站")
            cell.detailTextLabel?.text = login.website
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
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 问题：设置为0，不起作用？？？
        //return 0.0
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100.0
        }
        return UITableViewAutomaticDimension
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



