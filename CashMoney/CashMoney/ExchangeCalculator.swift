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
        exchangeTable.setObject(value, forKey: currencyCode as NSCopying)
    }
    
    //convert from one currency to another
    func getCurrencyValue(fromCurrencyCode:String, toCurrencyCode:String, amount:Double) -> Double
    {
        if (exchangeTable.object(forKey: fromCurrencyCode) != nil) && (exchangeTable.object(forKey: toCurrencyCode) != nil)
        {
            
            let fromValue:Double = exchangeTable.object(forKey: fromCurrencyCode) as! Double
            let toValue:Double = exchangeTable.object(forKey: toCurrencyCode) as! Double
            
            return amount/fromValue*toValue
        }
        else
        {
            return Double.nan
        }
        
    }
}
