//
//  FolderModel.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/29.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// FolderModel
/// 功能：主页面的data model，用于显示文件夹数据
/// 1、
/// 2、

/*
 var persistent: String // 持久化方式
 var folderName: String // 文件夹name
 var itmes: [ItemModel] // 条目

 */

import Foundation

class FolderModel {
    
    /// 可以定义一个enum来处理相关操作()
    enum PersistentType {
        case iphone, icloud
    }
    
    var persistentType: String
    var itemType: String
    var items: [Item]
    
    init(persistentType: String, itemType: String, items: [Item]?) {
        self.persistentType = persistentType
        self.itemType = itemType
        self.items = items != nil ? items! : [Item]()
    }
    
    
}
