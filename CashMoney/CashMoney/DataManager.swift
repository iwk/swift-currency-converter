//
//  DataManager.swift
//  CashMoney
//
//  Created by Philip Ip on 17/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import Foundation


class DataManager:NSObject, NSURLConnectionDelegate {
    static let sharedInstance = DataManager()
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func loadJSONFromUrl(urlPath:String)
    {
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                print(json)
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
    }
    
}