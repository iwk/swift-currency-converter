//
//  ExchangeCalculator.swift
//  CashMoney
//
//  Created by Philip Ip on 17/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import Foundation

class ExchangeCalculator:NSObject {
    static let sharedInstance = ExchangeCalculator()
    private override init() {} //This prevents others from using the default '()' initializer for this class.

    var exchangeTable:NSMutableDictionary = NSMutableDictionary()
    
    func addCurrencyWithValue(currencyCode:String, value:Double)
    {
        exchangeTable.setObject(value, forKey: currencyCode)
    }
    
    func getCurrencyValue(fromCurrencyCode:String, toCurrencyCode:String, amount:Double) -> Double
    {
        let fromValue:Double = exchangeTable.objectForKey(fromCurrencyCode) as! Double
        let toValue:Double = exchangeTable.objectForKey(toCurrencyCode) as! Double
        
        return amount/fromValue*toValue
        
    }
}