//
//  ItemModel.swift
//  EasyPassword
//
//  Created by owen on 05/12/2017.
//  Copyright © 2017 libowen. All rights reserved.
//
///  ItemModel
/// 功能：item list数据模型
/// 1、model为cell需要显示的信息，可以根据db查询结果，取需要的即可
///
///

import Foundation

// MARK: - 类型通用协议
protocol Item {
    var itemId: String { get set }
    var persistentType: FolderModel.PersistentType { get set }
    var itemType: FolderModel.ItemType { get set }
}

//enum ItemType: Int {
//    case all = 0
//    case login = 1
//    case note = 2
//}


// MARK: - 登录模型
struct Login: Item {
    
    var itemId: String
    var itemName: String
    var userName: String     // 非空
    var password: String     // 非空
    var website: String     //
    var note: String        //
    //var updateTime: String
    var persistentType: FolderModel.PersistentType
    var itemType: FolderModel.ItemType
    
    init(itemId: String, itemName: String, userName: String, password: String, website: String, note: String, persistentType: FolderModel.PersistentType, itemType: FolderModel.ItemType) {
        self.itemId = itemId
        self.itemName = itemName
        self.userName = userName
        self.password = password
        self.website = website
        self.note = note
        self.persistentType = persistentType
        self.itemType = itemType
        
    }

}

extension Login: Equatable {
    static func ==(lhs: Login, rhs: Login) -> Bool {
        return lhs.itemId == rhs.itemId && lhs.itemName == rhs.itemName && lhs.userName == rhs.userName && lhs.password == rhs.password && lhs.website == rhs.website && lhs.note == rhs.note
    }
}


// Note
struct Note: Item {
    var itemId: String
    var itemName: String
    var userName: String
    var note: String
    var persistentType: FolderModel.PersistentType
    var itemType: FolderModel.ItemType
    
    init(itemId: String, itemName: String, userName: String, note: String, persistentType: FolderModel.PersistentType, itemType: FolderModel.ItemType) {
        self.itemId = itemId
        self.itemName = itemName
        self.userName = userName
        self.note = note
        self.persistentType = persistentType
        self.itemType = itemType
    }
}

// 信用卡模型

// 电影卡模型

// 其他模型

// All
struct List: Item {
    var itemId: String
    var itemName: String
    var userName: String
    var persistentType: FolderModel.PersistentType
    var itemType: FolderModel.ItemType
    
    init(itemId: String, itemName: String, userName: String, persistentType: FolderModel.PersistentType, itemType: FolderModel.ItemType) {
        self.itemId = itemId
        self.itemName = itemName
        self.userName = userName
        self.persistentType = persistentType
        self.itemType = itemType
    }
}

struct PasswordHistory {
    var id: String
    var itemId: String
    var password: String
    var createTime: String
    
    init(id: String, itemId: String, password: String, createTime: String) {
        self.id = id
        self.itemId = itemId
        self.password = password
        self.createTime = createTime
    }
}






