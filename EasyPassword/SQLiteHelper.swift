//
//  SQLiteHelper.swift
//  EasyPassword
//
//  Created by libowen on 2018/1/11.
//  Copyright © 2018年 libowen. All rights reserved.
//
/// SQLiteHelper.swift
/// 功能：封装sqlite3语法，使用Swift风格
/// 
///



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
/// 封装SQLite3对象
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
        print("#close sqlite db!")
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
                    print("db != nil, close sqlite db! ???")
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



// 扩展SQLiteDatabase--class method
extension SQLiteDatabase {
    
    // 创建db实例
    static func createDB() throws -> SQLiteDatabase {
        var db: SQLiteDatabase!
        let dbUrl = SQLiteDatabase.getDBPath("EasyPassword.sqlite")
        let dbPath = dbUrl.path
        do {
            db = try SQLiteDatabase.open(path: dbPath)
            print("Successfully opened connection to database.")
        } catch SQLiteError.OpenDatabase(let message) {
            print("Unable to open database. :\(message)")
        } catch {
            print("Others errors")
        }
        
        return db
    }

    
    // other class method
}



// 扩展SQLiteDatabase--封装 sqlite3基础方法
extension SQLiteDatabase {

    /// 封装 sqlite3_prepare()方法，返回prepared statement对象
    ///
    /// - Parameter sql: SQL语句
    /// - Returns: 指针类型，返回prepared statement对象
    /// - Throws: 抛出error
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
    
    
    /// 封装s qlite3_exec()方法
    ///
    /// - Parameter sql: SQL语句
    /// - Returns: Bool type, 执行成功返回true，否则报错
    /// - Throws: 抛出error
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
    // create table
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
    // execute Insert
    func insert(sql: String) throws {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
        }
        print("Successfully inserted row.")
    
    }
    
    // execute Insert--返回Item_id
    func insertIntoTable(_ table: String, sql: String) throws -> Int? {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
        }
        print("Successfully inserted row.")
        if let queryResult = querySql(sql: "SELECT Item_id FROM \(table);") {
            return Int(queryResult.last?["Item_id"] as! Int32)
        }
        
        return nil
    }
}

