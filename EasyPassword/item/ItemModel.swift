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
    var folderType: FolderModel.FolderType { get set }          // 增加folderType用来判断是来自于哪个folder
    //var image: String { get set }
}



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
    var folderType: FolderModel.FolderType
    
    //var image: String = "login29"
    
    init(itemId: String, itemName: String, userName: String, password: String, website: String, note: String, persistentType: FolderModel.PersistentType, itemType: FolderModel.ItemType, folderType: FolderModel.FolderType) {
        self.itemId = itemId
        self.itemName = itemName
        self.userName = userName
        self.password = password
        self.website = website
        self.note = note
        self.persistentType = persistentType
        self.itemType = itemType
        self.folderType = folderType
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
    var folderType: FolderModel.FolderType
    
    //var image: String = "note29"
    
    init(itemId: String, itemName: String, userName: String, note: String, persistentType: FolderModel.PersistentType, itemType: FolderModel.ItemType, folderType: FolderModel.FolderType) {
        self.itemId = itemId
        self.itemName = itemName
        self.userName = userName
        self.note = note
        self.persistentType = persistentType
        self.itemType = itemType
        self.folderType = folderType
    }
}

// 信用卡模型

// 电影卡模型

// 其他模型

// All
struct List: Item {
    //var image: String
    
    var itemId: String
    var itemName: String
    var userName: String
    var note: String        // 新增兼容Note类型在cell上detailText展示
    var persistentType: FolderModel.PersistentType
    var itemType: FolderModel.ItemType
    var folderType: FolderModel.FolderType
    
    init(itemId: String, itemName: String, userName: String, note: String, persistentType: FolderModel.PersistentType, itemType: FolderModel.ItemType, folderType: FolderModel.FolderType) {
        self.itemId = itemId
        self.itemName = itemName
        self.userName = userName
        self.note = note
        self.persistentType = persistentType
        self.itemType = itemType
        self.folderType = folderType

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






