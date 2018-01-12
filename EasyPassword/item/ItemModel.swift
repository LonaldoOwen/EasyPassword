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
    
    var itemname: String
    var username: String     // 非空
    var password: String     // 非空
    var website: String     //
    var note: String        //
    
    init(itemname: String, username: String, password: String, website: String, note: String) {
        self.itemname = itemname
        self.username = username
        self.password = password
        self.website = website
        self.note = note
    }
}


// 信用卡模型

// 电影卡模型

// 其他模型
