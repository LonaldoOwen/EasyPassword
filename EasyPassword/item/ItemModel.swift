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
protocol Item { }


// MARK: - 登录模型
struct Login: Item {
    
    var itemId: String
    var itemName: String
    var userName: String     // 非空
    var password: String     // 非空
    var website: String     //
    var note: String        //
    //var updateTime: String
    
    init(itemId: String, itemName: String, userName: String, password: String, website: String, note: String) {
        self.itemId = itemId
        self.itemName = itemName
        self.userName = userName
        self.password = password
        self.website = website
        self.note = note
        
    }

}

extension Login: Equatable {
    static func ==(lhs: Login, rhs: Login) -> Bool {
        return lhs.itemId == rhs.itemId && lhs.itemName == rhs.itemName && lhs.userName == rhs.userName && lhs.password == rhs.password && lhs.website == rhs.website && lhs.note == rhs.note
    }
}


// Note
struct Note: Item {
    var id: String
    var text: String
}

// 信用卡模型

// 电影卡模型

// 其他模型

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






