/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import SQLite3
import PlaygroundSupport

// 运行前先删除已经创建的db
//destroyPart1Database()

/*:
 
 # Getting Started
 
 The first thing to do is set your playground to run manually rather than automatically. This will help ensure that your SQL commands run when you intend them to. At the bottom of the playground click and hold the Play button until the dropdown menu appears. Choose "Manually Run".
 
 You will also notice a `destroyPart1Database()` call at the top of this page. You can safely ignore this, the database file used is destroyed each time the playground is run to ensure all statements execute successfully as you iterate through the tutorial.
 
 Secondly, this Playground will need to write SQLite database files to your file system. Create the directory `~/Documents/Shared Playground Data/SQLiteTutorial` by running the following command in Terminal.
 
 `mkdir -p ~/Documents/Shared\ Playground\ Data/SQLiteTutorial`
 
 */
// 打开sqlite数据库
func openDatabase() -> OpaquePointer? {
    // 声明SQLite3对象指针
    var db: OpaquePointer? = nil
    // 打开数据库（如果没有创建新的）
    if sqlite3_open(part1DbPath, &db) == SQLITE_OK {
        print("Successfully opened connection to database at \(part1DbPath)")
        return db
    } else {
        print("Unable to open database. Verify that you created the directory described " +
            "in the Getting Started section.")
        PlaygroundPage.current.finishExecution()
    }
}


// 执行SQL语句(CREATE Table, INSERT, UPDATE, DELETE, ...)
//（One-Step Query Execution Interface）
func execSql(_ sql: String) -> Bool {
    var err: UnsafeMutablePointer<Int8>? = nil
    if sqlite3_exec(db, sql, nil, nil, &err) != SQLITE_OK {
        if let error = String(validatingUTF8: sqlite3_errmsg(db)) {
            print("execute failed to execute  Error: \(error)")
        }
        return false
    }
    return true
}
//: ## Open a Connection
let db = openDatabase()
//: ## Create a Table
// 创建Table SQL
let createTableString = """
CREATE TABLE Contact(
Id INT PRIMARY KEY NOT NULL,
Name CHAR(255));
"""

// 创建Table
func createTable() {
    // 1
    var createTableStatement: OpaquePointer? = nil
    // 2
    if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
        // 3
        if sqlite3_step(createTableStatement) == SQLITE_DONE {
            print("Contact table created.")
        } else {
            print("Contact table could not be created.")
        }
    } else {
        print("CREATE TABLE statement could not be prepared.")
    }
    // 4
    sqlite3_finalize(createTableStatement)
}

//createTable()

// 创建Table--使用execSql()
func createTable(_ sql: String) {
    if execSql(sql) {
        print("Table created.")
    } else {
        print("Table could not be created.")
    }
}
createTable(createTableString)

//: ## Insert a Contact
// 创建Insert SQL
let insertStatementString = "INSERT INTO Contact (Id, Name) VALUES (?, ?);"

func insert() {
    var insertStatement: OpaquePointer? = nil
    
    // 1
    if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
        let id: Int32 = 1
        let name: NSString = "Ray"
        
        // 2
        sqlite3_bind_int(insertStatement, 1, id)
        // 3
        sqlite3_bind_text(insertStatement, 2, name.utf8String, -1, nil)
        
        // 4
        if sqlite3_step(insertStatement) == SQLITE_DONE {
            print("Successfully inserted row.")
        } else {
            print("Could not insert row.")
        }
    } else {
        print("INSERT statement could not be prepared.")
    }
    // 5
    sqlite3_finalize(insertStatement)
}

//insert()

// Insert--使用execSql()
func insert(_ sql: String) {
    if execSql(sql) {
        print("Successfully inserted row.")
    } else {
        print("Could not insert row.")
    }
}
insert("INSERT INTO Contact (Id, Name) VALUES (1, 'ZhangSan');")
//insert("INSERT INTO Contact (Id, Name) VALUES (2, 'LiSi');")
//: ## Querying
let queryStatementString = "SELECT * FROM Contact;"

func query() {
    var queryStatement: OpaquePointer? = nil
    // 1
    if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
        // 2
        if sqlite3_step(queryStatement) == SQLITE_ROW {
            // 3
            let id = sqlite3_column_int(queryStatement, 0)
            
            // 4
            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
            let name = String(cString: queryResultCol1!)
            
            // 5
            print("Query Result:")
            print("\(id) | \(name)")
            
        } else {
            print("Query returned no results")
        }
    } else {
        print("SELECT statement could not be prepared")
    }
    
    // 6
    sqlite3_finalize(queryStatement)
}
query()

// 不能使用一步执行接口，这样获取不到结果；需要分步来执行
//func query(_ sql: String) {
//    if execSql(sql) {
//        print("Query Result:")
//    } else {
//        print("Query returned no results")
//    }
//}
//query(queryStatementString)

// 查询Table所有值
func queryAll(_ sql: String) {
    var queryStatement: OpaquePointer? = nil
    if sqlite3_prepare(db, sql, -1, &queryStatement, nil) == SQLITE_OK {
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            let id = sqlite3_column_int(queryStatement, 0)
            let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
            let name = String(cString: queryResultCol1!)
            print("Query Result:")
            print("\(id) | \(name)")
        }
    } else {
        print("SELECT statement could not be prepared")
    }
    sqlite3_finalize(queryStatement)
}
queryAll(queryStatementString)
//: ## Update
let updateStatementString = "UPDATE Contact SET Name = 'Chris' WHERE Id = 1;"

func update() {
    var updateStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK {
        if sqlite3_step(updateStatement) == SQLITE_DONE {
            print("Successfully updated row.")
        } else {
            print("Could not update row.")
        }
    } else {
        print("UPDATE statement could not be prepared")
    }
    sqlite3_finalize(updateStatement)
}
//update()
//query()

// Update--使用execSql()
func update(_ sql: String) {
    if execSql(sql) {
        print("Successfully updated row.")
    } else {
        print("Could not update row.")
    }
}
update("UPDATE Contact SET Name = 'Chris Zhang' WHERE Id = 1;")
queryAll(queryStatementString)
//: ## Delete
let deleteStatementStirng = "DELETE FROM Contact WHERE Id = 1;"

func delete() {
    var deleteStatement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("Successfully deleted row.")
        } else {
            print("Could not delete row.")
        }
    } else {
        print("DELETE statement could not be prepared")
    }
    
    sqlite3_finalize(deleteStatement)
}

//delete()
//query()

// Delete--使用execSql()
func delete(_ sql: String) {
    if execSql(sql) {
        print("Successfully deleted row.")
    } else {
        print("Could not delete row.")
    }
}
delete("DELETE FROM Contact WHERE Id = 2;")
//: ## Errors
let malformedQueryString = "SELECT Stuff from Things WHERE Whatever;"

func prepareMalformedQuery() {
    var malformedStatement: OpaquePointer? = nil
    // 1
    if sqlite3_prepare_v2(db, malformedQueryString, -1, &malformedStatement, nil) == SQLITE_OK {
        print("This should not have happened.")
    } else {
        // 2
        let errorMessage = String.init(cString: sqlite3_errmsg(db))
        print("Query could not be prepared! \(errorMessage)")
    }
    
    // 3
    sqlite3_finalize(malformedStatement)
}

prepareMalformedQuery()
//: ## Close the database connection
sqlite3_close(db)
queryAll(queryStatementString)
//: Continue to [Making It Swift](@next)

