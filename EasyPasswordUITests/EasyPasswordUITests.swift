//
//  EasyPasswordUITests.swift
//  EasyPasswordUITests
//
//  Created by owen on 2018/4/25.
//  Copyright © 2018 libowen. All rights reserved.
//
///
/// 功能：UITest；验证Xcode 9新增Testing内容
///
///
///
/// 新增内容：
/// 1、Activity
/// 2、Attachment
/// 3、XCTWaiter
/// 4、



import XCTest

class EasyPasswordUITests: XCTestCase {
    
    
    let app = XCUIApplication()
    
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testExample() {
//        // Use recording to get started writing UI tests.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        print("Hello, UITests!")
//    }
    
    /**
     验证输入主密码
    */
    func test_A_MasterPassword() {
        // enter master password
        enterMasterPassword()
        
        //_testZctivity()
        
        //_testAttachment()
    }
    
    
    /**
     验证新建类型（Activity的使用）
     问题：现在执行一个case就会重新调用一次proxy app（即：proxy app重新加载一次？？？）
    */
    func test_B_Activity() {
        print("Test activity.")
        
        // 先输入主密码
        enterMasterPassword()
        
        // add activity
        XCTContext.runActivity(named: "Activity: tap add and cancel") { _ in
            // tap add and cancel
            let addButton = app.toolbars["Toolbar"].buttons["新建类型"]
            let cancelButton = app.sheets["新建类型"].buttons["取消"]
            addButton.tap()
            // 判断是否出现sheet
            sleep(1)
            cancelButton.tap()
        }

    }


    /**
     验证login VC（Attachment的使用）
     */
    func test_C_Attachment() {
        print("Test attachment.")
        
        // 先输入主密码
        enterMasterPassword()
        
        // 点击，新建类型-登陆信息
        XCTContext.runActivity(named: "Activity: create new login") { _ in
            // create new login
            let addButton = app.toolbars["Toolbar"].buttons["新建类型"]
            let loginButton = app.sheets["新建类型"].buttons["登录信息"]
            addButton.tap()
            loginButton.tap()
            // 判断login VC出现
            sleep(1)
        }
        
        XCTContext.runActivity(named: "Activity: Gather screenshots") {activity in
            // Capture the full screen（创建全屏截图）
            let mainscreen = XCUIScreen.main
            let fullScreenshot = mainscreen.screenshot()
            let fullScreenshotAttachment = XCTAttachment(screenshot: fullScreenshot)
            fullScreenshotAttachment.lifetime = .keepAlways
            activity.add(fullScreenshotAttachment)

            let cancel = app.navigationBars["EasyPassword.CreateItemVC"].buttons["Cancel"]
            cancel.tap()

            // Capture just the toolbar（创建部分截图）
            let toolbar = app.toolbars.firstMatch
            let toolbarScreenshot = toolbar.screenshot()
            let toolbarScreenshotAttachment = XCTAttachment(screenshot: toolbarScreenshot)
            toolbarScreenshotAttachment.lifetime = .keepAlways
            activity.add(toolbarScreenshotAttachment)
        }

    }
    
    /**
     验证新建类型（XCTWaiter使用）
     
    */
    func test_D_XCTWaiter() {
        // 先输入主密码
        enterMasterPassword()
        
        //
        XCTContext.runActivity(named: "Activity: tap add and cancel") { _ in
            
            // tap add and cancel
            let addButton = app.toolbars["Toolbar"].buttons["新建类型"]
            let cancelButton = app.sheets["新建类型"].buttons["取消"]
            addButton.tap()
            
            // 判断是否出现sheet
            // identifier: ???
            // label: ???
            XCTContext.runActivity(named: "Activity: Assert") { _ in
                XCTAssertEqual(app.sheets.element.label, "新建类型", "Failed: 未找到sheet。")
            }
            
            // 点击，取消
            sleep(1)
            cancelButton.tap()
        }
        
        
    }
    
    /**
     验证login VC（wait的使用）
    */
    func test_E_Wait() {
        // 先输入主密码
        enterMasterPassword()
        
        // 点击，新建类型-登陆信息
        XCTContext.runActivity(named: "Activity: create new login") { _ in
            // create new login
            let addButton = app.toolbars["Toolbar"].buttons["新建类型"]
            let loginButton = app.sheets["新建类型"].buttons["登录信息"]
            addButton.tap()
            loginButton.tap()
            
            // 判断login VC出现（根据button=生成新密码）
            sleep(1)
            // wait：using waitForExistence()
            // 此方法会返回Bool值，不会直接failed掉test case
            let newButton = app.scrollViews.buttons["生成新密码"]
            _ = newButton.waitForExistence(timeout: 10)
            // wait: using XCTAssertEqual()
            //XCTAssertEqual(app.scrollViews.buttons.element.label, "生成新密码", "Failed: 未找到button=生成新密码。")
            
            // Wait: 判断是否出现itemName = "qqq"
            // identifier: ???label: ???（哪些元素有identifier属性、哪些有label属性）
            XCTContext.runActivity(named: "Activity: Assert") { _ in
                let itemName = app.scrollViews.firstMatch.textFields.element(matching: NSPredicate(format: "value = %@", "qqq"))
                
//                let predicate = NSPredicate(format: "exists == true")
//                expectation(for: predicate, evaluatedWith: itemName, handler: nil)
//                waitForExpectations(timeout: 10, handler: nil)
                // 可行
                //self.waitForElementToAppear(itemName, timeOut: 10)
                // failed
                //self.waitForExpectation(expectation: expectation(description: "Find qqq"), time: 10)
                //
                let result = itemName.waitForExistence(timeout: 5)
                print("result: \(result)")
            }
            
        }
    }
    
    
    
    
    // MARK: - Helper
    
    func enterMasterPassword() {
        XCTContext.runActivity(named: "Activity: Enter Master Password ") { _ in
            // enter master password
            let elementsQuery = app.scrollViews.otherElements
            let secureTextField = elementsQuery.secureTextFields["输入主密码"]
            let enterButton = elementsQuery.buttons["arrow white"]
            secureTextField.tap()
            secureTextField.typeText("qaz")
            enterButton.tap()
            // 判断导航栏title=“EasyPassword”
            XCTAssertEqual(app.navigationBars.firstMatch.identifier, "EasyPassword", "Failed: 未找到title=EasyPassword。")
        }
    }
    
    
    // wait: using waitForExpectations()
    // 此种方法如果timeout后，test case会失败
    func waitForElementToAppear(_ element: XCUIElement, timeOut: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        
        let predicate = NSPredicate(format: "exists == true")
        expectation(for: predicate, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeOut) { (error) in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeOut) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
    }
    
    // wait: using
    func waitForExpectation(expectation:XCTestExpectation, time: Double, safe: Bool = false) {
        let result: XCTWaiter.Result = XCTWaiter().wait(for: [expectation], timeout: time)
        if !safe && result != .completed {
            // if expectation is strict and was not fulfilled
            XCTFail("Condition was not satisfied during \(time) seconds")
        }
    }
    
}
