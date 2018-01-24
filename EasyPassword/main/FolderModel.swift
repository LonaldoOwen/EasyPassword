//
//  FolderModel.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/29.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// FolderModel
/// 功能：主页面的data model，用于显示文件夹数据
/// 1、使用plist时，需要返回所有结果
/// 2、使用db，则model设置需要的信息即可，根据需要从db查询
///
///

/*
 var persistent: String // 持久化方式
 var folderName: String // 文件夹name
 var itmes: [ItemModel] // 条目

 */

import Foundation

// MARK: - 适用plist存储的model
class FolderModel {
    
    // 可以定义一个enum来处理相关操作()
    enum PersistentType: Int {
        case iphone = 1
        case icloud = 2
        
        var typeString: String {
            switch self {
            case .iphone:
                return "IPHONE"
            case .icloud:
                return "ICLOUD"
            }
        }
    }
    
    enum ItemType: Int {
        case all = 0
        case login = 1
        case note = 2
        
        var typeString: String {
            switch self {
            case .all:
                return "All Item Type on IPHONE"
            case .login:
                return "Login"
            case .note:
                return "Note"
            }
        }
        
        var imageName: String {
            switch self {
            case .all:
                return "Item all2"
            case .login:
                return "login"
            case .note:
                return "note29"
            }
        }
    }
    
    
    // plist存储--data model
    /*
    var persistentType: String
    var itemType: String
    var items: [Item]
    
    init(persistentType: String, itemType: String, items: [Item]?) {
        self.persistentType = persistentType
        self.itemType = itemType
        self.items = items != nil ? items! : [Item]()
    }
    */
    
    // sqlite db存储--data model
    var persistentType: PersistentType
    var itemType: ItemType
    var count: String
    
    init(persistentType: PersistentType, itemType: ItemType, count: String) {
        self.persistentType = persistentType
        self.itemType = itemType
        self.count = count
    }
}


// MARK: - 适用sqlite db存储的model






