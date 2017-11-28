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
    ///
    public class func makeDefaulFolderPlis() {
        let defaultArray = [["type": "My IPHONE"], ["name": "备忘"], ["count": "0"]]
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
    ///
    ///
    public class func readPlist(ofName name: String) -> [Any]{
        
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let fileUrl = documentDirectory.appendingPathComponent(name, isDirectory: false)
        if fileManager.fileexist
    }
}



/// Write





