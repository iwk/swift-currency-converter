//
//  CashMoneyUITests.swift
//  CashMoneyUITests
//
//  Created by Philip Ip on 14/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import XCTest

class CashMoneyUITests: XCTestCase {
        
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
    
    //Assert output text is changed as required
    func testConvertFigure()
    {
        let app = XCUIApplication()
    
        
        let logoPngElementsQuery = app.otherElements.containingType(.Image, identifier:"Logo.png")
        let textField = logoPngElementsQuery.childrenMatchingType(.TextField).elementBoundByIndex(0)
        
        let textField2 = logoPngElementsQuery.childrenMatchingType(.TextField).elementBoundByIndex(1)
        
        //Before entering input text
        XCTAssertEqual(textField2.value as? String, "£0.00")
        
        textField.tap()
        textField.typeText("100")
        app.typeText("\n")
        
        //After entering input text
        XCTAssertNotEqual(textField2.value as? String, "£0.00")
    }
    
    //Entering  "10000.0" -> "10000.00" -> "10000.001" while formating input in realtime
    //Format as "$10,000.0" -> "$10,000.00"(intermediate) -> "$10,000.001"
    func testInputCase_IntermediateTrailingZeros()
    {
        
        let app = XCUIApplication()
        let textField = app.otherElements.containingType(.Image, identifier:"Logo.png").childrenMatchingType(.TextField).elementBoundByIndex(0)
        textField.tap()
        textField.typeText("10000.001")
        app.otherElements.containingType(.Image, identifier:"Logo.png").element.tap()
        
    }
    
    //Entering "0"  "."  "."  "."  "."  "1"
    func testInputCase_RepeatedAndTrailingDots()
    {
        let app = XCUIApplication()
        let textField = app.otherElements.containingType(.Image, identifier:"Logo.png").childrenMatchingType(.TextField).elementBoundByIndex(0)
        textField.tap()
        textField.typeText("1.........1")
        app.otherElements.containingType(.Image, identifier:"Logo.png").element.tap()
        app.staticTexts["EUR"].tap()
    }
    
    
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
}
