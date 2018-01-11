//
//  SQLiteHelper.swift
//  EasyPassword
//
//  Created by libowen on 2018/1/11.
//  Copyright © 2018年 libowen. All rights reserved.
//

import Foundation
import SQLite3

// 定义协议--
protocol SQLTable {
    static var createStatement: String { get }
}

// 定义enum处理sqlite error
enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
    case Exec(message: String)
}

// 创建一个SQLiteDatabase
class SQLiteDatabase {
    // 定义私有属性
    fileprivate var dbPointer: OpaquePointer?   // stored property
    fileprivate var errorMessage: String {
        // 使用sqlite提供的error message，否则给出统一的message
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String.init(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }   // computed property
    
    // 定义initializer
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    // 定义deinit方法
    deinit {
        // 关闭sqlite db
        sqlite3_close(dbPointer)
    }
    
    // 定义open db方法
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil
        // 1 打开db
        if sqlite3_open(path, &db) == SQLITE_OK {
            // 2 返回SQLiteDatabase实例
            return SQLiteDatabase.init(dbPointer: db)
        } else {
            // 3 延期处理,处理完error后--关闭db
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            // 处理error
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "Open--No error message provided from sqlite.")
            }
        }
    }
}

// 扩展SQLiteDatabase--封装 sqlite3_prepare()方法
extension SQLiteDatabase {
    // 准备statement 对象
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
    
}


// 扩展SQLiteDatabase--封装s qlite3_exec()方法
extension SQLiteDatabase {
    //
    func execSql(_ sql: String) throws -> Bool {
        var err: UnsafeMutablePointer<Int8>? = nil
        guard sqlite3_exec(dbPointer, sql, nil, nil, &err) == SQLITE_OK else {
            if let errorMsg = err {
                let message = String.init(cString: errorMsg)
                throw SQLiteError.Exec(message: message)
            } else {
                throw SQLiteError.Exec(message: "Execute--No error message provided from sqlite.")
            }
        }
        return true
    }
    
}

// 扩展SQLiteDatabase--封装 CREATE Table
extension SQLiteDatabase {
    //
    func createTable(table: SQLTable.Type) throws {
        // 1
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        // 2 销毁statement对象
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
        guard sqlite3_step(createTableStatement) == SQLITE_DONE  else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("\(table) table created.")
    }
}

// 扩展SQLiteDatabase--封装 INSERT
extension SQLiteDatabase {
    //
    func insert(sql: String) throws {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
        }
        print("Successfully inserted row.")
    
    }
}

// 扩展SQLiteDatabase--封装 SELECT
extension SQLiteDatabase {
    //
    func queryAll(sql: String) -> [Login]? {
        var logins = [Login]()
        //let queryStatement = try! prepareStatement(sql: sql)
        if let queryStatement = try? prepareStatement(sql: sql) {
            defer {
                sqlite3_finalize(queryStatement)
            }
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                // 处理查询结果，生成data model
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let itemname = String.init(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let username = String.init(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
                let password = String.init(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
                let website = String.init(cString: queryResultCol4!)
                let queryResultCol5 = sqlite3_column_text(queryStatement, 5)
                let note = String.init(cString: queryResultCol5!)
                let queryResultCol6 = sqlite3_column_text(queryStatement, 6)
                let itemType = String.init(cString: queryResultCol6!)
                let queryResultCol7 = sqlite3_column_text(queryStatement, 7)
                let persistentType = String.init(cString: queryResultCol7!)
                
                let login = Login(itemname: itemname, username: username, password: password, website: website, note: note)
                logins.append(login)
            }
        } else {
            print("SELECT statement could not be prepared")
            return nil
        }
        
        return logins
    }
}

// 扩展SQLiteDatabase--封装 UPDATE
extension SQLiteDatabase {
    //
    func update(sql: String) throws {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
        }
        print("Successfully update row.")
    }
    
}

// 扩展SQLiteDatabase--封装 DELETE
extension SQLiteDatabase {
    //
    func delete(sql: String) throws {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
        }
        print("Successfully delete row.")
    }
}


// 扩展SQLiteDatabase--获取db path
extension SQLiteDatabase {
    //
    static func getDBPath() -> URL {
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let dbUrl = documentDirectory.appendingPathComponent("EasyPassword.sqlite", isDirectory: false)
        
        return dbUrl
    }
}









