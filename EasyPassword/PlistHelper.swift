//
//  PlistHelper.swift
//  EasyPassword
//
//  Created by libowen on 2017/11/28.
//  Copyright © 2017年 libowen. All rights reserved.
//
/// PlistHelper
/// 功能：用于read、write plist
///

import UIKit
import Foundation

class PlistHelper {
    
//    let fileManager: FileManager = {
//        let fileManager = FileManager.default
//        return fileManager
//    }()
    
}

extension PlistHelper {
    
    /// 创建默认文件夹plist
    public class func makeDefaulFolderPlis() {
        
        let tempItem = ["username": "temp", "password": "123", "website": "temp.com", "note": "This is temp!"]
        let icloudArray = [["itemType": "iCloud备忘", "persistentType": "ICLOUD", "items": [tempItem]]]
        let iphoneArray = [["itemType": "备忘", "persistentType": "MyIPHONE","items": [tempItem]]]
        let defaultArray = [icloudArray, iphoneArray]
        let serializedData = try! PropertyListSerialization.data(fromPropertyList: defaultArray, format: .xml, options: 0)
        let fileManager = FileManager.default
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let plistUrl = documentsDirectory.appendingPathComponent("Folder.plist", isDirectory: false)
        
        do {
            try serializedData.write(to: plistUrl, options: .atomic)
        } catch let error {
            print("error: \(error)")
        }
    }
}

/// Read
extension PlistHelper {
    
    /// 获取沙盒中directory中的plist路径
    /// @ofName plist的完整名称，如：Folder.plist
    /// @return String
    public class func getPlistPath(ofName name: String) -> String {
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileUrl = documentDirectory.appendingPathComponent(name, isDirectory: false)
        let filePath = fileUrl.path
        return filePath
    }
    
    
    /// 读取plist返回数组
    /// @forResource plist名称
    /// @ofType plist类型
    /// @return [Any]
    public class func readPlist(forResource name: String?, ofType ext: String?) -> [Any]{
        
        let path = Bundle.main.path(forResource: name , ofType: ext)
        let fileManager = FileManager.default
        let plistData = fileManager.contents(atPath: path!)
        
        let tempArray: [[String: Any]] = try! PropertyListSerialization.propertyList(from: plistData!, options: [], format: nil) as! [[String : Any]]
        
        return tempArray
    }
    
    /// 从沙盒路径读取plist
    /// @ofName plist完整名称，如：Folder.plist
    /// @return 返回plist数据
    public class func readPlist(ofName name: String) -> Any{
        
        let fileManager = FileManager.default

        let filePath = self.getPlistPath(ofName: name)
        if fileManager.fileExists(atPath: filePath) {
            let data = fileManager.contents(atPath: filePath)
            let plist = try! PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil)
            print("readPlist(ofName:) plist: \(plist)")
            return plist
        } else {
            print("File not exists at: \(filePath)")
        }
       return [Any]()
    }
    
    ///
    
    ///
    
    ///

}



/// Write
extension PlistHelper {
    
    /// 将plist写入沙盒directory
    /// @plist property list
    /// @toPath Property list 路径（String）
    public class func write(plist: Any, toPath: String) {
        let serializedData = try! PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        let fileUrl = URL.init(fileURLWithPath: toPath)
        do {
            try serializedData.write(to: fileUrl, options: .atomic)
        } catch let error {
            print("Write plist failed: \(error)")
        }
    }
    
    
    /// 向plist中插入item
    ///
    ///
    /// 问题：存在插入不进去的情况？？？
    public class func insert(_ item: [String: Any], ofPersistentType type: String, itemType: String) {
        let plist = PlistHelper.readPlist(ofName: "Folder.plist") as! [[[String: Any]]]
        //var tempPlist = Array.init(plist)
        var tempPlist = plist                       // copy plist
        if type == "MyIPHONE" {
            var iphoneFolder = tempPlist[1]
            for (index, folder) in iphoneFolder.enumerated() {
                if folder["itemType"] as! String == itemType {
                    var tempFolder = folder                             // copy folder
                    var items = tempFolder["items"] as! [[String: Any]]
                    items.insert(item, at: 0)                           // insert item
                    tempFolder["items"] = items                         // update items
                    print(items)
                    iphoneFolder[index] = tempFolder                    // update iphoneFolder
                }
            }
            tempPlist[1] = iphoneFolder                                 // update tempPlist
        }
        // write plist
        PlistHelper.write(plist: tempPlist, toPath: PlistHelper.getPlistPath(ofName: "Folder.plist"))
    }
    
}




