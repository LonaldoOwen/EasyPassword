//
//  EasyPasswordUITests_Login_.swift
//  EasyPasswordUITests(Login)
//
//  Created by owen on 2018/5/1.
//  Copyright © 2018 libowen. All rights reserved.
//

import XCTest

class EasyPasswordUITests_Login_: XCTestCase {
    
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
    }
    
    func testLogin() {
        // enter master password
        enterMasterPassword()
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
    
}
