//
//  CreateNoteVC.swift
//  EasyPassword
//
//  Created by libowen on 2018/1/24.
//  Copyright © 2018年 libowen. All rights reserved.
//
/// CreateNoteVC.swift
/// 功能：
/// 1、
/// 2、
///
///
///
///
///



import UIKit

class CreateNoteVC: UIViewController {
    
    
    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteContent: UIView!
    
    var itemType: FolderModel.ItemType!
    var persistentType: FolderModel.PersistentType!
    var note: Note!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture))
        noteContent.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func handleCancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handleSaveAction(_ sender: Any) {
        // 保存编辑内容，写入db
        // 时间、日期格式
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = Date()
        let dateStr = formatter.string(from: now)
        
        // 存储item
        if let note = note {
            // 编辑模式，更新item，先删除旧item，再插入新item
            print(note)
            // 使用sqlite db存储
            // Update item
            
            // 收起VC
            self.dismiss(animated: true, completion: {
                // 回传值new item
                //self.passBackNewItemDetail(self.login)
            })
        } else {
            // 非编辑模式，创建新item
            if itemType.typeString == "Note" {
                // 查询Note表中，最后一行的id
                // 插入db
                // 创建新note时，设置Update_time等于Create_time
                let insertNoteSQL = "INSERT INTO Note (Item_name, User_name, Note, Item_type, Persistent_type, Create_time, Update_time, Is_discard) VALUES ('', '', '', '\(itemType)', '\(persistentType)', 'dateStr', 'dateStr', '0');"
                                
            } else {
                print("Handle other item types!")
                // 其他类型在这里处理
            }
            
            // 更新item list页面（选择方式？？？）
            //reloadItemListVC(login)
            // 收起VC
            self.dismiss(animated: true, completion: {
                // 更新item list页面；（如果使用db，则不需要此步了）
            })
        }
    }
    
    @objc func handleTapGesture(_ recognizier: UIGestureRecognizer) {
        print("Tap...")
        // 点击跳转到text编辑页面
        let addNoteVC: AddNoteVC = (storyboard?.instantiateViewController(withIdentifier:"AddNoteVC"))! as! AddNoteVC
        //
        addNoteVC.note = noteLabel.text
        addNoteVC.passBackNote = { note in
            print("#note: \(note)")
            self.noteLabel.text = note
        }
        self.show(addNoteVC, sender: nil)
        
        // 点击显示edit menu
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