// 扩展SQLiteDatabase--封装 SELECT
extension SQLiteDatabase {
    // 有了下面的方法，这个方法就可以废弃了，而且显得非常笨拙
//    func queryAll(sql: String) -> [Login]? {
//        var logins = [Login]()
//        //let queryStatement = try! prepareStatement(sql: sql)
//        if let queryStatement = try? prepareStatement(sql: sql) {
//            defer {
//                sqlite3_finalize(queryStatement)
//            }
//
//            while sqlite3_step(queryStatement) == SQLITE_ROW {
//                // 处理查询结果，生成data model
//                let id = sqlite3_column_int(queryStatement, 0)
//                print("\(id) not use in model!")
//                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
//                let itemname = String.init(cString: queryResultCol1!)
//                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
//                let username = String.init(cString: queryResultCol2!)
//                let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
//                let password = String.init(cString: queryResultCol3!)
//                let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
//                let website = String.init(cString: queryResultCol4!)
//                let queryResultCol5 = sqlite3_column_text(queryStatement, 5)
//                let note = String.init(cString: queryResultCol5!)
//                let queryResultCol6 = sqlite3_column_text(queryStatement, 6)
//                let itemType = String.init(cString: queryResultCol6!)
//                print("\(itemType) not use in model!")
//                let queryResultCol7 = sqlite3_column_text(queryStatement, 7)
//                let persistentType = String.init(cString: queryResultCol7!)
//                print("\(persistentType) not use in model!")
//
//                let login = Login(itemId: String(id), itemName: itemname, userName: username, password: password, website: website, note: note)
//                logins.append(login)
//            }
//        } else {
//            print("SELECT statement could not be prepared")
//            return nil
//        }
//
//        return logins
//    }
    
    
    /// 通用Query方法
    ///
    /// - Parameter sql: SQL语句
    /// - Returns: 返回数组类型，可以为nil，数组里面存储的是字典类型
    func querySql(sql: String) -> [[String: Any]]? {
        var tempArray: [[String: Any]] = []
        if let queryStatement = try? prepareStatement(sql: sql) {
            defer {
                sqlite3_finalize(queryStatement)
            }
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let columns = sqlite3_column_count(queryStatement)
                var row: [String: Any] = Dictionary()
                for i in 0..<columns {
                    let type = sqlite3_column_type(queryStatement, i)
                    let chars = UnsafePointer<CChar>(sqlite3_column_name(queryStatement, i))
                    let name = String.init(cString: chars!, encoding: String.Encoding.utf8)
                    var value: Any
                    switch type {
                    case SQLITE_INTEGER:
                        value = sqlite3_column_int(queryStatement, i)
                    case SQLITE_FLOAT:
                        value = sqlite3_column_double(queryStatement, i)
                    case SQLITE_TEXT:
                        let chars = UnsafePointer<CUnsignedChar>(sqlite3_column_text(queryStatement, i))
                        value = String.init(cString: chars!)
                    case SQLITE_BLOB:
                        let data = sqlite3_column_blob(queryStatement, i)
                        let size = sqlite3_column_bytes(queryStatement, i)
                        value = NSData.init(bytes: data, length: Int(size))
                    default:
                        value = ""
                    }
                    // 存储一条结果
                    row.updateValue(value, forKey: "\(name!)")
                }
                // 存储所有结果
                tempArray.append(row)
            }
            if tempArray.count == 0 {
                return nil
            } else {
                return tempArray
            }
        } else {
            print("SELECT statement could not be prepared")
            return nil
        }

    }
    
    // query -- 部分Keys
    
    // 统计Table中rows的数量
    /// 统计Table中rows的数量
    ///
    /// - Parameter table: String type, table name
    /// - Returns: Int type, count of rows in table
    func numberOfRowsInTable(_ table: String) -> Int {
        let queryResult = querySql(sql: "SELECT COUNT(*) FROM \(table);")
        let tableRowsCount: Int = Int(queryResult?.first!["COUNT(*)"] as! Int32)
        
        return tableRowsCount
    }
    
    
    /// sqlite中sqlite_master中是否包含table
    ///
    /// - Parameter table: String type，table name
    /// - Returns: Bool type，包含返回true，不包含返回false
    func masterContainTable(_ table: String) -> Bool? {
        let queryMasterResult = querySql(sql: "SELECT tbl_name FROM sqlite_master WHERE type = 'table';")
        let hasTable = queryMasterResult?.contains(where: { (row) -> Bool in
            let value = row["tbl_name"] as! String
            if value == table {
                return true
            }
            return false
        })
        
        return hasTable
    }
    
    
}

// 扩展SQLiteDatabase--封装 UPDATE
extension SQLiteDatabase {
    // execute Update
    func update(sql: String) throws -> Bool {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
            return false
        }
        print("Successfully update row.")
        return true
    }
    
}

// 扩展SQLiteDatabase--封装 DELETE
extension SQLiteDatabase {
    // execute Delete
    func delete(sql: String) throws {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
        }
        print("Successfully delete row.")
    }
}


// 扩展SQLiteDatabase--封装 Delete Table
extension SQLiteDatabase {
    //
    func deleteTable(sql: String) throws {
        guard try execSql(sql) == true else {
            throw SQLiteError.Exec(message: errorMessage)
        }
        print("Successfully delete table.")
    }
}


// 扩展SQLiteDatabase--获取db path
extension SQLiteDatabase {
    //
    static func getDBPath(_ path: String) -> URL {
        let fileManager = FileManager.default
        let documentDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let dbUrl = documentDirectory.appendingPathComponent(path, isDirectory: false)
        
        return dbUrl
    }
}









