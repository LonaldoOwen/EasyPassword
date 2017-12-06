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
    
    struct item {
        var name: String
        var count: String
    }
    
    var type: String
    var items: [item]
    
    init(type: String, items: [item]) {
        self.type = type
        self.items = items
    }
    
    
}
