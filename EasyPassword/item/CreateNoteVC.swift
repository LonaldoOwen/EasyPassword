//
//  CreateNoteVC.swift
//  EasyPassword
//
//  Created by libowen on 2018/1/24.
//  Copyright © 2018年 libowen. All rights reserved.
//
/// CreateNoteVC.swift
/// 功能：
/// 1、创建Note
/// 2、当文本过长时，达到键盘位置，向上滚动scrollview（）
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
    
    var db: SQLiteDatabase!
    //var item: Item!
    var itemType: FolderModel.ItemType!
    var persistentType: FolderModel.PersistentType!
    var note: Note!
    var passBackNewItemDetail: ((Item) -> ())!  // 定义closure用于刷新ItemDetailVC
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture))
        noteContent.addGestureRecognizer(tapGesture)
        
        // 注册keyboard通知
        registerForKeyboardNotifications()
        // 监听textField
        itemName.addTarget(self, action: #selector(handleTextFieldTextChanged), for: .editingChanged)
        
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
        print("#CreateNoteVC--viewWillAppear")
        // 注册UIApplicationDidBecomeActive通知
        //NotificationCenter.default.addObserver(self, selector: #selector(handleObserverUIApplicationDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
        
        //
        if let note = note {
            // note不为nil时，是从编辑页面跳转的
            itemName.text = note.itemName
            noteLabel.text = note.note
        }
        //
        configureNavigationItemsStatus()
        
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
            /// 编辑模式 -- 更新item
            print(note)
            // 使用sqlite db存储
            if noteLabel.text != note.note || itemName.text != note.itemName {
                // Update item
                let updateNoteSQL = "UPDATE Note SET Item_name = '\(itemName.text!)', Note = '\(noteLabel.text!)', Update_time = '\(dateStr)' WHERE Item_id = '\(note.itemId)';"
                //try? db.update(sql: updateNoteSQL)
                if try! db.update(sql: updateNoteSQL) {
                    print("更新Note item成功！")
                } else {
                    print("更新Note item出错！")
                }
            }
            
            // 收起VC
            self.dismiss(animated: true, completion: {
                // 回传值new item
                //self.passBackNewItemDetail(self.note)
            })
        } else {
            /// 非编辑模式 -- 创建新item
            if itemType == FolderModel.ItemType.note {
                // 查询sqlite_master表中是否包含Note表，没有先创建
                print("#如果尚未创建Note table，先创建")
                // 如果尚未创建Note table，先创建
                let dbTableCount = self.db.numberOfRowsInTable("sqlite_master")
                if dbTableCount > 0 {
                    // db不为空
                    if self.db.masterContainTable("Note")! {
                        // 执行2
                        print("跳转到list页面-->CreateVC页面。")
                    } else {
                        // 执行1
                        try? self.db.createTable(table: Note.self)
                    }
                } else {
                    // db为空，直接创建Note table
                    try? self.db.createTable(table: Note.self)
                }
                
                // 插入db
                // 创建新note时，设置Update_time等于Create_time
                let insertNoteSQL = "INSERT INTO Note (Item_name, User_name, Note, Item_type, Persistent_type, Create_time, Update_time, Is_discard) VALUES ('\(itemName.text!)', '', '\(noteLabel.text ?? "")', '\(itemType.rawValue)', '\(persistentType.rawValue)', '\(dateStr)', '\(dateStr)', '0');"
                try? db.insert(sql: insertNoteSQL)
            } else {
                print("Handle other item types!")
                // 其他类型在这里处理
            }
            
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
    
    @objc func handleObserverUIApplicationDidBecomeActive(_ notification: Notification) {
        //
        print("#handleObserverUIApplicationDidBecomeActive: \(notification)")
        //let app: UIApplication = notification.object as! UIApplication
        self.showMasterPasswordVC()
    }
    
    
    // MARK: -- Helper
    
    // Call this method somewhere in your view controller setup code.
    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateItemVC.keyboardWillBeHidden(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // 处理textField输入变化
    @objc func handleTextFieldTextChanged(_ textField: UITextField) {
        print("#handleTextFieldTextChanged")
        // 当前textField的text不为空，enable saveButton
        if (textField.text?.isEmpty)! {
            saveBtn.isEnabled = false
        } else {
            saveBtn.isEnabled = true
        }
    }
    
    // Called when the UIKeyboardDidShowNotification is sent.
    @objc
    func keyboardWasShown(_ aNotification: Notification) {
        //        let info = aNotification.userInfo
        //        let keyboardBounds = (info![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //        let keyboardSize = keyboardBounds.size
        print("#keyboardWasShown")
    }
    
    // Called when the UIKeyboardWillHideNotification is sent
    @objc
    func keyboardWillBeHidden(_ aNotification: Notification) {
        print("#keyboardWillBeHidden")
    }
    
    // 配置navigationItem 状态
    func configureNavigationItemsStatus() {
        if (itemName.text?.isEmpty)! {
            saveBtn.isEnabled = false
        } else {
            saveBtn.isEnabled = true
        }
    }

    //
//    func showMasterPasswordVC() {
//        //let storyBoard: UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let mpVC: MasterPasswordVC = storyboard!.instantiateViewController(withIdentifier: "MasterPasswordVC") as! MasterPasswordVC
//        mpVC.modalTransitionStyle = .crossDissolve
//        mpVC.modalPresentationStyle = .fullScreen
//        self.present(mpVC, animated: true, completion: nil)
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
