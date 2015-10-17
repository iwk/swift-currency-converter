//
//  CashMoneyTests.swift
//  CashMoneyTests
//
//  Created by Philip Ip on 14/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import XCTest
@testable import CashMoney

class CashMoneyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        ExchangeCalculator.sharedInstance.addCurrencyWithValue("AUD", value: 1.5)
        ExchangeCalculator.sharedInstance.addCurrencyWithValue("EUR", value: 1)
        ExchangeCalculator.sharedInstance.addCurrencyWithValue("USD", value: 1.1)

        
    }
    
    
    
    //MARK:- Calculator
    func testExchangeCalculatorConvert(){
        XCTAssertEqual(100, ExchangeCalculator.sharedInstance.getCurrencyValue("AUD", toCurrencyCode: "EUR", amount: 150))
        XCTAssertEqual(100, ExchangeCalculator.sharedInstance.getCurrencyValue("AUD", toCurrencyCode: "AUD", amount: 100))
        XCTAssertEqual(0, ExchangeCalculator.sharedInstance.getCurrencyValue("AUD", toCurrencyCode: "EUR", amount: 0))
    }
    func testExchangeCalculatorInvalidCurrency(){
        
        XCTAssertTrue(ExchangeCalculator.sharedInstance.getCurrencyValue("AUD", toCurrencyCode: "NAD", amount: 150).isNaN)
        
        XCTAssertTrue(ExchangeCalculator.sharedInstance.getCurrencyValue("NAN", toCurrencyCode: "AUD", amount: 150).isNaN)
    }
    
   
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
