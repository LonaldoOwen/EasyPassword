//
//  EasyPasswordUITests.swift
//  EasyPasswordUITests
//
//  Created by owen on 2018/4/25.
//  Copyright © 2018 libowen. All rights reserved.
//

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
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        print("Hello, UITests!")
    }
    
    func testMasterPassword() {
        // enter master password
        let elementsQuery = app.scrollViews.otherElements
        let secureTextField = elementsQuery.secureTextFields["输入主密码"]
        let enterButton = elementsQuery.buttons["arrow white"]
        secureTextField.tap()
        secureTextField.typeText("qaz")
        enterButton.tap()
        
        _testZctivity()
        
        _testAttachment()
    }
    
    /**
     验证Activity的使用
    */
    func _testZctivity() {
        print("Test activity.")
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

        XCTContext.runActivity(named: "Activity: create new login") {_ in
            // create new login
            let addButton = app.toolbars["Toolbar"].buttons["新建类型"]
            let loginButton = app.sheets["新建类型"].buttons["登录信息"]
            addButton.tap()
            loginButton.tap()
            // 判断login VC出现
            sleep(1)
        }

    }


    /**
     验证Attachment的使用
     */
    func _testAttachment() {
        print("Test attachment.")
        
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
    
}
