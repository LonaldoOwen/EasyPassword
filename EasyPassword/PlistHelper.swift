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


/// Write





