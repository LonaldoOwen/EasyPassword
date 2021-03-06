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


import Foundation

// MARK: - 适用plist存储的model
class FolderModel {
    
    // enum -- 存储类型
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
    
    // enum -- folder 类型
    enum FolderType: Int {
        case all = 0
        case login = 1
        case note = 2
        
        var typeString: String {
            switch self {
            case .all:
                return "All Item Type on IPHONE"    //"IPHONE上的所有类型"
            case .login:
                return  "Login" //"登录信息"
            case .note:
                return  "Note"  //"备忘信息"
            }
        }
        
        var imageName: String {
            switch self {
            case .all:
                return "Item all29"
            case .login:
                return "login29"
            case .note:
                return "note29"
            }
        }
    }
    
    // enum -- item 类型
    enum ItemType: Int {
        //case all = 0
        case login = 1
        case note = 2
        
        var typeString: String {
            switch self {
//            case .all:
//                return "All Item Type on IPHONE"
            case .login:
                return "Login"
            case .note:
                return "Note"
            }
        }
        
        var imageName: String {
            switch self {
//            case .all:
//                return "Item all29"
            case .login:
                return "login29"
            case .note:
                return "note29"
            }
        }
    }
    

    
    // sqlite db存储--data model
    var persistentType: PersistentType
    //var itemType: ItemType
    var folderType: FolderType
    var count: String
    
    init(persistentType: PersistentType, folderType: FolderType, count: String) {
        self.persistentType = persistentType
        //self.itemType = itemType
        self.count = count
        self.folderType = folderType
    }
}


// MARK: - 适用sqlite db存储的model






